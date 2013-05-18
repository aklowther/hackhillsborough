//
//  TripsMapViewController.m
//  BusStop
//
//  Created by Robert Ries on 4/14/13.
//  Copyright (c) 2013 0xC0ffee. All rights reserved.
//

#import "TripsMapViewController.h"

@interface TripsMapViewController ()

@end

@implementation TripsMapViewController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    mapView.delegate = self;
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 27.977727;
    zoomLocation.longitude = -82.454109;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation,
                                                                       10*METERS_PER_MILE,
                                                                       10.*METERS_PER_MILE);
    [mapView setRegion:viewRegion animated:YES];
    
    TripData *tripData = [[TripData alloc] init];
    [tripData setDelegate:self];
    
    dispatch_queue_t getAnnotations = dispatch_queue_create("com.awesomeness.I.am", DISPATCH_QUEUE_SERIAL);
    dispatch_async(getAnnotations, ^{
        NSArray *busAnnotations = [tripData busAnnotationsForRoute:@"Hillsborough Area Regional Transit_6"];
        NSLog(@"about to add annotations to map");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [mapView addAnnotations:busAnnotations];
//        });
        NSLog(@"Done did get busItemsArray");
    });
    dispatch_release(getAnnotations);
}

-(BOOL)addAnnotationToMap:(BusAnnotation *)annotation
{
    NSLog(@"TEST");
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView addAnnotation:annotation];
    });
    return true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

// way too buggy
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    NSLog(@"called viewForAnnotation");
    
    BusAnnotationView *annotationView = (BusAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    NSLog(@"annotationView: %@", annotationView);
    if (annotationView == nil)
    {
        NSLog(@"Brand new annotation!");
        if([annotation isKindOfClass:[BusAnnotation class]]){
            annotationView = [[BusAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.canShowCallout = YES;
            annotationView.opaque = NO;
        }
        else {
            NSLog(@"Annotation that is not a bus pin");
            // does this even work?
            AnnotationViewID = @"GenericPinViewID";
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//            return nil;
        }
        NSLog(@"Allocated space for the new annotation!");
    }
    
    annotationView.annotation = annotation;
    
    NSLog(@"Done with the annotations!");
    
    return annotationView;
}


@end