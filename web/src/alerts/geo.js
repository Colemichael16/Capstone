const EARTH_RADIUS_M = 6371008.8
const toRad = (deg) => (deg * Math.PI) / 180
const toDeg = (rad) => (rad * 180) / Math.PI

// Geodesic circle as a GeoJSON Polygon, so the radius is true meters at any zoom
// (a Mapbox `circle` layer is sized in pixels, which would misrepresent the area).
export function circlePolygon([lng, lat], radiusM, steps = 64) {
  const φ1 = toRad(lat)
  const λ1 = toRad(lng)
  const δ = radiusM / EARTH_RADIUS_M
  const ring = []
  for (let i = 0; i < steps; i++) {
    const θ = (i / steps) * 2 * Math.PI
    const φ2 = Math.asin(Math.sin(φ1) * Math.cos(δ) + Math.cos(φ1) * Math.sin(δ) * Math.cos(θ))
    const λ2 =
      λ1 + Math.atan2(Math.sin(θ) * Math.sin(δ) * Math.cos(φ1), Math.cos(δ) - Math.sin(φ1) * Math.sin(φ2))
    ring.push([toDeg(λ2), toDeg(φ2)])
  }
  ring.push(ring[0])
  return { type: 'Polygon', coordinates: [ring] }
}

export function polygonBounds(polygon) {
  const [ring] = polygon.coordinates
  const lngs = ring.map((c) => c[0])
  const lats = ring.map((c) => c[1])
  return [
    [Math.min(...lngs), Math.min(...lats)],
    [Math.max(...lngs), Math.max(...lats)],
  ]
}
