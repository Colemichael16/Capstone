export const EXPIRY_OPTIONS_H = [1, 2, 4, 8, 24]

export const EMPTY_DRAFT = {
  center: null,
  radius_m: 150,
  category: 'police',
  severity: 'severe',
  headline: '',
  short_message: '',
  instructions: '',
  full_details: '',
  expires_in_h: 2,
}

export const draftIsComplete = (d) => Boolean(d.center && d.headline.trim() && d.short_message.trim())

// Composer state -> a row matching shared/alert.schema.json
export function draftToAlert({ expires_in_h, center, ...fields }) {
  const now = Date.now()
  return {
    ...fields,
    id: crypto.randomUUID(),
    status: 'active',
    headline: fields.headline.trim(),
    short_message: fields.short_message.trim(),
    instructions: fields.instructions.trim() || null,
    full_details: fields.full_details.trim() || null,
    center: { type: 'Point', coordinates: center },
    issued_by: null,
    issued_at: new Date(now).toISOString(),
    expires_at: new Date(now + expires_in_h * 3600_000).toISOString(),
  }
}
