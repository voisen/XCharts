//
//  BarChartView.h
//  ChartsLib
//
//  Created by 邬志成 on 2017/5/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XBaseChartView.h"

@interface XBarChartView : XBaseChartView

/*              barWidth
 ↓
 |       ___      ___        |
 |      |   |    |   |       |
 |      |   |    |   |       |
 |      |   |    |   |       |
 |margin|   |    |   | margin|
 _________|______|___|____|___|_______|____
 ↑             ↑
 线         barSpace
 |-----------1.0f------------|
 
 计算公式 margin * 2.0f + barWidth * 2.0f + barSpace*1.0f = 1.0f
 */
/** bar 相关设置,值在0.0~1.0 之间  */
@property (nonatomic,assign) double barWidth;
@property (nonatomic,assign) double barSpace;
@property (nonatomic,assign) double margin;

/** bar 背景颜色 */
@property (nonatomic,strong) UIColor *barBgColor;

@end


