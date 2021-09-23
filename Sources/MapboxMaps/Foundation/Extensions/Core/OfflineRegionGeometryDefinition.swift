@_implementationOnly import MapboxCoreMaps_Private
import MapboxCommon

extension MapboxCoreMaps.OfflineRegionGeometryDefinition {

    convenience init(styleURL: String, geometry: Turf.Geometry, minZoom: Double, maxZoom: Double, pixelRatio: Float, glyphsRasterizationMode: GlyphsRasterizationMode) {
        let commonGeometry = MapboxCommon.Geometry(geometry: geometry)
        self.init(styleURL: styleURL, geometry: commonGeometry, minZoom: minZoom, maxZoom: maxZoom, pixelRatio: pixelRatio, glyphsRasterizationMode: glyphsRasterizationMode)
    }

    /// The geometry that defines the boundary of the offline region.
    public var geometry: Turf.Geometry? {
        get {
            return Turf.Geometry(__geometry)
        }
    }
}
