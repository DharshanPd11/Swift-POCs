//
//  MapContentView.swift
//  Swift POCs
//
//  Created by Priyadharshan Raja on 27/07/25.
//

import SwiftUI
import MapKit

struct MapContentView: View {
    let sampleEvents: [EventLocation] = [
        EventLocation(
            title: "Marina Beach Meetup",
            latitude: 13.0500,
            longitude: 80.2824,
            address: "Marina Beach, Chennai",
            description: "A casual meetup near the beach."
        ),
        EventLocation(
            title: "Tech Talk @ TIDEL Park",
            latitude: 13.0213,
            longitude: 80.2240,
            address: "TIDEL Park, Chennai",
            description: "Join the latest tech innovations discussion."
        ),
        EventLocation(
            title: "Open Mic Night",
            latitude: 13.0475,
            longitude: 80.2610,
            address: "Besant Nagar, Chennai",
            description: "Share poetry, music, or comedy."
        ),
        EventLocation(
            title: "Startup Pitch Day",
            latitude: 13.0358,
            longitude: 80.2446,
            address: "Guindy, Chennai",
            description: "Pitch your ideas to VCs and founders."
        ),
        EventLocation(
            title: "Cultural Fest",
            latitude: 13.0085,
            longitude: 80.2340,
            address: "Adyar, Chennai",
            description: "A festival with music, food and fun!"
        )
    ]
    
    var body: some View {
        Map {
            ForEach(sampleEvents) { location in
                Annotation(location.title, coordinate: location.coordinate) {
                    HStack{
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width:60, height: 60)
                            .clipShape(.circle)
                    }
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 5)
//                            .fill(.ultraThickMaterial)
//                        Text(location.description)
//                            .padding(5)
//                    }
                }
            }
        }
        .mapControlVisibility(.visible)
    }
}

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

#Preview {
    MapContentView()
}


struct EventLocation: Identifiable {
    let id = UUID()
    let title: String
    let latitude: Double
    let longitude: Double
    let address: String
    let description: String
    
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, latitude: Double, longitude: Double, address: String, description: String) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.description = description
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
