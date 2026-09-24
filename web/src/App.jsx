import { useEffect, useMemo, useState } from 'react'
import { isActive } from './alerts/contract.js'
import { EMPTY_DRAFT, draftToAlert } from './alerts/draft.js'
import { sampleAlerts } from './alerts/sampleAlerts.js'
import AlertMap from './components/AlertMap.jsx'
import Composer from './components/Composer.jsx'
import ConfirmPublish from './components/ConfirmPublish.jsx'
import Dashboard from './components/Dashboard.jsx'
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

export default function App() {
  const [alerts, setAlerts] = useState(sampleAlerts)
  const [view, setView] = useState('dashboard') // dashboard | compose | confirm
  const [draft, setDraft] = useState(EMPTY_DRAFT)
  const [selectedId, setSelectedId] = useState(null)
  const now = useNow(30_000)
  const activeAlerts = useMemo(() => alerts.filter((a) => isActive(a, now)), [alerts, now])

  // TODO: replace with a Supabase insert; Realtime then delivers the row to the iOS app
  const publish = () => {
    const alert = draftToAlert(draft)
    setAlerts((prev) => [alert, ...prev])
    setDraft(EMPTY_DRAFT)
    setSelectedId(alert.id)
    setView('dashboard')
  }

  const cancelDraft = () => {
    setDraft(EMPTY_DRAFT)
    setView('dashboard')
  }

  return (
    <div className="app">
      <header className="topbar">
        <span className="brand">ReagentWatch</span>
        <span className="subtitle">Office of Safety · Dispatcher</span>
      </header>

      <aside className="panel">
        {view === 'dashboard' && (
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
        {view === 'compose' && (
          <Composer draft={draft} onChange={setDraft} onCancel={cancelDraft} onReview={() => setView('confirm')} />
        )}
        {view === 'confirm' && (
          <ConfirmPublish draft={draft} onBack={() => setView('compose')} onPublish={publish} />
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
