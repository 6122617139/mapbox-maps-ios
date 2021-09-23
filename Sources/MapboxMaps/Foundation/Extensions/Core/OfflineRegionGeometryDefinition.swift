@_implementationOnly import MapboxCoreMaps_Private

extension MapboxCoreMaps.OfflineRegionGeometryDefinition {
    /// The geometry that defines the boundary of the offline region.
    public var geometry: Turf.Geometry? {
        get {
            return Turf.Geometry(__geometry)
        }
    }
}
