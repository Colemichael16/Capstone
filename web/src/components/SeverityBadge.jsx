import { SEVERITY_COLORS, SEVERITY_LABELS } from '../alerts/contract.js'

export default function SeverityBadge({ severity }) {
  return (
    <span className="severity-badge" style={{ '--sev': SEVERITY_COLORS[severity] }}>
      {SEVERITY_LABELS[severity]}
    </span>
  )
}
