//
//  Canvas.m
//  ios-study-MapKit
//
//  Created by Shimoda Shinichiro on 2014/02/02.
//  Copyright (c) 2014年 Shimoda Shinichiro. All rights reserved.
//

#import "Canvas.h"

@implementation Canvas

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // タッチイベントを有効にする
        self.userInteractionEnabled = YES;
        
        // マルチタッチは無効にする
        [self setMultipleTouchEnabled:NO];
        
        // touchPointsを初期化
        self.touchPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIResponder methods overwrite

// タッチされたとき
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // タッチ開始座標をインスタンス変数startPointに保持
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self];
    self.touchPoint = self.startPoint;
    
    // タッチ開始座標をインスタンス変数touchPointsに保持
    [self.touchPoints addObject:[NSValue valueWithCGPoint:self.startPoint]];
}

// タッチが離れたとき
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 現在のタッチ座標をendPointに保持
    UITouch *touch = [touches anyObject];
    self.endPoint = [touch locationInView:self];
    
    [self draw:self.startPoint toPoint:self.endPoint];
    
    NSLog(@"The number of Saved CGPoints are %lu", (unsigned long)[self.touchPoints count]);
    
    // デリゲートメソッドの読み出し
    if ([self.delegate respondsToSelector:@selector(finishDrawing)]) {
        [self.delegate finishDrawing];
    }
}

// タッチが移動中の場合
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    [self draw:self.touchPoint toPoint:currentPoint];
    
    // 現在のタッチ座標を次の開始座標にセット
    self.touchPoint = currentPoint;
    
    // タッチ開始座標をインスタンス変数touchPointsに保持
    [self.touchPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
}

- (void)draw:(CGPoint)from toPoint:(CGPoint)to
{
    // 描画領域を作成（アプリ上に表示はされない）
    UIGraphicsBeginImageContext(self.frame.size);
    
    // 現在表示されている画像を先ほど作った描画領域(UIGraphicsGetCurrentContext)に描画
    // これがないと前に描画した線が消える
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    // 線の角を丸くする
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    // 線の太さを指定
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0);
    
    // 線の色を指定（RGB）
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    
    // 線の描画開始座標をセット
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), from.x, from.y);
    
    // 線の描画終了座標をセット
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), to.x, to.y);
    
    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    // 描画領域を画像（UIImage）としてcanvasにセット
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画領域のクリア
    UIGraphicsEndImageContext();
}

@end
