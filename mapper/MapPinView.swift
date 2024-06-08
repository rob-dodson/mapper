//
//  MapPinView.swift
//  mapper
//
//  Created by Robert Dodson on 9/11/23.
//
import Foundation
import MapKit


class MapPinView : MKAnnotationView
{
    required init?(coder aDecoder: NSCoder)
    {
        return nil
    }
    
    
    init(mappin: MapPin)
    {
        super.init(annotation:mappin , reuseIdentifier: mappin.reuseID)
        
        if let image = NSImage(systemSymbolName: mappin.symbol!, accessibilityDescription:mappin.accessibilityDescription)
        {
            var config = NSImage.SymbolConfiguration(textStyle: .body,scale:.small)
            config = config.applying(.init(paletteColors: [mappin.color!,NSColor.gray]))
            self.image = image.withSymbolConfiguration(config)
        }
    }
}
