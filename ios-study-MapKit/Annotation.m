//  Annotation.m
//  ios-study-MapKit
//
//  Created by Shimoda Shinichiro on 2014/02/02.
//  Copyright (c) 2014年 Shimoda Shinichiro. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

- (id)initWithLocationCoordinate:(CLLocationCoordinate2D) coordinate
                           title:(NSString *)title
                        subtitle:(NSString *)subtitle {
    _coordinate = coordinate;
    _title      = title;
    _subtitle   = subtitle;
    return self;
}

@end
