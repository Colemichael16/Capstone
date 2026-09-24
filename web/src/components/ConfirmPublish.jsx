import { useState } from 'react'
import { CATEGORY_LABELS } from '../alerts/contract.js'
import NotificationPreview from './NotificationPreview.jsx'
import SeverityBadge from './SeverityBadge.jsx'

const CONFIRM_WORD = 'PUBLISH'

// Deliberate friction: accidental sends are the top real-world failure of alert systems
export default function ConfirmPublish({ draft, onBack, onPublish }) {
  const [typed, setTyped] = useState('')
  const confirmed = typed.trim() === CONFIRM_WORD

  return (
    <form
      className="confirm"
      onSubmit={(e) => {
        e.preventDefault()
        if (confirmed) onPublish()
      }}
    >
      <h2>Review and publish</h2>
      <p className="warning">This alert goes to every student with the app open, immediately.</p>

      <dl className="summary">
        <dt>Severity</dt>
        <dd>
          <SeverityBadge severity={draft.severity} />
        </dd>
        <dt>Category</dt>
        <dd>{CATEGORY_LABELS[draft.category]}</dd>
        <dt>Location</dt>
        <dd>
          {draft.center[1].toFixed(5)}, {draft.center[0].toFixed(5)} · {draft.radius_m} m radius
        </dd>
        <dt>Expires</dt>
        <dd>
          in {draft.expires_in_h} {draft.expires_in_h === 1 ? 'hour' : 'hours'}
        </dd>
        {draft.instructions && (
          <>
            <dt>Instructions</dt>
            <dd>{draft.instructions}</dd>
          </>
        )}
        {draft.full_details && (
          <>
            <dt>Full details</dt>
            <dd>{draft.full_details}</dd>
          </>
        )}
      </dl>

      <NotificationPreview headline={draft.headline} shortMessage={draft.short_message} />

      <label>
        Type <strong>{CONFIRM_WORD}</strong> to send
        <input value={typed} onChange={(e) => setTyped(e.target.value)} autoComplete="off" autoFocus />
      </label>

      <div className="actions">
        <button type="button" className="secondary" onClick={onBack}>
          ← Edit
        </button>
        <button type="submit" className="danger" disabled={!confirmed}>
          Publish alert
        </button>
      </div>
    </form>
  )
}
