//
//  BarChartView.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/5/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XBarChartView.h"
#import "XBar.h"

@interface XBarChartView()<XBarDelegate>

/** 所有bar所在的view */
@property (nonatomic,weak) UIView *chartView;

/** 是否为自定义宽度 */
@property (nonatomic,assign) BOOL isCustemSize;

@end

@implementation XBarChartView

/*
 计算公式 margin * 2.0f + barWidth * 2.0f + barSpace*1.0f = 1.0f
 */
- (void)initDefaultConfig{
    [super initDefaultConfig];
    self.barBgColor = [UIColor colorWithRed:0.882 green:0.882 blue:0.882 alpha:0.20];
}


- (void)setMargin:(double)margin{
    _margin = margin;
    _isCustemSize = YES;
}
- (void)setBarSpace:(double)barSpace{
    _barSpace = barSpace;
    _isCustemSize = YES;
}
- (void)setBarWidth:(double)barWidth{
    _barWidth = barWidth;
    _isCustemSize = YES;
}
//绘制工作
- (void)initChart{
    if (self.isCustemSize == NO) {
        _margin = 0.07f; //0.14
        //0.86
        _barSpace = 0.05;
        //0.81
        _barWidth = (1.0f - self.margin * 2.0f - self.barSpace * (self.yValuesArray.count - 1))/(1.0f*self.yValuesArray.count);//0.405
        if (_barWidth <= 0.0f) {
            NSLog(@"错误: 组数太多啦....赶紧清理清理");
        }
    }else{
        self.isCustemSize = YES;
        float total = self.margin * 2.0f + self.yValuesArray.count * (self.barSpace + self.barWidth) - self.barSpace;
        NSAssert(total == 1.0f, @"重要: 请根据公式重新设置 `margin`,`barSpace`,`barWidth`的值 !!");
    }
#ifdef DEBUG
    if (!self.isCustemSize) {
        NSAssert(_barWidth > 0, @"错误: 组数太多导致自动计算的 `barWidth` 小于或等于 0 !!");
    }
#endif
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
    [self.chartView removeFromSuperview];
    UIView *chartView = [[UIView alloc] initWithFrame:CGRectMake(0, WZCChartTopHeight, self.contentView.contentSize.width, self.contentView.frame.size.height - WZCChartTopHeight - WZCChartBottomHeight)];
    _chartView = chartView;
    [self.contentView addSubview:chartView];
    [self.yValuesArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawBar:idx valueArray:obj animation:animation];
    }];
}


- (void)drawBar:(NSInteger)idx valueArray:(NSArray<NSString *>*)values animation:(BOOL)animation{
    //必须的参数
    float maxY = [[self valueForKey:@"maxY"] floatValue];
    double labWidth = [[self valueForKey:@"finalLabWidth"] doubleValue];
    double marginValue = labWidth * self.margin;
    double barWidthValue = labWidth * self.barWidth;
    double barSpaceValue = labWidth * self.barSpace;
    for (int i = 0; i < values.count; i ++) {
        CGFloat x = labWidth * i + marginValue + (barWidthValue + barSpaceValue)*idx + WZCChartLeft;
        CGFloat height =self.chartView.frame.size.height;
        XBar *bar = [[XBar alloc] initWithFrame:CGRectMake(x, 0, barWidthValue, height)];
        bar.animationEnable = animation;
        bar.barColor = self.chartColors[idx];
        bar.barBgColor = self.barBgColor;
        bar.indexPath = [NSIndexPath indexPathForRow:i inSection:idx];
        bar.barDelegate = self;
        bar.grade = [values[i] floatValue]/maxY;
        [self.chartView addSubview:bar];
    }
}

- (void)drawXassistLine{
    if (self.xAssistLineEnable) {
        NSArray <UILabel *>*xLabs = [self valueForKey:@"xLabArr"];
        UILabel *preLab;//上一个显示的lab
        CGFloat maxY = self.contentView.frame.size.height - WZCChartTopHeight - WZCChartBottomHeight;
        UIBezierPath *xAassistLinePath = [UIBezierPath bezierPath];
        for (UILabel *lab in xLabs) {
            if (NO == lab.hidden) {
                UIBezierPath *path = [UIBezierPath bezierPath];
                if (preLab == nil) {
                    [path moveToPoint:CGPointMake(WZCChartLeft, 0)];
                    [path addLineToPoint:CGPointMake(WZCChartLeft, maxY)];
                }else{
                    [path moveToPoint:CGPointMake((preLab.center.x+lab.center.x)/2.0f, 0)];
                    [path addLineToPoint:CGPointMake((preLab.center.x+lab.center.x)/2.0f, maxY)];
                }
                [xAassistLinePath appendPath:path];
                preLab = lab;
            }
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.contentView.contentSize.width - WZCChartRight, 0)];
        [path addLineToPoint:CGPointMake(self.contentView.contentSize.width - WZCChartRight, maxY)];
        [xAassistLinePath appendPath:path];
        
        CAShapeLayer *layer = [self valueForKey:@"xAssistLayer"];
        [layer removeFromSuperlayer];
        CAShapeLayer *xAssistLayer = [CAShapeLayer layer];
        xAssistLayer.frame = CGRectMake(0, WZCChartTopHeight, self.contentView.contentSize.width, self.contentView.frame.size.height);
        xAssistLayer.path = xAassistLinePath.CGPath;
        xAssistLayer.strokeColor = self.xAssistLineColor.CGColor;
        xAssistLayer.lineWidth = self.xAssistLineWidth;
        xAssistLayer.fillColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:xAssistLayer];
        [self setValue:xAssistLayer forKey:@"xAssistLayer"];
    }
}


- (void)barDidselect:(NSIndexPath *)indexPath bar:(XBar *)bar{
    [self drawMarker:bar.center.x xTitle:self.xTitles[indexPath.row] yValuesArr:@[self.yValuesArray[indexPath.section][indexPath.row]]];
}

@end
