//
//  BaseChartView.h
//  ChartsLib
//
//  Created by 邬志成 on 2017/4/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WZCChartTopHeight 30
#define WZCChartBottomHeight 30
#define WZCChartRight 30
#define WZCChartLeft 10

typedef NS_ENUM(NSInteger, XChartViewScaleType) {
    XChartViewScaleTypeNone = 0,       //不启用缩放
    XChartViewScaleTypeFollowGesture,  //跟随手势
    XChartViewScaleTypeAfterGesture    //手势执行之后
};

typedef NS_ENUM(NSInteger, XCoordinatesType) {
    XCoordinatesTypeNormal = 0, //对获取到的X 轴刻度不作任何处理
    XCoordinatesTypeMinute,     //显示小时和分钟
    XCoordinatesTypeDay,        //显示年月日
    XCoordinatesTypeMonth       //显示年月
};


@interface XBaseChartView : UIView

/* 右侧 y 轴再数组中的 index */
@property (nonatomic, strong)NSArray *rYIndexArr;

/** 图表标题颜色 */
@property (nonatomic, strong)UIColor *titleColor;

/** 图表标题字体 font */
@property (nonatomic, strong)UIFont *titleFont;

/** 线条隐藏时图例颜色 */
@property (nonatomic, strong)UIColor *hideLineLeColor;

/** 线条出现时图例颜色 */
@property (nonatomic, strong)UIColor *showLineLeColor;

/** 图表标题 */
@property (nonatomic, copy) NSString *chartTitle;

///** 横坐标 */
//@property (nonatomic,strong) NSArray <NSString *>*xTitles;
//
///** 纵坐标 */
//@property (nonatomic,strong) NSArray <NSArray *>*yValuesArray;

///** 数据类别名称数组 */
//@property (nonatomic,strong) NSArray<NSString *> *dataNameArr;

/** 横坐标 */
@property (nonatomic,strong) NSArray <NSString *>*xTitles;

/** 浮动提示框显示的 title */
@property (nonatomic,strong) NSArray <NSString *>*xDetailTitles;

/** 纵坐标 */
@property (nonatomic,strong) NSMutableArray <NSArray *>*yValuesArray;

// 将传入的y 数组赋给该数组
@property (nonatomic, strong)NSMutableArray <NSArray *>*chartYValuesArr;

/** 数据类别名称数组 */
@property (nonatomic,strong) NSMutableArray<NSString *> *dataNameArr;

/** 右侧纵坐标 */
@property (nonatomic,strong) NSArray <NSArray *>*rYValuesArray;

/** 颜色数组 */
@property (nonatomic,strong) NSMutableArray <UIColor*>*chartColors;

/** y轴单位 */
// sihua 暂时屏蔽
@property (nonatomic,copy) NSString *yUnit;

/** 右侧y轴单位 */
@property (nonatomic,copy) NSString *rYUnit;



/** Y轴的刻度个数 */
@property (nonatomic,assign) NSInteger yLabNumber;

/** xy轴标签的字体 */
@property (nonatomic,strong) UIFont *labFont;

/** x轴lab之间的间距 */
@property (nonatomic,assign) CGFloat xLabspace;

/** 坐标系颜色 */
@property (nonatomic,strong) UIColor *coordColor;

/** 坐标系字体颜色 */
@property (nonatomic,strong) UIColor *coordTextColor;

/** 坐标轴线宽 */
@property (nonatomic,assign) CGFloat coordWidth;

/** 绘制区域 */
@property (nonatomic,weak,readonly) UIScrollView *contentView;

/** 动画 */
@property (nonatomic,assign) BOOL animationEnable;

/** 动画持续时间 */
@property (nonatomic,assign) NSTimeInterval animationDuration;

/** 是否显示横线辅助线 默认是 */
@property (nonatomic,assign) CGFloat yAssistLineEnable;

/** 横向辅助线宽度 */
@property (nonatomic,assign) CGFloat yAssistLineWidth;

/** 横向辅助线颜色 */
@property (nonatomic,strong) UIColor *yAssistLineColor;

/** 是否显示纵线辅助线 默认是 */
@property (nonatomic,assign) CGFloat xAssistLineEnable;

/** 纵向辅助线宽度 */
@property (nonatomic,assign) CGFloat xAssistLineWidth;

/** 纵向辅助线颜色 */
@property (nonatomic,strong) UIColor *xAssistLineColor;

/** marker 背景颜色 */
@property (nonatomic,strong) UIColor *markerBgColor;

/** marker 文字颜色 */
@property (nonatomic,strong) UIColor *markerTextColor;

/** marker 线条宽度 */
@property (nonatomic,assign) CGFloat markerLineWidth;

/** 提示线颜色 */
@property (nonatomic,strong) UIColor *markerLineColor;

/** 绘制线条上圆点的半径 */
@property (nonatomic,assign) CGFloat dotRadius;

/** 没有数据的lab */
@property (nonatomic,weak) UILabel *noDataLab;

/** 缩放功能
 *  ChartViewScaleTypeFollowGesture,  //跟随手势
 *  ChartViewScaleTypeAfterGesture    //手势执行之后  <- 默认值
 *  当数据过多时,强烈建议使用 `ChartViewScaleTypeAfterGesture`或者`ChartViewScaleTypeNone` 否则缩放时候会影响性能
 */
@property (nonatomic,assign) XChartViewScaleType scaleType;

/**
 * X 轴刻度的类型
 */
@property (nonatomic, assign) XCoordinatesType xCoType;

- (void)strokeChart;





/* - -- - -- - -- 私有方法调用 - -- - -- - - -*/
- (void)initDefaultConfig;
//- (UIColor *)randomColor; //随机颜色
- (void)initChart;
- (void)scrollViewContentSizeDidChange:(CGSize)size;
- (void)touchPoint:(CGPoint)p xLabWidth:(CGFloat)labWidth;
- (void)drawMarker:(CGFloat)drawX xTitle:(NSString *)title yValuesArr:(NSArray *)yArr indexPath:(NSIndexPath*)indexPath;
- (void)removeMarkView;

- (NSString *)stringByXCoordinatesType:(XCoordinatesType)xCoType objStr:(NSString *)objStr;


@end


