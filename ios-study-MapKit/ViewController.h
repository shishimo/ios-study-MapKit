//
//  ViewController.h
//  ios-study-MapKit
//
//  Created by Shimoda Shinichiro on 2014/02/02.
//  Copyright (c) 2014年 Shimoda Shinichiro. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "Canvas.h"
#import "Annotation.h"

@interface ViewController : UIViewController<MKMapViewDelegate, CanvasDelegate>

@property BOOL onDraw;
@property Canvas *canvasView;
@property (weak, nonatomic) IBOutlet UIButton *drawButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)pushDrawButton:(id)sender;
- (IBAction)pushRouteButton:(id)sender;

@end
