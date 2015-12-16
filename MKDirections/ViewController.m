//
//  ViewController.m
//  MKDirections
//
//  Created by Neeraj Mishra on 8/5/15.
//  Copyright (c) 2015 Neeraj Mishra. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableArray *array_points;
    NSMutableArray *test_points;
    CLLocation* referancelocation;
     NSMutableArray *arr_places;
}
@end
@implementation ViewController

CLPlacemark *thePlacemark;
MKRoute *routeDetails;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    NSLog(@"%@",self.mapView.userLocation.location);
    
    array_points = [[NSMutableArray alloc]init];
    test_points = [[NSMutableArray alloc]init];
    arr_places =[[NSMutableArray alloc]init];

}


-(void)distancebetween:(CLLocation *)currentLocation
{
    if (referancelocation == nil) {
        referancelocation = currentLocation;
        [array_points addObject:referancelocation];

    }
    
    else if ([referancelocation distanceFromLocation:currentLocation]>100)
    {

        [array_points addObject:currentLocation];
        referancelocation = currentLocation;
   
    }
  }


- (IBAction)routeButtonPressed:(UIBarButtonItem *)sender
{
      MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(38.8977, -77.0365);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoords addressDictionary:nil];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [self addAnnotation:destinationPlacemark];
    CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(38.902021, -77.024353);
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    [self addAnnotation:sourcePlacemark];

    // Set the source and destination on the request
    [directionsRequest setSource:source];
    [directionsRequest setDestination:destination];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         }
         else
         {
             //[self showRoute:response];
             for (MKRoute *route in response.routes)
             {
                 [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
              }
             MKRoute *routenew = response.routes.lastObject;
             for (NSUInteger i = 0; i < routenew.polyline.pointCount; i++) {
                                MKMapPoint point = routenew.polyline.points[i];
                 [self createAndAddAnnotationForCoordinate:MKCoordinateForMapPoint(point)];
               }
         }
         
         NSLog(@" test points--------->%lu",(unsigned long)test_points.count);
         NSLog(@" array points--------->%lu",(unsigned long)array_points.count);
         
         [self googleplaces];
         [self dropPin];
         
     }];
}


-(void)dropPin
{
    for (Modal * obj in arr_places) {
        
        float lat_places = [[obj lat] floatValue];
        float lng_places = [[obj lang] floatValue];

        
        CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(lat_places, lng_places);
        MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
        [self addAnnotation:sourcePlacemark];
    }
}


-(void)googleplaces
{
    for (int i = 0;i<array_points.count; i++) {
        
        CLLocation *searchlocation = [array_points objectAtIndex:i];
        lat = searchlocation.coordinate.latitude;
        lang = searchlocation.coordinate.longitude;
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=100&sensor=true&key=%@",lat,lang,GOOGLE_API_KEY];
        NSURL *googleRequestURL=[NSURL URLWithString:url];
       //  NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        NSMutableURLRequest *request =[[NSMutableURLRequest alloc]initWithURL:googleRequestURL];
        
        
        request.HTTPMethod = @"GET";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * dataString = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
        [self fetchedData:dataString];


    }
    
    }


- (void)fetchedData:(NSData *)responseData {
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    for (NSDictionary * dict in places) {
        Modal *obj = [Modal instanceofclass:dict];
        [arr_places addObject:obj];
    }
    
}


- (void)showRoute:(MKDirectionsResponse *)response {
    [self.mapView removeOverlays:self.mapView.overlays];
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.alpha = 0.7;
    renderer.lineWidth = 4.0;
    
    return renderer;
}

-(void) createAndAddAnnotationForCoordinate : (CLLocationCoordinate2D) coordinate1{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate1.latitude longitude:coordinate1.longitude];
    [test_points addObject:location];
    [self distancebetween:location];
 }

- (IBAction)clearRoute:(UIBarButtonItem *)sender {
    self.destinationLabel.text = nil;
    self.distanceLabel.text = nil;
    self.transportLabel.text = nil;
    self.steps.text = nil;
    [self.mapView removeOverlay:routeDetails.polyline];
}

- (IBAction)addressSearch:(UITextField *)sender {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:sender.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            thePlacemark = [placemarks lastObject];
            float spanX = 1.00725;
            float spanY = 1.00725;
            MKCoordinateRegion region;
            region.center.latitude = thePlacemark.location.coordinate.latitude;
            region.center.longitude = thePlacemark.location.coordinate.longitude;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            [self.mapView setRegion:region animated:YES];
            [self addAnnotation:thePlacemark];
        }
    }];
}

- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    
    [self.mapView addAnnotation:point];
}

//-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
//    routeLineRenderer.strokeColor = [UIColor redColor];
//    routeLineRenderer.lineWidth = 5;
//    return routeLineRenderer;
//}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
