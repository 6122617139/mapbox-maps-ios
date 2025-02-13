import UIKit

/// `PitchGestureHandler` updates the map camera in response to a vertical,
/// 2-touch pan gesture in which the angle between the touch points is less than 45°.
internal final class PitchGestureHandler: GestureHandler, UIGestureRecognizerDelegate {
    private var initialPitch: CGFloat?

    internal init(gestureRecognizer: UIPanGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.minimumNumberOfTouches = 2
        gestureRecognizer.maximumNumberOfTouches = 2
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    private func touchAngleIsLessThanMaximum(for gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view,
              gestureRecognizer === self.gestureRecognizer,
              self.gestureRecognizer.numberOfTouches == 2 else {
            return false
        }
        let touchLocation0 = self.gestureRecognizer.location(ofTouch: 0, in: view)
        let touchLocation1 = self.gestureRecognizer.location(ofTouch: 1, in: view)
        let angleBetweenTouchLocations = angleOfLine(from: touchLocation0, to: touchLocation1)
        return abs(angleBetweenTouchLocations) < 45
    }

    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return touchAngleIsLessThanMaximum(for: gestureRecognizer)
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialPitch = mapboxMap.cameraState.pitch
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pitch)
        case .changed:
            guard let view = gestureRecognizer.view,
                  let initialPitch = initialPitch else {
                return
            }

            let translation = gestureRecognizer.translation(in: view)
            let translationAngle = angleOfLine(from: .zero, to: translation)

            // If the angle between the touch locations is less than the maximum
            // AND the translation angle is more than 60 degrees, update the pitch.
            if touchAngleIsLessThanMaximum(for: gestureRecognizer), abs(translationAngle) > 60 {
                let verticalGestureTranslation = translation.y
                let slowDown = CGFloat(2.0)
                let newPitch = initialPitch - (verticalGestureTranslation / slowDown)
                mapboxMap.setCamera(to: CameraOptions(pitch: newPitch))
            }
        case .ended, .cancelled:
            initialPitch = nil
        default:
            break
        }
    }

    /**
     Calculates the angle in degrees between two points.
     For example, the angle between (0,0) and (1, 1) would be 45°
     */
    private func angleOfLine(from start: CGPoint, to end: CGPoint) -> CGFloat {
        var origin = start
        var end = end
        if start.x > end.x {
            origin = end
            end = start
        }
        let deltaX = end.x - origin.x
        let deltaY = end.y - origin.y
        let angleInRadians = atan2(deltaY, deltaX)
        return angleInRadians * 180 / .pi
    }
}
