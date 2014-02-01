//
//  Canvas.h
//  ios-study-MapKit
//
//  Created by Shimoda Shinichiro on 2014/02/02.
//  Copyright (c) 2014年 Shimoda Shinichiro. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CanvasDelegate <NSObject>

- (void)finishDrawing;

@end

@interface Canvas : UIImageView

@property id<CanvasDelegate> delegate;
@property CGPoint startPoint;
@property CGPoint touchPoint;
@property CGPoint endPoint;
@property NSMutableArray *touchPoints;

@end
