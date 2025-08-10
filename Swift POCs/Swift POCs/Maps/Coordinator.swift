//
//  Coordinator.swift
//  Swift POCs
//
//  Created by Priyadharshan Raja on 27/07/25.
//

import SwiftUI
import MapKit

class Coordinator: NSObject {
    private var routeColors: [MKPolyline: UIColor] = [:]
    private var colorIndex = 0
    private let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
    
    private var selectedAnnotation: MKAnnotation?
    private let locationManager = CLLocationManager()
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var floatingViewHostingController: UIHostingController<ETAFloatingView>?
    
    private var sources: [CLLocationCoordinate2D: UIView] = [:]

    init(destination: CLLocationCoordinate2D) {
        self.destinationCoordinate = destination
    }

    func updateFloatingViewsPosition(_ mapView: MKMapView) {
        guard !sources.isEmpty else { return }
        for source in sources {
            let floatingView = source.value
            let point = mapView.convert(source.key, toPointTo: mapView)
            floatingView.center = CGPoint(x: point.x, y: point.y + 50) // adjust offset as needed
        }
    }
    
    private func hideFloatingViews() {
        guard !sources.isEmpty else { return }
        for source in sources {
            let floatingView = source.value
            UIView.animate(withDuration: 0.25, animations: {
                floatingView.alpha = 0
                floatingView.isHidden = true
            })
        }
    }
    
    private func showFloatingViews() {
        guard !sources.isEmpty else { return }
        for source in sources {
            UIView.animate(withDuration: 0.25, animations: {
                let floatingView = source.value
                floatingView.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    floatingView.alpha = 1
                }
            })
        }
    }
    
    func addRoutes(from sources: [CLLocationCoordinate2D], to destination: CLLocationCoordinate2D, on mapView: MKMapView) {
        for source in sources {
            let annotation = MKPointAnnotation()
            annotation.coordinate = source
            mapView.addAnnotation(annotation)
            addRoute(from: source, to: destination, on: mapView)
        }
    }
    
    private func addRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, on mapView: MKMapView) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        MKDirections(request: request).calculate { response, error in
            guard let route = response?.routes.first else { return }
            let polyline = route.polyline
            
            let routeColor = self.colors[self.colorIndex % self.colors.count]
            self.routeColors[polyline] = routeColor
            self.colorIndex += 1
            
            mapView.addOverlay(polyline)
            mapView.setVisibleMapRect(mapView.visibleMapRect.union(polyline.boundingMapRect), animated: true)

            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { [weak self] response, error in
                guard let self = self,
                      let route = response?.routes.min(by: { $0.expectedTravelTime < $1.expectedTravelTime }) else { return }
                
                let etaMinutes = Int(route.expectedTravelTime / 60)
                let etaSwiftUIView = ETAFloatingView(etaMinutes: etaMinutes)
                let hostingController = UIHostingController(rootView: etaSwiftUIView)
                let etaView = hostingController.view!
                
                etaView.backgroundColor = .clear
                let point = mapView.convert(source, toPointTo: mapView)
                etaView.frame = CGRect(x: point.x-80, y: point.y+20, width: 160, height: 40)
                
                mapView.addSubview(etaView)
                self.updateFloatingViewsPosition(mapView)
                self.floatingViewHostingController = hostingController
                
                self.sources[source] = etaView
            }
        }
    }
}

extension MKPolyline {
    func coordinates() -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        return coords
    }
}

extension Coordinator: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedAnnotation = view.annotation
        guard let destinationCoordinate, let sourceCoordinate = view.annotation?.coordinate else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self,
                  let route = response?.routes.first else { return }
            
            let etaMinutes = Int(route.expectedTravelTime / 60)
            let etaSwiftUIView = ETAFloatingView(etaMinutes: etaMinutes)
            let hostingController = UIHostingController(rootView: etaSwiftUIView)
            let etaView = hostingController.view!

            etaView.backgroundColor = .clear
            etaView.frame = CGRect(x: 0, y: 0, width: 160, height: 40)

            mapView.addSubview(etaView)
            self.updateFloatingViewsPosition(mapView)
            self.floatingViewHostingController = hostingController

        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        showFloatingViews()
        updateFloatingViewsPosition(mapView)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView){
        hideFloatingViews()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }

        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = routeColors[polyline] ?? .blue
        renderer.lineWidth = 4
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "ProfileImagePin"
        let profileColor: UIColor = self.colors[self.colorIndex % self.colors.count]

        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysTemplate)
            annotationView?.tintColor = profileColor
            annotationView?.frame.size = CGSize(width: 40, height: 40)
            annotationView?.layer.cornerRadius = 20
            annotationView?.clipsToBounds = true
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        floatingView?.removeFromSuperview()
//        floatingView = nil
        selectedAnnotation = nil
    }
}

#Preview{
    RouteContentView()
}

extension CLLocationCoordinate2D:  @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
