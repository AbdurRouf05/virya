// Field Notes map style builder (no text labels → no glyph dependency).
// Supports Protomaps basemap v4 (offline PMTiles) and OpenMapTiles
// (OpenFreeMap online fallback).
(function () {
  'use strict';
  var C = {
    paper: '#EFE9DC', paperDeep: '#E3DBC9', paperLine: '#CFC6B2',
    ink: '#141414', inkSoft: '#3A3A36', inkMuted: '#77736A',
    water: '#B4C0C2', waterLine: '#8E9EA2',
    wood: '#DAD7C0', park: '#E0DCC6', urban: '#E6DFCF', farm: '#E9E3D3',
    building: '#D6CDB9'
  };
  var OSM = '© <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>';

  function w(z0, w0, z1, w1) {
    return ['interpolate', ['exponential', 1.6], ['zoom'], z0, w0, z1, w1];
  }

  // ---------- Protomaps v4 ----------
  function protomapsLayers(src) {
    var unpavedPm = ['any',
      ['==', ['get', 'kind'], 'path'],
      ['in', ['get', 'kind_detail'], ['literal', ['track', 'path', 'bridleway', 'footway', 'cycleway', 'steps']]],
      ['in', ['get', 'surface'], ['literal', ['unpaved', 'gravel', 'fine_gravel', 'dirt', 'ground', 'compacted', 'earth', 'sand', 'grass', 'mud']]]
    ];
    var road = function (id, kinds, color, width, minzoom) {
      return {
        id: id, type: 'line', source: src, 'source-layer': 'roads', minzoom: minzoom || 0,
        filter: ['all', ['in', ['get', 'kind'], ['literal', kinds]], ['!', unpavedPm]],
        layout: { 'line-cap': 'round', 'line-join': 'round' },
        paint: { 'line-color': color, 'line-width': width }
      };
    };
    return [
      { id: 'earth', type: 'fill', source: src, 'source-layer': 'earth', paint: { 'fill-color': C.paper } },
      { id: 'landcover', type: 'fill', source: src, 'source-layer': 'landcover',
        paint: { 'fill-color': ['match', ['get', 'kind'],
          'forest', C.wood, 'scrub', C.park, 'grassland', C.park, 'farmland', C.farm,
          'urban_area', C.urban, C.paper], 'fill-opacity': 0.8 } },
      { id: 'landuse', type: 'fill', source: src, 'source-layer': 'landuse',
        paint: { 'fill-color': ['match', ['get', 'kind'],
          ['forest', 'wood', 'nature_reserve', 'national_park', 'protected_area'], C.wood,
          ['park', 'grass', 'garden', 'golf_course', 'meadow', 'recreation_ground', 'cemetery', 'grave_yard'], C.park,
          ['farmland', 'orchard', 'farmyard', 'allotments', 'vineyard'], C.farm,
          C.paperDeep], 'fill-opacity': 0.55 } },
      { id: 'water', type: 'fill', source: src, 'source-layer': 'water',
        filter: ['match', ['geometry-type'], ['Polygon', 'MultiPolygon'], true, false], paint: { 'fill-color': C.water } },
      { id: 'waterway', type: 'line', source: src, 'source-layer': 'water',
        filter: ['match', ['geometry-type'], ['LineString', 'MultiLineString'], true, false],
        paint: { 'line-color': C.waterLine, 'line-width': w(9, 0.4, 16, 2.5) } },
      { id: 'buildings', type: 'fill', source: src, 'source-layer': 'buildings', minzoom: 13,
        paint: { 'fill-color': C.building, 'fill-opacity': 0.45 } },
      // Unpaved / tracks / paths: dashed (gravel focus).
      { id: 'road-unpaved', type: 'line', source: src, 'source-layer': 'roads', minzoom: 11,
        filter: unpavedPm, layout: { 'line-cap': 'butt', 'line-join': 'round' },
        paint: { 'line-color': C.inkSoft, 'line-width': w(11, 0.6, 18, 2.4), 'line-dasharray': [2.2, 1.6] } },
      road('road-minor', ['minor_road', 'other'], C.inkMuted, w(11, 0.3, 18, 4), 10),
      road('road-major', ['major_road'], C.inkSoft, w(7, 0.5, 18, 7)),
      road('road-highway', ['highway'], C.ink, w(5, 0.6, 18, 9)),
      { id: 'rail', type: 'line', source: src, 'source-layer': 'roads', minzoom: 10,
        filter: ['==', ['get', 'kind'], 'rail'],
        paint: { 'line-color': C.inkMuted, 'line-width': 1, 'line-dasharray': [4, 2] } },
      { id: 'boundaries', type: 'line', source: src, 'source-layer': 'boundaries',
        paint: { 'line-color': C.inkMuted, 'line-width': 0.8, 'line-dasharray': [3, 2], 'line-opacity': 0.5 } }
    ];
  }

  // ---------- OpenMapTiles (OpenFreeMap) ----------
  function omtLayers(src) {
    var unpaved = ['any',
      ['==', ['get', 'surface'], 'unpaved'],
      ['in', ['get', 'class'], ['literal', ['track', 'path']]]];
    var road = function (id, classes, color, width, minzoom) {
      return {
        id: id, type: 'line', source: src, 'source-layer': 'transportation', minzoom: minzoom || 0,
        filter: ['all', ['in', ['get', 'class'], ['literal', classes]], ['!', unpaved]],
        layout: { 'line-cap': 'round', 'line-join': 'round' },
        paint: { 'line-color': color, 'line-width': width }
      };
    };
    return [
      { id: 'landcover', type: 'fill', source: src, 'source-layer': 'landcover',
        paint: { 'fill-color': ['match', ['get', 'class'], 'wood', C.wood, 'grass', C.park,
          'farmland', C.farm, C.paper], 'fill-opacity': 0.8 } },
      { id: 'landuse', type: 'fill', source: src, 'source-layer': 'landuse',
        paint: { 'fill-color': C.urban, 'fill-opacity': 0.5 } },
      { id: 'park', type: 'fill', source: src, 'source-layer': 'park',
        paint: { 'fill-color': C.park, 'fill-opacity': 0.6 } },
      { id: 'water', type: 'fill', source: src, 'source-layer': 'water', paint: { 'fill-color': C.water } },
      { id: 'waterway', type: 'line', source: src, 'source-layer': 'waterway',
        paint: { 'line-color': C.waterLine, 'line-width': w(9, 0.4, 16, 2.5) } },
      { id: 'buildings', type: 'fill', source: src, 'source-layer': 'building', minzoom: 13,
        paint: { 'fill-color': C.building, 'fill-opacity': 0.45 } },
      { id: 'road-unpaved', type: 'line', source: src, 'source-layer': 'transportation', minzoom: 11,
        filter: ['all', unpaved, ['!=', ['get', 'class'], 'rail']],
        paint: { 'line-color': C.inkSoft, 'line-width': w(11, 0.6, 18, 2.4), 'line-dasharray': [2.2, 1.6] } },
      road('road-minor', ['minor', 'service', 'tertiary'], C.inkMuted, w(10, 0.3, 18, 4), 10),
      road('road-major', ['primary', 'secondary', 'trunk'], C.inkSoft, w(7, 0.5, 18, 7)),
      road('road-highway', ['motorway'], C.ink, w(5, 0.6, 18, 9)),
      { id: 'rail', type: 'line', source: src, 'source-layer': 'transportation', minzoom: 10,
        filter: ['==', ['get', 'class'], 'rail'],
        paint: { 'line-color': C.inkMuted, 'line-width': 1, 'line-dasharray': [4, 2] } }
    ];
  }

  function hillshade() {
    return { id: 'hillshade', type: 'hillshade', source: 'hs',
      paint: { 'hillshade-shadow-color': C.inkSoft, 'hillshade-highlight-color': '#FFFDF6',
        'hillshade-accent-color': C.inkMuted, 'hillshade-exaggeration': 0.35 } };
  }

  // cfg: { basemapUrl, demUrl, online }
  function build(cfg) {
    var sources = {};
    var layers = [{ id: 'background', type: 'background', paint: { 'background-color': C.paper } }];
    var base = [];
    if (cfg.basemapUrl) {
      sources.base = { type: 'vector', url: cfg.basemapUrl, attribution: '© Protomaps ' + OSM };
      base = protomapsLayers('base');
    } else if (cfg.online) {
      sources.base = { type: 'vector', url: 'https://tiles.openfreemap.org/planet',
        attribution: '<a href="https://openfreemap.org">OpenFreeMap</a> ' + OSM };
      base = omtLayers('base');
    }
    if (cfg.demUrl) {
      sources.dem = { type: 'raster-dem', url: cfg.demUrl, encoding: 'terrarium', tileSize: 256, maxzoom: 12 };
      sources.hs = { type: 'raster-dem', url: cfg.demUrl, encoding: 'terrarium', tileSize: 256, maxzoom: 12 };
    }
    // Hillshade sits above land/water, below roads.
    var split = base.findIndex(function (l) { return l.id === 'buildings'; });
    if (split < 0) split = base.length;
    layers = layers.concat(base.slice(0, split));
    if (cfg.demUrl) layers.push(hillshade());
    layers = layers.concat(base.slice(split));
    return { version: 8, sources: sources, layers: layers };
  }

  window.ViryaStyle = { build: build, colors: C };
})();
