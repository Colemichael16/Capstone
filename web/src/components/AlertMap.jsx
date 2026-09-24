import { useEffect, useRef, useState } from 'react'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'
import { INITIAL_VIEW, MAPBOX_TOKEN, MAP_STYLE } from '../config.js'
import { SEVERITIES, SEVERITY_COLORS, SEVERITY_LABELS } from '../alerts/contract.js'
import { circlePolygon, polygonBounds } from '../alerts/geo.js'

const EMPTY = { type: 'FeatureCollection', features: [] }

const severityColor = [
  'match',
  ['get', 'severity'],
  ...SEVERITIES.flatMap((s) => [s, SEVERITY_COLORS[s]]),
  '#6b7280',
]
const isArea = ['==', ['geometry-type'], 'Polygon']
const isPin = ['==', ['geometry-type'], 'Point']

// Each alert becomes an area (true-meter radius) plus a pin at its center
function toFeatures(alert, extra = {}) {
  const center = alert.center.coordinates
  const properties = {
    id: alert.id,
    severity: alert.severity,
    // Severity is spelled out on the map so it is never conveyed by color alone
    label: SEVERITY_LABELS[alert.severity].toUpperCase(),
    ...extra,
  }
  return [
    { type: 'Feature', properties, geometry: circlePolygon(center, alert.radius_m) },
    { type: 'Feature', properties, geometry: { type: 'Point', coordinates: center } },
  ]
}

function addLayers(map) {
  map.addSource('alerts', { type: 'geojson', data: EMPTY })
  map.addSource('draft', { type: 'geojson', data: EMPTY })

  map.addLayer({
    id: 'alert-fill',
    type: 'fill',
    source: 'alerts',
    filter: isArea,
    paint: { 'fill-color': severityColor, 'fill-opacity': 0.18 },
  })
  map.addLayer({
    id: 'alert-outline',
    type: 'line',
    source: 'alerts',
    filter: isArea,
    paint: {
      'line-color': severityColor,
      'line-width': ['case', ['get', 'selected'], 3.5, 1.5],
    },
  })
  map.addLayer({
    id: 'draft-fill',
    type: 'fill',
    source: 'draft',
    filter: isArea,
    paint: { 'fill-color': severityColor, 'fill-opacity': 0.25 },
  })
  map.addLayer({
    id: 'draft-outline',
    type: 'line',
    source: 'draft',
    filter: isArea,
    paint: { 'line-color': severityColor, 'line-width': 2.5, 'line-dasharray': [2, 1.5] },
  })
  for (const source of ['alerts', 'draft']) {
    map.addLayer({
      id: `${source}-pin`,
      type: 'circle',
      source,
      filter: isPin,
      paint: {
        'circle-color': severityColor,
        'circle-radius': ['case', ['get', 'selected'], 10, 8],
        'circle-stroke-color': '#fff',
        'circle-stroke-width': 2.5,
      },
    })
    map.addLayer({
      id: `${source}-label`,
      type: 'symbol',
      source,
      filter: isPin,
      layout: {
        'text-field': ['get', 'label'],
        'text-font': ['DIN Pro Bold', 'Arial Unicode MS Bold'],
        'text-size': 11,
        'text-letter-spacing': 0.08,
        'text-offset': [0, 1.4],
        'text-anchor': 'top',
        'text-allow-overlap': true,
      },
      paint: { 'text-color': severityColor, 'text-halo-color': '#fff', 'text-halo-width': 1.5 },
    })
  }
}

export default function AlertMap({ alerts, selectedId, onSelect, draft, picking, onPick }) {
  const containerRef = useRef(null)
  const mapRef = useRef(null)
  const [ready, setReady] = useState(false)
  // Map event handlers are bound once; read the latest props through a ref
  const handlers = useRef({})
  useEffect(() => {
    handlers.current = { picking, onPick, onSelect }
  })

  useEffect(() => {
    if (!MAPBOX_TOKEN) return
    mapboxgl.accessToken = MAPBOX_TOKEN
    const map = new mapboxgl.Map({ container: containerRef.current, style: MAP_STYLE, ...INITIAL_VIEW })
    mapRef.current = map
    map.addControl(new mapboxgl.NavigationControl(), 'top-right')
    map.addControl(new mapboxgl.ScaleControl({ unit: 'imperial' }), 'bottom-right')

    map.on('load', () => {
      addLayers(map)
      setReady(true)
    })

    map.on('click', (e) => {
      const { picking, onPick, onSelect } = handlers.current
      if (picking) {
        onPick([e.lngLat.lng, e.lngLat.lat])
        return
      }
      const [hit] = map.queryRenderedFeatures(e.point, { layers: ['alerts-pin', 'alert-fill'] })
      if (hit) onSelect(hit.properties.id)
    })

    map.on('mousemove', (e) => {
      if (handlers.current.picking) return
      const hits = map.queryRenderedFeatures(e.point, { layers: ['alerts-pin', 'alert-fill'] })
      map.getCanvas().style.cursor = hits.length ? 'pointer' : ''
    })

    return () => {
      map.remove()
      mapRef.current = null
      setReady(false)
    }
  }, [])

  useEffect(() => {
    if (!ready) return
    const features = alerts.flatMap((a) => toFeatures(a, { selected: a.id === selectedId }))
    mapRef.current.getSource('alerts').setData({ type: 'FeatureCollection', features })
  }, [ready, alerts, selectedId])

  useEffect(() => {
    if (!ready) return
    const features = draft?.center
      ? toFeatures({ ...draft, id: 'draft', center: { type: 'Point', coordinates: draft.center } })
      : []
    mapRef.current.getSource('draft').setData({ type: 'FeatureCollection', features })
  }, [ready, draft])

  useEffect(() => {
    if (!ready) return
    mapRef.current.getCanvas().style.cursor = picking ? 'crosshair' : ''
  }, [ready, picking])

  // Frame the selected alert's whole radius, not just its pin
  const selected = alerts.find((a) => a.id === selectedId)
  useEffect(() => {
    if (!ready || !selected) return
    const area = circlePolygon(selected.center.coordinates, selected.radius_m)
    mapRef.current.fitBounds(polygonBounds(area), { padding: 60, maxZoom: 18 })
  }, [ready, selected])

  if (!MAPBOX_TOKEN) {
    return (
      <div className="map-missing">
        <p>
          Map unavailable: set <code>VITE_MAPBOX_TOKEN</code> in <code>web/.env.local</code> (see{' '}
          <code>.env.example</code>) and restart the dev server.
        </p>
      </div>
    )
  }

  return <div ref={containerRef} className="map" aria-label="Campus alert map" role="region" />
}
