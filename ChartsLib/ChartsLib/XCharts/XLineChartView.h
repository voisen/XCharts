//
//  ChartLineView.h
//  ChartsLib
//
//  Created by 邬志成 on 2017/4/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XBaseChartView.h"

typedef NS_ENUM(NSInteger, XChartLineType) {
    XChartLineTypeCurve = 0,
    XChartLineTypePolyline
};


@interface XLineChartView : XBaseChartView

/** 绘制线条的宽度 */
@property (nonatomic,assign) CGFloat strokeLineWidth;

/** 显示圆点 */
@property (nonatomic,assign) BOOL showDot;

/** 绘制线条上圆点的半径 */
@property (nonatomic,assign) CGFloat dotRadius;

/** 绘制线条上圆点的线条宽度 */
@property (nonatomic,assign) CGFloat dotLineWidth;

/** 绘制线条上圆点的线条颜色 */
@property (nonatomic,strong) NSArray <UIColor*> * dotStrokeColors;

/** 绘制线条上圆点的填充颜色 */
@property (nonatomic,strong) NSArray <UIColor*> *dotFillColors;

/** 渐变色填充 默认 YES */
@property (nonatomic,assign) BOOL gradientEnable;

//填充渐变色  内部数组格式 (id)[UIColor redColor].CGColor
@property (nonatomic,strong) NSArray <NSArray<id> *> *gradientColors;

//渐变色的locations 参考CAGradientLayer的locations
@property (nonatomic,strong) NSArray <NSArray<NSNumber *> *> *gradientLocations;

/** 线条类型 */
@property (nonatomic,assign) XChartLineType chartType;
@end
