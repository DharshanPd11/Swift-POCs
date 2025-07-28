//
//  SourceToDestinationRouteView.swift
//  Swift POCs
//
//  Created by Priyadharshan Raja on 27/07/25.
//

import SwiftUI
import MapKit

struct SourceToDestinationRouteView: UIViewRepresentable {
    let sources: [CLLocationCoordinate2D]
    let destination: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        for source in sources {
            let annotation = MKPointAnnotation()
            annotation.coordinate = source
            mapView.addAnnotation(annotation)
            
            context.coordinator.addRoute(from: source, to: destination, on: mapView)
        }
        
        let allCoordinates = sources + [destination]
        var zoomRect = MKMapRect.null
        
        for coordinate in allCoordinates {
            let point = MKMapPoint(coordinate)
            let rect = MKMapRect(origin: point, size: MKMapSize(width: 0.1, height: 0.1))
            zoomRect = zoomRect.union(rect)
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40), animated: false)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(destination: destination)
    }
}

struct RouteContentView: View {
    let sampleEvents: [EventLocation] = [
        EventLocation(title: "Tech Talk @ TIDEL Park", latitude: 13.0213, longitude: 80.2240, address: "", description: ""),
        EventLocation(title: "Open Mic Night", latitude: 13.0475, longitude: 80.2610, address: "", description: ""),
        EventLocation(title: "Startup Pitch Day", latitude: 13.0358, longitude: 80.2446, address: "", description: ""),
        EventLocation(title: "Cultural Fest", latitude: 13.0085, longitude: 80.2340, address: "", description: "")
    ]

    let destination = CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.2824)

    var body: some View {
        SourceToDestinationRouteView(
            sources: sampleEvents.map { $0.coordinate },
            destination: destination
        )
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    RouteContentView()
}
