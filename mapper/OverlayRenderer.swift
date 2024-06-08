//
//  OverlayRenderer.swift
//  mapper
//
//  Created by Robert Dodson on 9/11/23.
//
import Foundation
import MapKit


class overlayrenderer : MKOverlayRenderer
{
    var polyline : MKPolyline
    
    init(polyline: MKPolyline)
    {
        self.polyline = polyline
        super.init(overlay: polyline)
    }
    
    
    override func draw(_ mapRect: MKMapRect,zoomScale: MKZoomScale,in context: CGContext)
    {
        context.beginPath()
        
        var count = 0
        for mappoint in UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount)
        {
            let point = self.point(for: mappoint)
            if count == 0
            {
                context.move(to: point)
            }
            else
            {
                context.addLine(to: point)
            }
            
            count = count + 1
        }
        
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setStrokeColor(CGColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 0.8))
        context.setLineWidth(min(500,40 * (0.5 / zoomScale)))
        context.strokePath()
    }
}
