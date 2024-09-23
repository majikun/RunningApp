//
//  MapView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)  // 清除之前的轨迹

        guard !coordinates.isEmpty else { return }

        // 创建一个 MKPolyline 并添加到地图
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        // 自动缩放地图区域以适应轨迹
        if let firstCoordinate = coordinates.first {
            let region = MKCoordinateRegion(center: firstCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
