import { useEffect, useMemo, useState } from 'react'
import { fetchActiveAlerts, publishAlert, subscribeToAlerts } from './alerts/api.js'
import { isActive } from './alerts/contract.js'
import { EMPTY_DRAFT, draftToAlert } from './alerts/draft.js'
import { sampleAlerts } from './alerts/sampleAlerts.js'
import AlertMap from './components/AlertMap.jsx'
import Composer from './components/Composer.jsx'
import ConfirmPublish from './components/ConfirmPublish.jsx'
import Dashboard from './components/Dashboard.jsx'
import SignIn from './components/SignIn.jsx'
import { supabase } from './supabase.js'
import './App.css'

// Re-render periodically so expired alerts clear off the map on their own
function useNow(intervalMs) {
  const [now, setNow] = useState(() => Date.now())
  useEffect(() => {
    const id = setInterval(() => setNow(Date.now()), intervalMs)
    return () => clearInterval(id)
  }, [intervalMs])
  return now
}

// Without Supabase configured there is no auth; treat the app as signed in
function useSession() {
  const [session, setSession] = useState(null)
  const [ready, setReady] = useState(!supabase)
  useEffect(() => {
    if (!supabase) return
    const { data } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s)
      setReady(true)
    })
    return () => data.subscription.unsubscribe()
  }, [])
  return { session, ready, signedIn: !supabase || Boolean(session) }
}

const publishErrorMessage = (err) =>
  err.code === '42501' ? 'This account is not a registered dispatcher.' : `Publish failed: ${err.message}`

export default function App() {
  const { session, ready, signedIn } = useSession()
  const [alerts, setAlerts] = useState(supabase ? [] : sampleAlerts)
  const [loadError, setLoadError] = useState(null)
  const [view, setView] = useState('dashboard') // dashboard | compose | confirm
  const [draft, setDraft] = useState(EMPTY_DRAFT)
  const [selectedId, setSelectedId] = useState(null)
  const [publishing, setPublishing] = useState(false)
  const [publishError, setPublishError] = useState(null)
  const now = useNow(30_000)
  const activeAlerts = useMemo(() => alerts.filter((a) => isActive(a, now)), [alerts, now])
  const userId = session?.user.id

  // Initial load, then refetch whenever Realtime reports a change to public.alerts
  useEffect(() => {
    if (!supabase) return
    let cancelled = false
    const load = () =>
      fetchActiveAlerts().then(
        (rows) => {
          if (cancelled) return
          setAlerts(rows)
          setLoadError(null)
        },
        (err) => !cancelled && setLoadError(err.message),
      )
    load()
    const unsubscribe = subscribeToAlerts(load)
    return () => {
      cancelled = true
      unsubscribe()
    }
  }, [userId])

  const publish = async () => {
    const alert = draftToAlert(draft)
    if (supabase) {
      setPublishing(true)
      setPublishError(null)
      try {
        await publishAlert(alert)
      } catch (err) {
        setPublishError(publishErrorMessage(err))
        return
      } finally {
        setPublishing(false)
      }
    }
    // Show it immediately; the Realtime refetch replaces this with the server row
    setAlerts((prev) => [alert, ...prev.filter((a) => a.id !== alert.id)])
    setDraft(EMPTY_DRAFT)
    setSelectedId(alert.id)
    setView('dashboard')
  }

  const cancelDraft = () => {
    setDraft(EMPTY_DRAFT)
    setPublishError(null)
    setView('dashboard')
  }

  return (
    <div className="app">
      <header className="topbar">
        <span className="brand">ReagentWatch</span>
        <span className="subtitle">Office of Safety · Dispatcher</span>
        {session && (
          <span className="account">
            {session.user.email}
            <button type="button" className="secondary" onClick={() => supabase.auth.signOut()}>
              Sign out
            </button>
          </span>
        )}
      </header>

      <aside className="panel">
        {ready && !signedIn && <SignIn />}
        {signedIn && loadError && (
          <p className="warning" role="alert">
            Couldn&apos;t load alerts: {loadError}
          </p>
        )}
        {signedIn && view === 'dashboard' && (
          <Dashboard
            alerts={activeAlerts}
            selectedId={selectedId}
            onSelect={setSelectedId}
            onNewAlert={() => {
              setSelectedId(null)
              setView('compose')
            }}
          />
        )}
        {signedIn && view === 'compose' && (
          <Composer draft={draft} onChange={setDraft} onCancel={cancelDraft} onReview={() => setView('confirm')} />
        )}
        {signedIn && view === 'confirm' && (
          <ConfirmPublish
            draft={draft}
            onBack={() => {
              setPublishError(null)
              setView('compose')
            }}
            onPublish={publish}
            publishing={publishing}
            error={publishError}
          />
        )}
      </aside>

      <main className="map-wrap">
        <AlertMap
          alerts={activeAlerts}
          selectedId={selectedId}
          onSelect={setSelectedId}
          draft={view === 'dashboard' ? null : draft}
          picking={view === 'compose'}
          onPick={(center) => setDraft((d) => ({ ...d, center }))}
        />
      </main>
    </div>
  )
}
