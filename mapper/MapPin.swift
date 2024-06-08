//
//  MapPin.swift
//  mapper
//
//  Created by Robert Dodson on 9/11/23.
//
import Foundation
import MapKit


class MapPin : NSObject, MKAnnotation
{
    var coordinate : CLLocationCoordinate2D
    var title : String?
    var subtitle : String?
    var color : NSColor?
    var reuseID : String?
    var symbol : String? // SFSymbol
    var accessibilityDescription : String?
    
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String,color:NSColor,reuseID:String,symbol:String,accessibilityDescription:String)
    {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.reuseID = reuseID
        self.symbol = symbol
        self.accessibilityDescription = accessibilityDescription
    }
}
