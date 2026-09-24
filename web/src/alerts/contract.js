import schema from '../../../shared/alert.schema.json'

export const STATUSES = schema.$defs.status.enum
export const CATEGORIES = schema.$defs.category.enum
export const SEVERITIES = schema.$defs.severity.enum
export const HEADLINE_MAX = schema.properties.headline.maxLength
export const SHORT_MESSAGE_MAX = schema.properties.short_message.maxLength

export const CATEGORY_LABELS = {
  active_threat: 'Active threat',
  fire: 'Fire',
  weather: 'Weather',
  hazmat: 'Hazmat',
  police: 'Police activity',
  utility: 'Utility outage',
  protest: 'Protest',
  medical: 'Medical',
}

export const SEVERITY_LABELS = {
  extreme: 'Extreme',
  severe: 'Severe',
  moderate: 'Moderate',
  minor: 'Minor',
}

export const SEVERITY_COLORS = {
  extreme: '#b91c1c',
  severe: '#ea580c',
  moderate: '#ca8a04',
  minor: '#2563eb',
}

// Mirrors the "public reads active alerts" RLS policy
export const isActive = (alert, now = Date.now()) =>
  (alert.status === 'active' || alert.status === 'updated') &&
  new Date(alert.expires_at).getTime() > now
