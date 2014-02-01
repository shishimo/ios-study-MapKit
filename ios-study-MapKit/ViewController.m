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
@end
