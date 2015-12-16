//
//  ViewController.h
//  MKDirections
//
//  Created by Neeraj Mishra on 8/5/15.
//  Copyright (c) 2015 Neeraj Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Modal.h"
#define GOOGLE_API_KEY @"AIzaSyBWXHQYCpgIhPhfy2j0je-VJzkqNIUO5cM"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ViewController : UIViewController <MKMapViewDelegate>
{
@public
    float lat;
@public
    float lang;
    
@public
    int viewStatus;
    
    AppDelegate *appdelegate;

}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *transportLabel;
@property (weak, nonatomic) IBOutlet UITextView *steps;

@property (strong, nonatomic) NSString *allSteps;

@end
