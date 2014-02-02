//
//  Annotation.h
//  ios-study-MapKit
//
//  Created by Shimoda Shinichiro on 2014/02/02.
//  Copyright (c) 2014年 Shimoda Shinichiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) coordinate
                           title:(NSString *)title
                        subtitle:(NSString *)subtitle;

@end
