//
//  ChartLineView.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/4/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XLineChartView.h"
#import "UIBezierPath+LxThroughPointsBezier.h"

@interface XLineChartView()<UIScrollViewDelegate>

/** 绘制线条层 */
@property (nonatomic,weak) CAShapeLayer *valueLayer;

@end


@implementation XLineChartView

/**
 配置工作
 */
- (void)initDefaultConfig{
    
    [super initDefaultConfig];
    self.strokeLineWidth = 2.0f;
    // sihua 圆点大小
    self.dotRadius = 3.0f;
    self.dotLineWidth = 1.0f;
    self.gradientEnable = true;
    self.chartType = XChartLineTypeCurve;
    self.showDot = true;
//    self.coordColor = [UIColor redColor];
    // sihua 更改轴线颜色
    self.coordColor = [UIColor colorWithRed:178/255.f green:223/255.f blue:238/255.f alpha:1.00];

    
    // sihua
    self.dotType = RXLineDotTypeCircle;
    self.isDotFill = YES;
    
}

//绘制工作
- (void)initChart{
    [self strokeChartWithAnimation:self.animationEnable];
}


/**
 滚动的时候绘制
 
 @param size size
 */
- (void)scrollViewContentSizeDidChange:(CGSize)size{
    [self strokeChartWithAnimation:NO];
}

- (void)strokeChartWithAnimation:(BOOL)animation{
    [self.valueLayer removeFromSuperlayer];
    CAShapeLayer *valueLayer = [[CAShapeLayer alloc] initWithLayer:self.contentView.layer];
    _valueLayer = valueLayer;
    [self.contentView.layer addSublayer:valueLayer];
    
    [self.chartYValuesArr enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"idx 测试测试 -- %lu", (unsigned long)idx);
        NSArray *pathArr = [self strokeChartWithArray:obj idx:idx];
        UIBezierPath *valuesPath = pathArr.firstObject;
        UIBezierPath *dotPath = pathArr.lastObject;
        
        CAShapeLayer *vLayer = [[CAShapeLayer alloc] initWithLayer:self.contentView.layer];
        vLayer.path = valuesPath.CGPath;
        vLayer.lineWidth = self.strokeLineWidth;
        vLayer.lineJoin = kCALineCapRound;
        // sihua 影响线条颜色的地方
        vLayer.strokeColor = self.chartColors[idx].CGColor;
        vLayer.fillColor = [UIColor clearColor].CGColor;
        [_valueLayer addSublayer:vLayer];
        
        CAShapeLayer *arcLayer = [[CAShapeLayer alloc] initWithLayer:self.contentView.layer];
        if (_showDot) {
            arcLayer.path = dotPath.CGPath;
            arcLayer.lineWidth = self.dotLineWidth;
            arcLayer.strokeColor = self.dotStrokeColors[idx].CGColor;
//            // sihua暂时屏蔽
//            if (self.dotFillColors && idx<self.dotFillColors.count) {
//                arcLayer.fillColor = self.dotFillColors[idx].CGColor;
//            }else{
//                arcLayer.fillColor = [UIColor whiteColor].CGColor;
//            }
            if (self.isDotFill == YES) {
                // 影响点填充颜色的地方，将该行注释掉，则默认黑色
                arcLayer.fillColor = self.chartColors[idx].CGColor;
            }
            else {
                arcLayer.fillColor = [UIColor whiteColor].CGColor;
            }
            
            [_valueLayer addSublayer:arcLayer];
        }
        
        
        if (self.gradientEnable) {
            CAShapeLayer *gradienMaskLayer = [CAShapeLayer layer];
            gradienMaskLayer.path = [self gradientPath:obj].CGPath;
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = CGRectMake(0, 0, self.contentView.contentSize.width, self.contentView.frame.size.height - WZCChartBottomHeight - self.strokeLineWidth);
            if (self.gradientColors && idx<self.gradientColors.count) {
                gradientLayer.colors = self.gradientColors[idx];
            }else{
                gradientLayer.colors = @[(id)[UIColor colorWithRed:0.9 green:0 blue:0.6 alpha:0.5].CGColor,
                                         (id)[UIColor colorWithRed:0.5 green:0.8 blue:0.3 alpha:0.5].CGColor];
            }
            
            if (self.gradientLocations&&idx<self.gradientLocations.count) {
                gradientLayer.locations = self.gradientLocations[idx];
            }
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint = CGPointMake(0, 1);
            gradientLayer.mask = gradienMaskLayer;
            [vLayer addSublayer:gradientLayer];
            if (animation) {
                //添加动画
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                animation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 0, self.contentView.frame.size.height - WZCChartBottomHeight - self.strokeLineWidth)];
                animation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.contentView.contentSize.width, self.contentView.frame.size.height - WZCChartBottomHeight - self.strokeLineWidth)];
                animation.duration = self.animationDuration+0.6f;
                //添加动画
                CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                positionAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0, (self.contentView.frame.size.height - WZCChartBottomHeight)*0.5f)];
                positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.contentView.contentSize.width * 0.5f, (self.contentView.frame.size.height - WZCChartBottomHeight)*0.5f)];
                positionAnimation.duration = self.animationDuration+0.6f;
                [gradientLayer addAnimation:animation forKey:nil];
                [gradientLayer addAnimation:positionAnimation forKey:nil];
            }
        }
        
        if (animation) {
            //添加动画
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = @(0);
            animation.byValue = @(0.6);
            animation.toValue = @(1);
            animation.duration = self.animationDuration;
            [vLayer addAnimation:animation forKey:nil];
            [arcLayer addAnimation:animation forKey:nil];
        }
        
    }];
}

/**
 mask的路径
 
 @param valuesArr valuesArr description
 @return return value description
 */
- (UIBezierPath *)gradientPath:(NSArray <NSString *>*)valuesArr{
    CGFloat labWidth = (self.contentView.contentSize.width - WZCChartRight - WZCChartLeft)/self.xTitles.count + self.xLabspace*2.0f;
    UIBezierPath *valuePath = [UIBezierPath bezierPath];
    [valuePath moveToPoint:CGPointMake(labWidth*0.5f + WZCChartLeft, self.contentView.frame.size.height - WZCChartBottomHeight)];
    float scale = [[self valueForKey:@"chartScale"] floatValue];
    NSMutableArray *points = nil;
    CGPoint lastPoint = CGPointMake(self.contentView.contentSize.width - WZCChartRight - labWidth * 0.5f,self.contentView.frame.size.height - WZCChartBottomHeight );
    if (self.chartType == XChartLineTypeCurve) {
        points = [NSMutableArray array];
    }
    for (int i = 0; i < valuesArr.count; i ++) {
        if (i > self.xTitles.count) {
            break;
        }
        CGFloat x = labWidth *(i + 0.5f) + WZCChartLeft;
        CGFloat y = self.contentView.frame.size.height - scale * [valuesArr[i] floatValue] - WZCChartBottomHeight;

        if (self.chartType == XChartLineTypeCurve && i!=0 && valuesArr.count > 3) {
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }else{
            [valuePath addLineToPoint:CGPointMake(x, y)];
        }
        lastPoint = CGPointMake(x,self.contentView.frame.size.height - WZCChartBottomHeight );
    }
    
    if (self.chartType == XChartLineTypeCurve && points.count > 0 && valuesArr.count > 3) {
        [valuePath addBezierThroughPoints:points];
    }
    
    [valuePath addLineToPoint:lastPoint];
    
    [valuePath closePath];
    return valuePath;
}

/**
 绘制折线
 
 @param valuesArr valuesArr description
 @return return value description
 */
- (NSArray<UIBezierPath*>*)strokeChartWithArray:(NSArray<NSString *> *)valuesArr idx:(NSUInteger)idx{
    NSLog(@"index -- %lu", (unsigned long)idx);
//    NSLog(@"调试 -- %@, %lu", valuesArr, (unsigned long)idx);
    
    CGFloat labWidth = [[self valueForKey:@"finalLabWidth"] floatValue];//(self.contentView.contentSize.width - WZCChartRight - WZCChartLeft)/self.x_values.count + self.xLabspace*2.0f;
    UIBezierPath *valuePath = [UIBezierPath bezierPath];
    UIBezierPath *circelPath = [UIBezierPath bezierPath];
    
    
    float scale;
    float lineMinY;
    NSUInteger rIndex = [[[self valueForKey:@"rYIndexArr"] objectAtIndex:0] unsignedIntegerValue];
    if ([self.yValuesArray indexOfObject:valuesArr] == rIndex) {
        scale  = [[self valueForKey:@"r_y_chartScale"] floatValue];
        lineMinY = [[self valueForKey:@"r_minY"] floatValue];
    }
    else {
        scale = [[self valueForKey:@"chartScale"] floatValue];
        lineMinY = [[self valueForKey:@"minY"] floatValue];
    }
    NSLog(@"调试 scale -- %f", scale);
//    float scale = [[self valueForKey:@"chartScale"] floatValue];
//    float scale = [[self valueForKey:@"r_y_chartScale"] floatValue];

    NSMutableArray *points = nil;
    if (self.chartType == XChartLineTypeCurve) {
        points = [NSMutableArray array];
    }
    for (int i = 0; i < valuesArr.count; i ++) {
        if (i > self.xTitles.count) {
            break;
        }
        CGFloat x = labWidth *(i + 0.5f) + WZCChartLeft;
        CGFloat minY = lineMinY;
        // sihua 会影响点的位置
        CGFloat y = self.contentView.frame.size.height - scale * ([valuesArr[i] floatValue] - minY)  - WZCChartBottomHeight;
//        CGFloat y = 100;

        if (i == 0) {
            [valuePath moveToPoint:CGPointMake(x, y)];
        }
        if (self.chartType == XChartLineTypeCurve && valuesArr.count > 3) { //曲线绘制区域
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }else{ //折线绘制区域
            if(i!=0){
                [valuePath addLineToPoint:CGPointMake(x, y)];
            }
        }
        if (_showDot) {
////            // sihua 暂时屏蔽
//            UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:self.dotRadius startAngle:0 endAngle:M_PI*2.0f clockwise:NO];
//            [circelPath appendPath:arcPath];
            
//            // sihua
//            UIBezierPath *cirPath;
//            UIBezierPath *squPath;
//            UIBezierPath *upTriPath;
//            UIBezierPath *downTriPath;
            
//            [downTriPath moveToPoint:CGPointMake(x, y+self.dotRadius)];
//            [downTriPath addLineToPoint:CGPointMake(x-self.dotRadius, y-self.dotRadius)];
//            [downTriPath addLineToPoint:CGPointMake(x+self.dotRadius, y-self.dotRadius)];
//            [downTriPath closePath];
            //
//            double circleL = self
            
            // sihua
            UIBezierPath *cirPath;
            double squareL = self.dotRadius*0.8;
            double diamondL = self.dotRadius * 1.2;
            switch (idx % 5) {
                case RXLineDotTypeCircle:   // 圆点
                    cirPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:self.dotRadius startAngle:0 endAngle:M_PI*2.0f clockwise:NO];
                    [circelPath appendPath:cirPath];
                    break;
                case RXLineDotTypeDiamond:  // 菱形
                    [circelPath moveToPoint:CGPointMake(x, y+diamondL)];
                    [circelPath addLineToPoint:CGPointMake(x+diamondL, y)];
                    [circelPath addLineToPoint:CGPointMake(x, y-diamondL)];
                    [circelPath addLineToPoint:CGPointMake(x-diamondL, y)];
                    [circelPath closePath];
                    break;
                case RXLineDotTypeSquare:   // 正方形
//                    [circelPath moveToPoint:CGPointMake(x-squareL, y+squareL)];
//                    [circelPath addLineToPoint:CGPointMake(x+squareL, y+squareL)];
//                    [circelPath addLineToPoint:CGPointMake(x+squareL, y-squareL)];
//                    [circelPath addLineToPoint:CGPointMake(x-squareL, y-squareL)];
                    [circelPath moveToPoint:CGPointMake(x-squareL, y+squareL)];
                    [circelPath addLineToPoint:CGPointMake(x+squareL, y+squareL)];
                    [circelPath addLineToPoint:CGPointMake(x+squareL, y-squareL)];
                    [circelPath addLineToPoint:CGPointMake(x-squareL, y-squareL)];
                    [circelPath closePath];
                    break;
                case RXLineDotTypeUPTriangle: // 上三角
                    [circelPath moveToPoint:CGPointMake(x, y-self.dotRadius)];
                    [circelPath addLineToPoint:CGPointMake(x-self.dotRadius, y+self.dotRadius)];
                    [circelPath addLineToPoint:CGPointMake(x+self.dotRadius, y+self.dotRadius)];
                    [circelPath closePath];
                    break;
                case RXLineDotTypeDownTriangle: // 下三角
                    [circelPath moveToPoint:CGPointMake(x, y+self.dotRadius)];
                    [circelPath addLineToPoint:CGPointMake(x-self.dotRadius, y-self.dotRadius)];
                    [circelPath addLineToPoint:CGPointMake(x+self.dotRadius, y-self.dotRadius)];
                    [circelPath closePath];
                    break;
                    
                    
                default:
                    break;
            }
        }
    }
    if (self.chartType == XChartLineTypeCurve && points.count>0 && valuesArr.count > 3) {
        [valuePath addBezierThroughPoints:points];
//        NSLog(@"测试测试 pointCount -- %lu", (unsigned long)points.count);
    }
    return @[valuePath,circelPath];
}


- (void)touchPoint:(CGPoint)p xLabWidth:(CGFloat)labWidth{
    NSInteger position = (p.x - WZCChartLeft*1.0f)/labWidth;
    if (position>=self.xTitles.count || position < 0) {
        return;
    }
//    NSString *xTitle = [self.xTitles objectAtIndex:position];  //x标签名
    NSString *xTitle = [self.xTitles objectAtIndex:position];  //x标签名
    NSMutableArray <NSString *>*yValues = [NSMutableArray array];  //y轴的值
    [self.chartYValuesArr enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (position < obj.count) {
            [yValues addObject:obj[position]];
        }else{
            [yValues addObject:@"--"];
        }
    }];
    
    CGFloat drawX = (position + 0.5) * labWidth + WZCChartLeft;
    
    [self drawMarker:drawX xTitle:xTitle yValuesArr:yValues indexPath:nil];
}




- (NSArray<UIColor *> *)dotStrokeColors{
    if (_dotStrokeColors&&_dotStrokeColors.count==self.chartYValuesArr.count) {
        return _dotStrokeColors;
    }
    // sihua 影响连接点的线条颜色，非填充颜色
    _dotStrokeColors = self.chartColors;
//    NSArray *colorArr = @[[UIColor blueColor], [UIColor grayColor], [UIColor whiteColor],[UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor]];
//    _dotStrokeColors = colorArr;
    return _dotStrokeColors;
}

@end
