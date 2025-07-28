//
//  Coordinator.swift
//  Swift POCs
//
//  Created by Priyadharshan Raja on 27/07/25.
//

import SwiftUI
import MapKit


struct ETAFloatingView: View {
    let etaMinutes: Int

    var body: some View {
        Text("ETA to HQ: \(etaMinutes) min")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .glassEffect()
            .foregroundColor(.black)
            .font(.system(size: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 0.5)
            )
            .cornerRadius(10)
            .shadow(radius: 2)
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    private var routeColors: [MKPolyline: UIColor] = [:]
    private var colorIndex = 0
    private let colors: [UIColor] = [.systemBlue, .systemRed, .systemGreen, .systemOrange, .systemPurple, .systemTeal]
    
    var floatingView: UIView?
    var selectedAnnotation: MKAnnotation?
    let locationManager = CLLocationManager()
    private var destinationCoordinate: CLLocationCoordinate2D?
    var floatingViewHostingController: UIHostingController<ETAFloatingView>?

    init(destination: CLLocationCoordinate2D) {
        self.destinationCoordinate = destination
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        floatingView?.removeFromSuperview()
        
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
            self.floatingView = etaView
            self.updateFloatingViewPosition(mapView)
            self.floatingViewHostingController = hostingController

        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateFloatingViewPosition(mapView)
    }

    func updateFloatingViewPosition(_ mapView: MKMapView) {
        guard let annotation = selectedAnnotation,
              let floatingView = floatingView else { return }
        
        let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
        floatingView.center = CGPoint(x: point.x, y: point.y - 50) // adjust offset as needed
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        floatingView?.removeFromSuperview()
        floatingView = nil
        selectedAnnotation = nil
    }

    
    func addRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, on mapView: MKMapView) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .any
        
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
                      let route = response?.routes.first else { return }
                
                let etaMinutes = Int(route.expectedTravelTime / 60)
                let etaSwiftUIView = ETAFloatingView(etaMinutes: etaMinutes)
                let hostingController = UIHostingController(rootView: etaSwiftUIView)
                let etaView = hostingController.view!
                
                etaView.backgroundColor = .clear
                etaView.frame = CGRect(x: 0, y: 0, width: 160, height: 40)
                
                mapView.addSubview(etaView)
                self.floatingView = etaView
                self.updateFloatingViewPosition(mapView)
                self.floatingViewHostingController = hostingController
            }
        }
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

}
#Preview{
    RouteContentView()
}
