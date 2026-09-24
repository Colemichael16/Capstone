import {
  CATEGORIES,
  CATEGORY_LABELS,
  HEADLINE_MAX,
  SEVERITIES,
  SEVERITY_LABELS,
  SHORT_MESSAGE_MAX,
} from '../alerts/contract.js'
import { EXPIRY_OPTIONS_H, draftIsComplete } from '../alerts/draft.js'
import NotificationPreview from './NotificationPreview.jsx'

export default function Composer({ draft, onChange, onCancel, onReview }) {
  const set = (field) => (e) => {
    const value = e.target.type === 'range' || field === 'expires_in_h' ? Number(e.target.value) : e.target.value
    onChange({ ...draft, [field]: value })
  }

  return (
    <form
      className="composer"
      onSubmit={(e) => {
        e.preventDefault()
        if (draftIsComplete(draft)) onReview()
      }}
    >
      <h2>New alert</h2>

      <p className={`pin-status ${draft.center ? 'placed' : ''}`} role="status">
        {draft.center
          ? `Pin at ${draft.center[1].toFixed(5)}, ${draft.center[0].toFixed(5)}. Click the map to move it.`
          : 'Click the map to place the alert pin.'}
      </p>

      <label>
        Radius <output>{draft.radius_m} m</output>
        <input type="range" min="25" max="1500" step="25" value={draft.radius_m} onChange={set('radius_m')} />
      </label>

      <div className="row">
        <label>
          Category
          <select value={draft.category} onChange={set('category')}>
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {CATEGORY_LABELS[c]}
              </option>
            ))}
          </select>
        </label>
        <label>
          Severity
          <select value={draft.severity} onChange={set('severity')}>
            {SEVERITIES.map((s) => (
              <option key={s} value={s}>
                {SEVERITY_LABELS[s]}
              </option>
            ))}
          </select>
        </label>
      </div>

      <label>
        Headline{' '}
        <small>
          {draft.headline.length}/{HEADLINE_MAX}
        </small>
        <input required maxLength={HEADLINE_MAX} value={draft.headline} onChange={set('headline')} />
      </label>

      <label>
        Short message{' '}
        <small>
          {draft.short_message.length}/{SHORT_MESSAGE_MAX}
        </small>
        <textarea
          required
          rows="2"
          maxLength={SHORT_MESSAGE_MAX}
          value={draft.short_message}
          onChange={set('short_message')}
        />
      </label>

      <label>
        Instructions
        <textarea
          rows="2"
          placeholder="Avoid 18th & Colorado. Shelter in place."
          value={draft.instructions}
          onChange={set('instructions')}
        />
      </label>

      <label>
        Full details <small>shown on pin tap</small>
        <textarea rows="3" value={draft.full_details} onChange={set('full_details')} />
      </label>

      <label>
        Expires in
        <select value={draft.expires_in_h} onChange={set('expires_in_h')}>
          {EXPIRY_OPTIONS_H.map((h) => (
            <option key={h} value={h}>
              {h} {h === 1 ? 'hour' : 'hours'}
            </option>
          ))}
        </select>
      </label>

      <NotificationPreview headline={draft.headline} shortMessage={draft.short_message} />

      <div className="actions">
        <button type="button" className="secondary" onClick={onCancel}>
          Cancel
        </button>
        <button type="submit" disabled={!draftIsComplete(draft)}>
          Review →
        </button>
      </div>
    </form>
  )
}
