//
//  LiveLocation.swift
//  Swift POCs
//
//  Created by Priyadharshan Raja on 03/08/25.
//

import MapKit
import SwiftUI


struct LiveLocationMapView: View {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.0358, longitude: 80.2446),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var people: [PersonLocation] = [
        PersonLocation(id: UUID(), name: "Alice", coordinate: CLLocationCoordinate2D(latitude: 13.0358, longitude: 80.2446)),
        PersonLocation(id: UUID(), name: "Bob", coordinate: CLLocationCoordinate2D(latitude: 13.0475, longitude: 80.2610))
    ]

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: people) { person in
            MapAnnotation(coordinate: person.coordinate) {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text(person.name)
                        .font(.caption)
                        .background(Color.white.opacity(0.8))
                }
            }
        }
        .onAppear {
//            simulateLocationUpdates()
            simulateLiveLocation(from: people[0].coordinate, to: CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.2824))
        }
    }
    
    // Simulate live location update (replace with real-time update using location manager or server data)
    func simulateLocationUpdates() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation {
                people[0].coordinate.latitude += 0.0005
                people[1].coordinate.longitude += 0.0005
            }
        }
    }
    
    func simulateLiveLocation(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) {
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            
            // This is your polyline for the route
            let polyline = route.polyline
            
            // Get coordinates from it
            let coordinates = polyline.coordinates()
            
            // Now you can use `coordinates` to simulate movement
            print("Polyline coordinates count: \(coordinates.count)")
            
            var currentStep = 0

            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                guard currentStep < coordinates.count else {
                    timer.invalidate()
                    return
                }
                
                people[0].coordinate = coordinates[currentStep]
                
                currentStep += 1
            }

        }

    }
}

struct PersonLocation: Identifiable {
    let id: UUID
    let name: String
    var coordinate: CLLocationCoordinate2D
}

#Preview{
    LiveLocationMapView()
}
