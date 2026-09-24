export const MAPBOX_TOKEN = import.meta.env.VITE_MAPBOX_TOKEN

// Shared with the iOS app so both clients render the same campus style
export const MAP_STYLE = 'mapbox://styles/colemichael16/cmtw4y9ih005901skhxpidcxg'

export const INITIAL_VIEW = {
  center: [-105.26999046550955, 40.00736870089145],
  zoom: 17.661848768717196,
  bearing: 0,
  pitch: 0,
}
