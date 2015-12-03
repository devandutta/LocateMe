//****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

//
//  ViewController.swift
//  LocateMe
//
//  Created by Devan Dutta on 11/26/15.
//  Copyright © 2015 devan.dutta. All rights reserved.
//

import UIKit

//Import CoreLocation so that the app can make use of CoreLocation Framework
//Don't forget to link the CoreLocation framework in Build Phases
import CoreLocation

//Import MapKit so that the app can make use of MapKit Framework
//Don't forget to link the CoreLocation framework in Build Phases
import MapKit

//Inherit from CLLocationManagerDelegate so that the app can get location information from the location manager
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //*****************************Property declarations***************************
    
    //locationManager will hold the reference to the CLLocationManager object
    private let locationManager = CLLocationManager()
    
    /*
    previousPoint will hold the location of the last update from location manager
    
    Note the question mark after CLLocation.  This question mark indicates what Swift calls an "optional value"
    
    The idea is that previousPoint may be "nil" or it may have a value
    
    So, if we ever use "if let" with previousPoint, we need to designate the possibility of "nil" value
    
    If previousPoint is "nil" and used in an "if condition", that code block is skipped
    
    Otherwise, we use the value of previousPoint and the value of previousPoint will be assigned to the constant
    after let
    */
    
    private var previousPoint:CLLocation?
    
    //When the user moves far enough from previousPoint, the movement distance will be added to totalMovementDistance
    private var totalMovementDistance:CLLocationDistance=0
    
    //*****************************IBOutlet Declarations***************************
    
    //Note that all the IBOutlets have "!" after "UILabel".  The "!" indicates that the outlet is "an implicitly unwrapped
    //optional.  This means that Storyboard can connect the outlets at runtime, after initialization"
    
    //From Apple Documentation, "Do not use an implicitly unwrapped optional when there is a possibility of a variable becoming nil at a later point. Always use a normal optional type if you need to check for a nil value during the lifetime of a variable.
    //More info: https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/WritingSwiftClassesWithObjective-CBehavior.html#//apple_ref/doc/uid/TP40014216-CH5-ID86
    
    //https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-ID309
    
    
    @IBOutlet var latitudeLabel:UILabel!
    @IBOutlet var longitudeLabel:UILabel!
    @IBOutlet var horizontalAccuracyLabel:UILabel!
    @IBOutlet var altitudeLabel:UILabel!
    @IBOutlet var verticalAccuracy:UILabel!
    @IBOutlet var distanceTraveledLabel:UILabel!
    @IBOutlet var speedLabel:UILabel!
    @IBOutlet var mapView:MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate=self  //Make the controller class the location manager's delegate
        
        /*
        Initially, the desired accuracy was set to kCLLocationAccuracyBest, however upon testing the app on my phone,
        I found that the best accuracy would drain the iPhone battery quickly
        
        Source for Accuracy constants: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CoreLocationConstantsRef/index.html#//apple_ref/doc/constant_group/Accuracy_Constants
        */
        
        locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters
        
        locationManager.requestWhenInUseAuthorization()  //Request that the app get location data while it is currently open
        //Note that the app will ask if it can use location services the first time it opens with this method,
        //not when it actually needs to start using location data
        
        //Apple recommends instead that you ask for location services when it's actually necessary because users would be more
        //likely to accept if they could see by context exactly why the app wants to use location services (for example, if
        //the user taps a "Get Directions" button and then the app asks if it can use Location Services, that is better than
        //simply asking the moment the app is opened)
        
        //For the purpose of this app, it is okay to ask at the beginning since everything is location-oriented
        
        //Note: the requestAlwaysAuthorization() is a much more advanced method
        
        //Note: As of iOS 8, you must supply a supporting description to a key that requests permission to do something
        //In the Info.plist file, I have added the following key and string:
        
        /*
        Key: NSLocationWhenInUseUsageDescription
        Value: Need Location Services to locate and report location values
        */
        
        //If you needed to access location even when the app is not running in the foreground, you must first use
        //the requestAlwaysAuthorization() method and the key that you must add to the Info.plist file is:
        
        // NSLocationAlwaysUsageDescription
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function will start listening for location changes only if authorization is granted, otherwise, it will stop
    //listening for location changes
    
    //This function is in the CLLocationManagerDelegate Protocol
    //Source: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManagerDelegate_Protocol/index.html#//apple_ref/occ/intfm/CLLocationManagerDelegate/locationManager:didChangeAuthorizationStatus:
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("Authorization status changed to \(status.rawValue)")
        switch status {
        case .Authorized, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation=true
            
        default:
            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation=false
        }
    }
    
    //This function will produce an error message if location data is unavailable due to an error
    
    //This function is in the CLLocationManagerDelegate Protocol
    //Source: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManagerDelegate_Protocol/index.html#//apple_ref/occ/intfm/CLLocationManagerDelegate/locationManager:didFailWithError:
    
    //In an application with objects and such, you need to not only produce an error message, but you also need to clean up
    //application state
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let errorType = error.code == CLError.Denied.rawValue ? "Access Denied": "Error \(error.code)"
        let alertController = UIAlertController(title: "Location Manager Error", message: errorType, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: { action in } )
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //This function will display information to the text fields
    
    //This function is in the CLLocationManagerDelegate Protocol
    //Source: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManagerDelegate_Protocol/index.html#//apple_ref/occ/intfm/CLLocationManagerDelegate/locationManager:didUpdateLocations:
    
    //This function lets the delegate know that new location data is available
    //Note: the paramater "locations" is an array of CLLocation objects that has location data, where at least one object
    //holds the current location
    //The array can have additional entries if location updates were deferred or came in before they could be delivered to the
    //manager
    //Objects are arranged chronologically, so most recent location update is at end of array
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //The array could have more than one location update, so use the last one since that one will be the most recent item
        let newLocation = (locations as [CLLocation])[locations.count-1]
        
        //Note: "\u{00B0}" is the hexadecimal representation of the Unicode degree symbol
        //"%g" indicates double with specific formatting requirement for exponents
        let latitudeString = String(format:"%g\u{00B0}", newLocation.coordinate.latitude)
        latitudeLabel.text = latitudeString
        
        let longitudeString = String(format:"%g\u{00B0}", newLocation.coordinate.longitude)
        longitudeLabel.text = longitudeString
        
        let horizontalAccuracyString = String(format:"%gm", newLocation.horizontalAccuracy)
        horizontalAccuracyLabel.text = horizontalAccuracyString
        
        let altitudeString = String(format:"%gm", newLocation.altitude)
        altitudeLabel.text = altitudeString
        
        let verticalAccuracyString = String(format:"%gm", newLocation.verticalAccuracy)
        verticalAccuracy.text = verticalAccuracyString
        
        if newLocation.horizontalAccuracy < 0 {
            return //A negative value indicates that the horizontal accuracy is invalid
        }
        
        //The higher the accuracy number, the less accurate the location manager believes it is
        //Accuracy values are in meters
        //The location manager places you in the center of a circle with a radial length = accuracy value
        //The bigger the radius, the bigger the circle and the less accurate the location manager thinks it is
        if newLocation.horizontalAccuracy > 100 || newLocation.horizontalAccuracy > 50 {
            return //Accuracy radius is too large so it won't be practical to use
        }
        
        if previousPoint == nil {
            totalMovementDistance = 0
            
            //Add Place object, give it parameters, and add it to the map
            let start = Place(title: "Starting Point", subtitle: "Where we began the trip", coordinate: newLocation.coordinate)
            mapView.addAnnotation(start)
            
            //A region lets us define how much of the map we want to show
            //Here, we state that we want the center to be newLocation 
            //and the latitudinal and longitudinal distances to both be 100 meters
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100)
            mapView.setRegion(region, animated: true)
        } else {
            
            //Log the movement distance and the speed to the console
            print("movement distance: " + String(format:"%f meters", newLocation.distanceFromLocation(previousPoint!)))
            print("speed: " + String(format:"%f meters/s", newLocation.speed))
            
            //Alternate logging method that can be used, but with lower and no units by default:
            
            //print("movement distance: " + "\(newLocation.distanceFromLocation(previousPoint!))") //will print distance with one tenth precision and with no units
            //print("speed: " + "\(newLocation.speed)") //will print speed with one tenth precision and with no units
            
            totalMovementDistance += newLocation.distanceFromLocation(previousPoint!)
        }
        
        previousPoint = newLocation
        
        let distanceString = String(format:"%gm", totalMovementDistance)
        distanceTraveledLabel.text = distanceString
        
        let speedString = String(format:"%fm/s", newLocation.speed)
        
        speedLabel.text=speedString
        
        /* ******************************************************************************************************************
        An alternate implementation of speed that seems to yield nan (not a number) for speed (I'm currently debugging it):

        To calculate the speed, I will take the distance from the newLocation to the previousPoint
        Then I will divide that distance by the time interval between the newLocation timestamp and the previousPoint timestamp
        This equation is: speed = distance/time
        
        
        NOTE: distanceFromLocation works as follows: 
        "Returns the distance (in meters) from the receiver’s location to the specified location...by tracing a line between them that follows the curvature of the Earth. The resulting arc is a smooth curve and does not take into account specific altitude changes between the two locations."
        Source: https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocation_Class/#//apple_ref/doc/uid/TP40007126-CH3-SW17


        let distance = newLocation.distanceFromLocation(previousPoint!) //In meters
        let timeDifference = newLocation.timestamp.timeIntervalSinceDate((previousPoint?.timestamp)!) //In seconds
        
        let calculatedSpeed = distance/timeDifference
        let speedString = String(format:"%fm/s", calculatedSpeed)
        
        speedLabel.text=speedString
        */
    }
}

