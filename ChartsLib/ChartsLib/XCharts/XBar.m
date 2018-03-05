//
//  Bar.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/5/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XBar.h"

@interface XBar()

/** bar layer */
@property (nonatomic,weak) CAShapeLayer *barLayer;

@end

@implementation XBar

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer *barLayer = [CAShapeLayer layer];
        barLayer.cornerRadius = 3;
        barLayer.strokeEnd = 0.0f;
        barLayer.lineWidth = frame.size.width;
        barLayer.lineCap = kCALineCapButt;
        barLayer.fillColor = [[UIColor whiteColor] CGColor];
        [self.layer addSublayer:barLayer];
        _barLayer = barLayer;
        if (self.frame.size.width < 20) {
            self.layer.cornerRadius = 0.1;
        }else{
            self.layer.cornerRadius = 4;
        }
        self.clipsToBounds = YES;
        self.animationEnable = YES;
        self.animationDuration = 1.0f;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabGesture:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tabGesture:(UITapGestureRecognizer *)recognizer{
    if (self.barDelegate&&[self.barDelegate respondsToSelector:@selector(barDidselect:bar:)]) {
        [self.barDelegate barDidselect:self.indexPath bar:self];
    }
}



- (void)setGrade:(CGFloat)grade{
    _barLayer.strokeEnd = 1.0;
    _grade = grade;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.frame.size.width*0.5f, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(self.frame.size.width*0.5f, self.frame.size.height*(1.0f-grade))];
    [path setLineWidth:1.0];
    [path setLineCapStyle:kCGLineCapSquare];
    _barLayer.strokeColor = [self.barColor CGColor];
    _barLayer.path = path.CGPath;
    if (self.animationEnable) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0.0f);
        animation.byValue = @(0.6f);
        animation.toValue = @(1.0f);
        animation.duration = self.animationDuration;
        [_barLayer addAnimation:animation forKey:nil];
    }
}


- (void)setBarBgColor:(UIColor *)barBgColor{
    self.backgroundColor = barBgColor;
    _barBgColor = barBgColor;
}

/*
 - (void)drawRect:(CGRect)rect{
 [super drawRect:rect];
 CGContextRef ctx = UIGraphicsGetCurrentContext();
 if (self.barBgColor) {
 CGContextSetFillColorWithColor(ctx, self.barBgColor.CGColor);
 }else{
 CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:1.00].CGColor);
 }
 CGContextFillRect(ctx, rect);
 }
 */
@end
