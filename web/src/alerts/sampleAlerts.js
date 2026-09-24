// Stand-in data until Supabase and db/seed/scenarios.sql exist. These are the
// plan's three demo scenarios; coordinates are approximate.
const hoursFromNow = (h) => new Date(Date.now() + h * 3600_000).toISOString()

export const sampleAlerts = [
  {
    id: 'sample-norlin',
    status: 'active',
    category: 'active_threat',
    severity: 'extreme',
    headline: 'Police response near Norlin Library',
    short_message: 'Avoid Norlin Quad. Shelter in place if nearby.',
    full_details: 'CUPD is responding to a reported threat near Norlin Library.',
    instructions: 'Avoid Norlin Quad. Shelter in place and lock doors.',
    center: { type: 'Point', coordinates: [-105.2706, 40.0088] },
    radius_m: 150,
    issued_at: hoursFromNow(-0.25),
    expires_at: hoursFromNow(2),
  },
  {
    id: 'sample-chem',
    status: 'active',
    category: 'hazmat',
    severity: 'severe',
    headline: 'Chemical spill in chemistry building',
    short_message: 'Chemical spill reported. Stay out of the building until cleared.',
    full_details: 'Boulder Fire hazmat team on scene.',
    instructions: 'Evacuate the building and stay upwind.',
    center: { type: 'Point', coordinates: [-105.2722, 40.0069] },
    radius_m: 100,
    issued_at: hoursFromNow(-0.5),
    expires_at: hoursFromNow(3),
  },
  {
    id: 'sample-weather',
    status: 'active',
    category: 'weather',
    severity: 'moderate',
    headline: 'Severe thunderstorm warning',
    short_message: 'Lightning and hail expected. Move indoors.',
    full_details: null,
    instructions: 'Stay indoors until the warning expires.',
    center: { type: 'Point', coordinates: [-105.27, 40.0074] },
    radius_m: 900,
    issued_at: hoursFromNow(-1),
    expires_at: hoursFromNow(1),
  },
]
