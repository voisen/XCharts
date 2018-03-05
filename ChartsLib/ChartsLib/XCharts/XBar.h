//
//  Bar.h
//  ChartsLib
//
//  Created by 邬志成 on 2017/5/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBar;
@protocol XBarDelegate <NSObject>

- (void)barDidselect:(NSIndexPath *)indexPath bar:(XBar* )bar;

@end

@interface XBar : UIView

/** 级别 0.0 ~ 1.0 之间*/

@property (nonatomic,assign) CGFloat grade;

/** bar 背景颜色 */
@property (nonatomic,strong) UIColor *barBgColor;

/** bar 的颜色 */
@property (nonatomic,strong) UIColor *barColor;


/** 动画 */
@property (nonatomic,assign) BOOL animationEnable;

/** 动画时间 */
@property (nonatomic,assign) NSTimeInterval animationDuration;

/** indexpath */
@property (nonatomic,strong) NSIndexPath *indexPath;

/** delegate */
@property (nonatomic,weak) id<XBarDelegate> barDelegate;

@end


