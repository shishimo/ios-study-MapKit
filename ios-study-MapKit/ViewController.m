//
//  ViewController.m
//  ios-study-MapKit
//
//  Created by Shimoda Shinichiro on 2014/02/02.
//  Copyright (c) 2014年 Shimoda Shinichiro. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 画面全体に表示。コードで書く場合は下記
    // MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    // [self.view addSubview:mapView];
    
    // MKMapViewDelegateのデリゲート先を設定
    self.mapView.delegate = self;
    
    // ユーザの現在位置を表示
    self.mapView.showsUserLocation = NO;
    
    // 地図の種類をハイブリッドにする
    self.mapView.mapType = MKMapTypeStandard;  //標準
    //mapView.mapType = MKMapTypeSatellite; //航空写真
    //mapView.mapType = MKMapTypeHybrid;    //標準＋航空写真
    
    // デバイスの向きに合わせて地図を回転
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    
    // 表示位置を設定（東京都庁）
    CLLocationCoordinate2D co;
    co.latitude  = 35.68664111; // 経度
    co.longitude = 139.6948839; // 緯度
    [self.mapView setCenterCoordinate:co animated:YES];
    
    // 縮尺を指定
    MKCoordinateRegion cr = self.mapView.region;
    cr.center = co;
    cr.span.latitudeDelta = 0.05;
    cr.span.longitudeDelta = 0.05;
    [self.mapView setRegion:cr animated:NO];
    
    // スクロールを固定しない
    self.mapView.scrollEnabled = YES;
    
    // ズームを固定しない
    self.mapView.zoomEnabled = YES;
    
    // 非描画中設定
    self.onDraw = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate methods

// 地図データが読み込まれる直前に呼び出される
-(void)mapViewWillStartLoadingMap: (MKMapView *)mapView
{
    NSLog(@"これから地図データを読み込みます。");
}

// 地図データが読み込まれた直後に呼び出される
-(void)mapViewDidFinishLoadingMap: (MKMapView *)mapView
{
    NSLog(@"これから地図データを読み込みました。");
}

// iOS7から
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        // MKPolylineのレンダリング時ならば
        MKPolyline *line = overlay;
        MKPolylineRenderer *lineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:line];
        lineRenderer.lineWidth = 2.0;
        lineRenderer.strokeColor = [UIColor blueColor];
        return lineRenderer;
    } else if ([overlay isKindOfClass:[MKPolygon class]]) {
        // MKPolygonのレンダリング時ならば
        MKPolygon *polygon = overlay;
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
        polygonRenderer.fillColor = [UIColor blueColor];
        polygonRenderer.alpha = 0.1;
        return polygonRenderer;
    } else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircle *circle = overlay;
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:circle];
        circleRenderer.fillColor = [UIColor blueColor];
        circleRenderer.lineWidth = 1.0;
        circleRenderer.strokeColor = [UIColor blueColor];
        circleRenderer.alpha = 0.05;
        return circleRenderer;
    } else {
        return nil;
    }
}

// iOS7 からdeplicate
/*
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
 {
 if ([overlay isKindOfClass:[MKPolyline class]]) {
 // MKPolylineのレンダリング時ならば
 MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
 view.strokeColor = [UIColor blueColor];
 view.lineWidth = 5.0;
 return view;
 } else if ([overlay isKindOfClass:[MKPolygon class]]) {
 // MKPolygonのレンダリング時ならば
 MKPolygonView *view = [[MKPolygonView alloc] initWithOverlay:overlay];
 view.fillColor = [UIColor blueColor];
 view.alpha = 0.1;
 return view;
 } else {
 return nil;
 }
 }
*/

#pragma mark - CanvasDelegate methods

- (void)finishDrawing
{
    CGPoint points[self.canvasView.touchPoints.count];
    CLLocationCoordinate2D coors[self.canvasView.touchPoints.count];
    
    int i=0;
    for (NSValue* value in self.canvasView.touchPoints) {
        points[i] = [value CGPointValue];
        coors[i]  = [self.mapView convertPoint:points[i] toCoordinateFromView:self.canvasView];
        i++;
    }
    coors[i++]  = [self.mapView convertPoint:points[0] toCoordinateFromView:self.canvasView];
    
    // 線で表示
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coors count:i];
    [self.mapView addOverlay:line];
    
    // 領域で表示
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coors count:i];
    [self.mapView addOverlay:polygon];
    
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled   = YES;
    [self.drawButton setTitle:@"絵を描く" forState:UIControlStateNormal];
    self.onDraw = NO;
    
    // 描画領域を削除
    [self.canvasView removeFromSuperview];
    self.canvasView = nil;
}



#pragma mark - ViewController IBAction methods

- (IBAction)pushDrawButton:(id)sender
{
    if (self.onDraw) {
        self.mapView.scrollEnabled = YES;
        self.mapView.zoomEnabled   = YES;
        [self.drawButton setTitle:@"絵を描く" forState:UIControlStateNormal];
        self.onDraw = NO;

        // 描画領域を削除
        [self.canvasView removeFromSuperview];
        self.canvasView = nil;
    } else {
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled   = NO;
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.drawButton setTitle:@"描画中" forState:UIControlStateNormal];
        self.onDraw = YES;

        // 描画領域を作成
        self.canvasView = [[Canvas alloc] initWithFrame:self.mapView.bounds];
        self.canvasView.delegate = self;
        [self.canvasView setBackgroundColor:[UIColor lightGrayColor]];
        [self.canvasView setAlpha:0.5];
        [self.view addSubview:self.canvasView];
    }
}

- (IBAction)pushRouteButton:(id)sender
{
    // 東京都庁から渋谷までの経路を表示する

    // まず出発点と到着点を CLLocationCoordinate2D で作成します。
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(35.68664111, 139.6948839); // 東京都庁
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(35.658987, 139.702776);   // 渋谷

    // CLLocationCoordinate2D から MKPlacemark を生成
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate addressDictionary:nil];

    // MKPlacemark から MKMapItem を生成
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];

    // MKMapItem をセットして MKDirectionsRequest を生成
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = fromItem;
    request.destination = toItem;
    request.requestsAlternateRoutes = YES;

    // MKDirectionsRequest から MKDirections を生成
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    // 経路検索を実行
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error) return;

         if ([response.routes count] > 0)
         {
             MKRoute *route = [response.routes objectAtIndex:0];
             MKPolyline* line = route.polyline;

             // 地図上にルートを描画
             [self.mapView addOverlay:line];

             CLLocationCoordinate2D coors[line.pointCount];
             NSRange range = NSMakeRange(0, line.pointCount);

             [line getCoordinates:coors range:range];

             for (int i=0; i<line.pointCount; ++i) {
                 /*
                 Annotation *annotation =
                 [[Annotation alloc] initWithLocationCoordinate:coors[i]
                                                          title:[NSString stringWithFormat:@"%d番目", i]
                                                       subtitle:@""];
                 [self.mapView addAnnotation:annotation];
                 */

                 MKCircle *circle = [MKCircle circleWithCenterCoordinate:coors[i] radius:500];
                 [self.mapView addOverlay:circle];
             }

             /*
             // ルートの中心点にフラグを立てる
             Annotation *annotation =
                 [[Annotation alloc] initWithLocationCoordinate:route.polyline.coordinate
                                                          title:route.name
                                                       subtitle:[NSString stringWithFormat:@"%.2f", route.distance]];
             [self.mapView addAnnotation:annotation];

             // 各ルートの最後にフラグを立てる
             NSArray *steps = route.steps;
             for (MKRouteStep *step in steps) {
                 Annotation *annotation =
                 [[Annotation alloc] initWithLocationCoordinate:step.polyline.coordinate
                                                          title:step.instructions
                                                          subtitle:@""];
                 [self.mapView addAnnotation:annotation];
             }
             */
         }
     }];
}
@end
