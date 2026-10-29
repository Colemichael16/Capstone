import { CATEGORY_LABELS } from '../alerts/contract.js'
import SeverityBadge from './SeverityBadge.jsx'

const time = (iso) => new Date(iso).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })

export default function Dashboard({ alerts, selectedId, onSelect, onNewAlert }) {
  return (
    <>
      <button type="button" className="new-alert" onClick={onNewAlert}>
        + New alert
      </button>

      <h2>
        Active alerts <span className="count">{alerts.length}</span>
      </h2>

      {alerts.length === 0 ? (
        <p className="empty">No active alerts. The map is clear.</p>
      ) : (
        <ul className="alert-list">
          {alerts.map((a) => {
            const selected = a.id === selectedId
            return (
              <li key={a.id} className={selected ? 'selected' : ''}>
                <button type="button" className="alert-item" aria-expanded={selected} onClick={() => onSelect(a.id)}>
                  <SeverityBadge severity={a.severity} />
                  <span className="alert-headline">{a.headline}</span>
                  <span className="alert-meta">
                    {CATEGORY_LABELS[a.category]} · {a.radius_m} m radius · expires {time(a.expires_at)}
                  </span>
                </button>
                {selected && (
                  <div className="alert-details">
                    <p>{a.short_message}</p>
                    {a.instructions && (
                      <p>
                        <strong>Instructions:</strong> {a.instructions}
                      </p>
                    )}
                    {a.full_details && <p>{a.full_details}</p>}
                    <p className="alert-meta">Issued {time(a.issued_at)}</p>
                  </div>
                )}
              </li>
            )
          })}
        </ul>
      )}
    </>
  )
}
