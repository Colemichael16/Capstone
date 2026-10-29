import { supabase } from '../supabase.js'

// Contract-shaped rows (center as GeoJSON) via the alerts_feed view
export async function fetchActiveAlerts() {
  const { data, error } = await supabase
    .from('alerts_feed')
    .select('*')
    .in('status', ['active', 'updated'])
    .gt('expires_at', new Date().toISOString())
    .order('issued_at', { ascending: false })
  if (error) throw error
  return data
}

// Inserts into public.alerts; Realtime then delivers the row to the iOS app.
// issued_by is left to the column default (auth.uid()), which RLS requires.
export async function publishAlert(alert) {
  const [lng, lat] = alert.center.coordinates
  const { error } = await supabase.from('alerts').insert({
    id: alert.id,
    status: alert.status,
    category: alert.category,
    severity: alert.severity,
    headline: alert.headline,
    short_message: alert.short_message,
    full_details: alert.full_details,
    instructions: alert.instructions,
    center: `SRID=4326;POINT(${lng} ${lat})`,
    radius_m: alert.radius_m,
    issued_at: alert.issued_at,
    expires_at: alert.expires_at,
  })
  if (error) throw error
}

// Calls onChange on any insert/update/delete visible to this user under RLS
export function subscribeToAlerts(onChange) {
  const channel = supabase
    .channel('alerts')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'alerts' }, onChange)
    .subscribe()
  return () => supabase.removeChannel(channel)
}
