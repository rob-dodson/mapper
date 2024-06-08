//
//  AppDelegate.swift
//  mapper
//
//  Created by Robert Dodson on 9/9/23.
//
import Foundation
import Cocoa
import MapKit
import GPX


@main
class AppDelegate: NSObject, NSApplicationDelegate,MKMapViewDelegate 
{
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var mapper: MKMapView!
    
    
    //
    // Render a track
    //
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        return overlayrenderer(polyline: overlay as! MKPolyline)
    }
    
    
    //
    // Render a pin
    //
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        return MapPinView(mappin: annotation as! MapPin)
    }
    
    
    //
    // App did finish launching
    //
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        mapper.showsScale = true
        mapper.showsPitchControl = true
        mapper.showsUserLocation = true
        
        //
        // read in a gpx file and parse it.
        //
        if let urlPath = Bundle.main.url(forResource: "SRBD_anticlockwise_start_corvara_alta_badia", withExtension: "gpx")
        {
            let parser = GPXParser(urlPath);
            
            Task
            {
                if let rootElement = try? await parser.parse()
                {
                    let root = GPXRoot(withXMLElement: rootElement)
                    
                    for track in root.tracks 
                    {
                        print("Track: \(String(describing: track.name))")
                        
                        for tracksegment in track.tracksegments
                        {
                            var linepoints = [MKMapPoint]()
                            
                            var count = 0
                            let max = tracksegment.locations().count - 1
                            for location in tracksegment.locations()
                            {
                                var mappin : MapPin?
                                
                                let loc2d = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                if count == 0
                                {
                                    mappin = MapPin(coordinate:loc2d , title: "trailstart", subtitle: "trailstart",color:NSColor.green,reuseID: "TRAILSTART", symbol: "flag.fill", accessibilityDescription: "trail start")
                                }
                                else if count == max
                                {
                                    mappin = MapPin(coordinate:loc2d , title: "trailend", subtitle: "trailend",color: NSColor.red,reuseID: "TRAILEND", symbol: "flag.checkered", accessibilityDescription: "trail end")
                                }
                                else
                                {
                                    mappin = MapPin(coordinate:loc2d , title: "point", subtitle: "point",color:NSColor.white, reuseID: "PIN", symbol: "circle", accessibilityDescription: "trail point")
                                }
                                mapper.addAnnotation(mappin!)
                                
                                linepoints.append(MKMapPoint(loc2d))
                                
                                count = count + 1
                            }
                            
                            let polyline = MKPolyline(points: linepoints, count: linepoints.count)
                            mapper.addOverlay(polyline, level: .aboveLabels)
                        }
                    }
                }
            }
        }
        
        mapper.delegate = self
        
       // let mappin = MapPin(coordinate:CLLocationCoordinate2D(latitude: 47.2529, longitude: -122.444438) , title: "Tacoma", subtitle: "home",color: NSColor.orange)
       // mapper.addAnnotation(mappin)
    }
    

    func applicationWillTerminate(_ aNotification: Notification) 
    {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool 
    {
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "mapper")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    func save() {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

