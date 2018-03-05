//
//  BaseChartView.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/4/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XBaseChartView.h"

#define yCoverWidth 45

@interface XBaseChartView()<UIScrollViewDelegate>

/** y 坐标 view */
@property (nonatomic,weak) UIView *y_coor_view;

/** 右侧 y 坐标 view */
@property (nonatomic,weak) UIView *r_y_coor_view;

/** x 坐标 view */
@property (nonatomic,weak) UIScrollView *x_coor_view;

/** y刻度的间距值 */
@property (nonatomic,assign) CGFloat yStepValue;

/** 右侧y刻度的间距值 */
@property (nonatomic,assign) CGFloat rYStepValue;

/** 获取最大的Y */
@property (nonatomic,assign) CGFloat maxY;

/** 获取最大的右侧 Y */
@property (nonatomic,assign) CGFloat r_maxY;

/** X轴标签数组 */
@property (nonatomic,strong) NSMutableArray<UILabel *>*xLabArr;

/** X轴的layer层 */
@property (nonatomic,weak) CAShapeLayer *xCoordsLayer;

/** 比例值 */
@property (nonatomic,assign,readonly) CGFloat chartScale;

/** 右侧 y 轴比例值 */
@property (nonatomic,assign,readonly) CGFloat r_y_chartScale;

/** 最终的labWidth */
@property (nonatomic,assign) CGFloat finalLabWidth;

/** 横向辅助线layer */
@property (nonatomic,weak) CAShapeLayer *yAssistLayer;

/** 纵向辅助线layer */
@property (nonatomic,weak) CAShapeLayer *xAssistLayer;


/** 数值标签的layer */
@property (nonatomic,weak) CAShapeLayer *markerLayer;

/** 数值标签的layer */
@property (nonatomic,weak) UILabel *markerView;

/** 单位lab */
// sihua 暂时屏蔽
@property (nonatomic,weak) UILabel *unitLab;

/** 右侧单位lab */
@property (nonatomic,weak) UILabel *rUnitLab;

/** 最小的Y */
@property (nonatomic,assign) CGFloat minY;

/** 右侧Y轴最小的Y */
@property (nonatomic,assign) CGFloat r_minY;

// sihua 待实现
/** x 轴的刻度是否为时间类型 */
@property (nonatomic, assign) BOOL isTimeXTitle;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, weak) UILabel *titleLab;

@property (nonatomic, assign) CGFloat legendBgVH;

@property (nonatomic, strong)NSArray *originDataNameArr;
//@property (nonatomic, strong)NSArray *originYValuesArr;
@property (nonatomic, strong)NSArray <UIColor *>*originChartColors;



@property (nonatomic, weak) UIView *legendBgView;

@end

@implementation XBaseChartView{
    NSLayoutConstraint *contentLayoutLeft;
    UIPanGestureRecognizer *panGesture;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self layoutIfNeeded];
    
    [self initDefaultConfig];
    [self initViews];
}

//- (void)setChartColors:(NSMutableArray<UIColor *> *)chartColors {
//    _chartColors = chartColors;
//    NSLog(@"set方法中 -- %lu %@", (unsigned long)_chartColors.count, _chartColors);
//}

#pragma mark - 关于图例
- (void)initLegendViews {
    
    // sihua 线条颜色
    // 目前只适用于本项目，之后需要优化
    //    NSArray *colorArr =  @[[UIColor blueColor], [UIColor grayColor], [UIColor whiteColor],[UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor]];
    // 209, 94, 96
    UIColor *color1 = [UIColor colorWithRed:209/255.f green:94/255.f blue:96/255.f alpha:1.0];
    // 231, 167, 1
    UIColor *color2 = [UIColor colorWithRed:231/255.f green:167/255.f blue:1/255.f alpha:1.0];
    // 80, 193, 141
    UIColor *color3 = [UIColor colorWithRed:80/255.f green:193/255.f blue:141/255.f alpha:1.0];
    // 253, 72, 0
    UIColor *color4 = [UIColor colorWithRed:253/255.f green:72/255.f blue:0/255.f alpha:1.0];
    // 88, 194, 239
    UIColor *color5 = [UIColor colorWithRed:88/255.f green:194/255.f blue:239/255.f alpha:1.0];
    // 225, 152, 226
    UIColor *color6 = [UIColor colorWithRed:225/255.f green:152/255.f blue:226/255.f alpha:1.0];
    
    
    NSArray *colorArr =  @[color1, color2, color3, color4, color5, color6];
    
    self.chartColors = [NSMutableArray arrayWithArray:colorArr];
    
    UIView *legendBgView = [[UIView alloc] init];
    //    legendBgView.backgroundColor = [UIColor redColor];
    [self addSubview:legendBgView];
    
    self.originDataNameArr = [self.dataNameArr copy];
    //    self.originYValuesArr = [self.yValuesArray copy];
    self.originChartColors = [self.chartColors copy];
    
    //    [self.legendBgView removeFromSuperview];
    
    if (!self.legendBgView) {
        CGFloat __block maxBtnY = 0;
        CGFloat __block rowsNumb = 0;
        //    if (!self.legendBgView) {
        [self.originDataNameArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 1.获取宽度，获取字符串不折行单行显示时所需要的长度
            NSLog(@"obj ------ %@", obj);
            CGSize titleSize = [obj boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                                 context:nil].size;
            //        CGSize titleSize = [obj sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
            NSLog(@"titleSize.width -- %f", titleSize.width);
            // 注：如果想得到宽度的话，size的width应该设为MAXFLOAT。
            NSInteger titleWidth = (int)titleSize.width + 1;
            
            NSInteger btnWidth = 15+titleWidth+2+5;
            NSInteger btnHeight = 15;
            
            
            UIButton *button = [[UIButton alloc] init];
            //        button.frame = CGRectMake(idx * (68 + 3), 0, 68, 30);
            if (maxBtnY + btnWidth + 3 > self.frame.size.width - 10) {
                rowsNumb ++;
                maxBtnY = 0;
            }
            button.frame = CGRectMake(maxBtnY + 3, rowsNumb*(btnHeight + 3), btnWidth, btnHeight);
            //        button.backgroundColor = [UIColor purpleColor];
            button.tag = idx + 100;
            //        button.titleLabel.font = [UIFont systemFontOfSize:12 weight:60];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitleColor:self.showLineLeColor forState:UIControlStateNormal];
            [button setTitle:obj forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            [legendBgView addSubview:button];
            self.legendBgView = legendBgView;
            
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            
            maxBtnY = maxBtnY + btnWidth + 3;
            
            UIBezierPath *bzPath = [UIBezierPath bezierPath];
            //        bzPath.lineWidth = 5;
            [bzPath moveToPoint:CGPointMake(3, btnHeight/2)];
            [bzPath addLineToPoint:CGPointMake(18, btnHeight/2)];
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = bzPath.CGPath;
            shapeLayer.lineWidth = 2;
            NSLog(@"self.chartColors -- %@", self.chartColors);
            shapeLayer.strokeColor = self.chartColors[idx].CGColor;
            //        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
            [button.layer addSublayer:shapeLayer];
        }];
        self.legendBgVH = 20 * (rowsNumb + 1)+3;
    }
    else {
        //        /** 刷新时，如果图例选择了隐藏，则对应的线条不参与刷新 */
        //        NSLog(@"self.legendSubviews -- %@", self.legendBgView.subviews);
        //        for (UIButton *btn in self.legendBgView.subviews) {
        //            UIColor *btnColor = [btn titleColorForState:UIControlStateNormal];
        //            if (CGColorEqualToColor(btnColor.CGColor, self.hideLineLeColor.CGColor)) {
        //                NSLog(@"该图例线条隐藏 --- ");
        //                id nameObj = [self.originDataNameArr objectAtIndex:btn.tag - 100];
        ////                id yValueObj = [self.yValuesArray objectAtIndex:btn.tag - 100];
        ////                id colorsArrObj = [self.originChartColors objectAtIndex:btn.tag - 100];
        //
        //                if ([self.dataNameArr containsObject:nameObj]) {
        //                    NSInteger index = [self.dataNameArr indexOfObject:nameObj];
        //                    [self.dataNameArr removeObjectAtIndex:index];
        //                    [self.chartColors removeObjectAtIndex:index];
        //                    [self.chartYValuesArr removeObjectAtIndex:index];
        //                }
        
        
        
        //                NSLog(@"yValues test -- %@", self.chartYValuesArr);
        
        //    // 根据图例
        //    UIColor *btnColor = [sender titleColorForState:UIControlStateNormal];
        //    // 该图例线条隐藏
        //    if (CGColorEqualToColor(btnColor.CGColor, self.hideLineLeColor.CGColor)) {
        //        if (<#condition#>) {
        //            <#statements#>
        //        }
        //    }
        
        
        //                // 有元素，判断dataNameArr 中是否有点击的元素，有是删除操作，没有是添加操作
        //                if (self.chartYValuesArr.count>0) {
        //                    NSLog(@"yValuresArray -- %@", self.chartYValuesArr);
        //                    NSLog(@"nameObj -- %@", nameObj);
        //                    NSLog(@"self.dataNameArr -- %@", self.dataNameArr);
        //                    if ([self.dataNameArr containsObject:nameObj]) {
        //                        NSInteger index = [self.dataNameArr indexOfObject:nameObj];
        //                        [self.dataNameArr removeObjectAtIndex:index];
        //                        [self.chartColors removeObjectAtIndex:index];
        //                        [self.chartYValuesArr removeObjectAtIndex:index];
        //            }
        //            else {
        //                NSLog(@"该图例线条显示 --- ");
        //            }
        //        }
    }
    
    
    //    }
}

- (void)setLegendBgVH:(CGFloat)legendBgVH {
    _legendBgVH = legendBgVH;
    NSLog(@"_legendBgVH -- %f", _legendBgVH);
    
    self.bgView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height-10-self.legendBgVH);
    
    self.legendBgView.frame = CGRectMake(10, self.frame.size.height-self.legendBgVH, self.frame.size.width - 20, self.legendBgVH);
}

- (void)setYValuesArray:(NSMutableArray<NSArray *> *)yValuesArray {
    _yValuesArray = yValuesArray;
    //    self.chartYValuesArr = [_yValuesArray copy];
    self.chartYValuesArr = [_yValuesArray mutableCopy];
    self.dataNameArr = [_originDataNameArr mutableCopy];
    self.chartColors = [_originChartColors mutableCopy];
    
    /** 刷新时，如果图例选择了隐藏，则对应的线条不参与刷新 */
    NSLog(@"self.legendSubviews -- %@", self.legendBgView.subviews);
    for (UIButton *btn in self.legendBgView.subviews) {
        UIColor *btnColor = [btn titleColorForState:UIControlStateNormal];
        if (CGColorEqualToColor(btnColor.CGColor, self.hideLineLeColor.CGColor)) {
            NSLog(@"该图例线条隐藏 --- ");
            id nameObj = [self.originDataNameArr objectAtIndex:btn.tag - 100];
            //                id yValueObj = [self.yValuesArray objectAtIndex:btn.tag - 100];
            //                id colorsArrObj = [self.originChartColors objectAtIndex:btn.tag - 100];
            
            if ([self.dataNameArr containsObject:nameObj]) {
                NSInteger index = [self.dataNameArr indexOfObject:nameObj];
                [self.dataNameArr removeObjectAtIndex:index];
                [self.chartColors removeObjectAtIndex:index];
                [self.chartYValuesArr removeObjectAtIndex:index];
            }
        }
    }
    NSLog(@"YValuesArr 测试 --- ");
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (instancetype)init{
    NSAssert(NO, @"请使用 initWithFrame: 初始化方法");
    return nil;
}

#pragma mark - 图例的点击事件处理
- (void)clickBtn:(UIButton *)sender{
    NSLog(@"self.originName -- %@", self.originDataNameArr);
    
    NSLog(@"点击了该方法 ------ ");
    
    id nameObj = [self.originDataNameArr objectAtIndex:sender.tag - 100];
    id yValueObj = [self.yValuesArray objectAtIndex:sender.tag - 100];
    id colorsArrObj = [self.originChartColors objectAtIndex:sender.tag - 100];
    
    NSLog(@"yValues test -- %@", self.chartYValuesArr);
    
    //    // 根据图例
    //    UIColor *btnColor = [sender titleColorForState:UIControlStateNormal];
    //    // 该图例线条隐藏
    //    if (CGColorEqualToColor(btnColor.CGColor, self.hideLineLeColor.CGColor)) {
    //        if (<#condition#>) {
    //            <#statements#>
    //        }
    //    }
    
    
    // 有元素，判断dataNameArr 中是否有点击的元素，有是删除操作，没有是添加操作
    if (self.chartYValuesArr.count>0) {
        NSLog(@"yValuresArray -- %@", self.chartYValuesArr);
        NSLog(@"nameObj -- %@", nameObj);
        NSLog(@"self.dataNameArr -- %@", self.dataNameArr);
        if ([self.dataNameArr containsObject:nameObj]) {
            NSInteger index = [self.dataNameArr indexOfObject:nameObj];
            [self.dataNameArr removeObjectAtIndex:index];
            [self.chartColors removeObjectAtIndex:index];
            [self.chartYValuesArr removeObjectAtIndex:index];
            
            [self strokeChart];
            
            [sender setTitleColor:self.hideLineLeColor forState:UIControlStateNormal];
            [sender.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[CAShapeLayer class]]) {
                    CAShapeLayer *shaperL = (CAShapeLayer *)obj;
                    //            shaperL.strokeColor = [UIColor blackColor].CGColor;
                    shaperL.strokeColor = self.hideLineLeColor.CGColor;
                }
            }];
            
            
        }
        else {
            if (sender.tag - 100 >= [self.originDataNameArr indexOfObject:self.dataNameArr.lastObject]) {
                [self.dataNameArr addObject:nameObj];
                [self.chartYValuesArr addObject:yValueObj];
                [self.chartColors addObject:colorsArrObj];
                [self strokeChart];
            }
            else {
                [self.dataNameArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (sender.tag-100 < [self.originDataNameArr indexOfObject:obj]) {
                        [self.dataNameArr insertObject:nameObj atIndex:idx];
                        [self.chartYValuesArr insertObject:yValueObj atIndex:idx];
                        [self.chartColors insertObject:colorsArrObj atIndex:idx];
                        [self strokeChart];
                        *stop = YES;
                    }
                }];
            }
            
            [sender setTitleColor:self.showLineLeColor forState:UIControlStateNormal];
            [sender.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[CAShapeLayer class]]) {
                    CAShapeLayer *shaperL = (CAShapeLayer *)obj;
                    //            shaperL.strokeColor = [UIColor blackColor].CGColor;
                    NSLog(@"self.originChartColors : %@", self.originChartColors);
                    shaperL.strokeColor = self.originChartColors[sender.tag - 100].CGColor;
                }
            }];
        }
    }
    else {
        // 没有元素，必定是需要添加数据的 或者。。。
        [self.dataNameArr addObject:nameObj];
        [self.chartYValuesArr addObject:yValueObj];
        [self.chartColors addObject:colorsArrObj];
        [self strokeChart];
        
        [sender setTitleColor:self.showLineLeColor forState:UIControlStateNormal];
        [sender.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[CAShapeLayer class]]) {
                CAShapeLayer *shaperL = (CAShapeLayer *)obj;
                //            shaperL.strokeColor = [UIColor blackColor].CGColor;
                NSLog(@"self.originChartColors : %@", self.originChartColors);
                shaperL.strokeColor = self.originChartColors[sender.tag - 100].CGColor;
            }
        }];
    }
}

#pragma mark - view 的初始
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        //        self.legendBgVH = 35;
        
        //        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 32)];
        //        button.backgroundColor = [UIColor redColor];
        //        [button addTarget:self action:@selector(clickTest) forControlEvents:UIControlEventTouchUpInside];
        //        [self addSubview:button];
        
        [self initBgView];
        [self initDefaultConfig];
        [self initViews];
        
        
        
        //        // 一整个的基图
        //        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)initBgView {
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height-10-self.legendBgVH)];
    [self addSubview:self.bgView];
}

- (void)setChartTitle:(NSString *)chartTitle {
    _chartTitle = chartTitle;
    self.titleLab.text = chartTitle;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLab.textColor = _titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLab.font = _titleFont;
}

- (void)setDataNameArr:(NSMutableArray<NSString *> *)dataNameArr {
    _dataNameArr = dataNameArr;
    
    // 图例
    [self initLegendViews];
}

- (void)initDefaultConfig{
    // 标题
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.frame = CGRectMake(0, 5, self.frame.size.width, 25);
    titleLab.text = @"chart";
    titleLab.textAlignment = NSTextAlignmentCenter;
    //    titleLab.backgroundColor = [UIColor redColor];
    [self addSubview:titleLab];
    self.titleLab = titleLab;
    // sihua y 轴刻度数
    self.yLabNumber = 3;
    //    self.coordColor = [UIColor blackColor];
    self.coordColor = [UIColor colorWithRed:240/255.f green:248/255.f blue:255/255.f alpha:1.00];
    self.coordTextColor = [UIColor colorWithRed:139/255.f green:139/255.f blue:131/255.f alpha:1.00];
    
    self.coordWidth = 1.0f;
    self.labFont = [UIFont systemFontOfSize:11];
    self.xLabspace = 0;
    self.animationEnable = YES;
    self.animationDuration = 1.0f;
    self.yAssistLineEnable = YES;
    self.yAssistLineWidth = 1.0f;
    // sihua 横向刻度线的颜色
    //    self.yAssistLineColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1.00];
    // 202, 206, 202
    // 191, 193, 191
    self.yAssistLineColor = [UIColor colorWithRed:191/255.f green:193/255.f blue:191/255.f alpha:1.00];
    self.xAssistLineEnable = NO;
    self.xAssistLineWidth = 1.0f;
    self.xAssistLineColor = [UIColor colorWithRed:191/255.f green:193/255.f blue:191/255.f alpha:1.00];
    
    
    //    self.xAssistLineColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1.00];
    //提示 默认配置
    self.markerBgColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.80];
    self.markerTextColor = [UIColor whiteColor];
    self.markerLineWidth = 1.5f;
    self.markerLineColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.00];
    
    self.scaleType = XChartViewScaleTypeFollowGesture;
}

- (void)initViews{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    //    scrollView.backgroundColor = [UIColor redColor];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    _contentView = scrollView;
    [self.bgView addSubview:scrollView];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-yCoverWidth];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraints:@[top,right,bottom]];
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.contentView addGestureRecognizer:pin];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.contentView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *removeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTapGes:)];
    [self addGestureRecognizer:removeTap];
    
    //    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    //    [self.contentView addGestureRecognizer:panGesture];
    
    UILabel *noDataLab = [[UILabel alloc] init];
    //    noDataLab.text = @"NO Data";
    noDataLab.text = @"";
    noDataLab.textColor = [UIColor colorWithRed:0.859 green:0.318 blue:0.286 alpha:1.00];
    [self.bgView addSubview:noDataLab];
    _noDataLab = noDataLab;
}

- (void)removeTapGes:(UITapGestureRecognizer *)removeTap {
    //    CGRect frame = [self convertRect:self.contentView.frame toView:self];
    //    NSLog(@"frame ---- %@", NSStringFromCGRect(frame));
    [self removeMarkView];
}

/** 移除标签 */
- (void)removeMarkView {
    [self.markerView removeFromSuperview];
    [self.markerLayer removeFromSuperlayer];
}

- (void)strokeChart{
    NSLog(@"self.origindataNameArr = %@", self.originDataNameArr);
    NSLog(@"self.colorArr = %@", self.chartColors);
    NSLog(@"self.originColor = %@", self.originChartColors);
    [self.y_coor_view removeFromSuperview];
    [self.r_y_coor_view removeFromSuperview];
    [self.markerView removeFromSuperview];
    [self.markerLayer removeFromSuperlayer];
    
    if (![self checkData]) {
        self.noDataLab.hidden = NO;
        //        self.userInteractionEnabled = NO;
        self.contentView.hidden = YES;
        return;
    }
    else {
        self.noDataLab.hidden = YES;
        self.contentView.hidden = NO;
    }
    self.contentView.hidden = NO;
    self.userInteractionEnabled = YES;
    self.noDataLab.hidden = YES;
//    __block CGFloat y_Max = -CGFLOAT_MAX;
//    // 右侧最大 y 值
//    __block CGFloat r_y_Max = -CGFLOAT_MAX;
//    __block CGFloat y_Min = CGFLOAT_MAX;
//    // 右侧最小 y 值
//    __block CGFloat r_y_Min = CGFLOAT_MAX;
    
    __block CGFloat y_Max = 0;
    // 右侧最大 y 值
    __block CGFloat r_y_Max = 0;
    __block CGFloat y_Min = 0;
    // 右侧最小 y 值
    __block CGFloat r_y_Min = 0;

    __block BOOL isHaveRightElement = NO;
    NSLog(@"self.chartYVCount -- %lu", (unsigned long)self.chartYValuesArr.count);
    NSLog(@"_chartYvaluesArr -- %@", self.chartYValuesArr);
    if (![self.chartYValuesArr containsObject:@[@""]]) { // 不含有空数组的时候执行
        [_chartYValuesArr enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"self.yvaluesArr -- %@", self.yValuesArray);
            NSLog(@"indexOfObj -- %lu", (unsigned long)[self.yValuesArray indexOfObject:obj]);
            NSUInteger currentLineIndex = (unsigned long)[self.yValuesArray indexOfObject:obj];
            NSLog(@"currentIndex -- %lu", (unsigned long)currentLineIndex);
            if ([self.yValuesArray containsObject:@[@""]]) {
                NSLog(@"含有空数组 -- ");
            }
            if ([_rYIndexArr[0] unsignedIntegerValue] == currentLineIndex && self.rYIndexArr.count != 0) { // 右侧元素
                isHaveRightElement = YES;
                [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"-rYIndexArr -- %@", _rYIndexArr);
                    NSLog(@"-rYIndexArr contains -- %d", [_rYIndexArr containsObject:@"2"]);
                    
                    //                if ([_rYIndexArr[0] unsignedIntegerValue] == idx) {
                    //                    NSLog(@"_chartY -- %@", _chartYValuesArr[idx]);
                    if (r_y_Max < [obj floatValue]) {
                        r_y_Max = [obj floatValue];
                    }
                    if ([obj floatValue]<r_y_Min) {
                        r_y_Min = [obj floatValue];
                    }
                }];
            }
            else {
                [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"-rYIndexArr -- %@", _rYIndexArr);
                    NSLog(@"-rYIndexArr contains -- %d", [_rYIndexArr containsObject:@"2"]);
                    
                    
                    if (y_Max < [obj floatValue]) {
                        y_Max = [obj floatValue];
                    }
                    //            if (y_Max < [obj floatValue]) {
                    //                y_Max = [obj floatValue];
                    //            }
                    if ([obj floatValue]<y_Min) {
                        y_Min = [obj floatValue];
                    }
                }];
            }
            
        }];
    }
    
    //    if (y_Max < 1) {
    //        y_Max = 1;
    //    }
    
    if (y_Min>0) {
        y_Min = 0;
    }else{
        if (y_Min<-10) {
            while ((int)(y_Min+0.5)%5!=0) {
                y_Min--;
            }
        }else{
            int yMinTmp = y_Min * 100;
            while (yMinTmp%5!=0) {
                yMinTmp--;
            }
            y_Min = yMinTmp/100.0f;
        }
    }
    
    if (r_y_Min>0) {
        r_y_Min = 0;
    }else{
        if (r_y_Min<-10) {
            while ((int)(r_y_Min+0.5)%5!=0) {
                r_y_Min--;
            }
        }else{
            int yMinTmp = r_y_Min * 100;
            while (yMinTmp%5!=0) {
                yMinTmp--;
            }
            r_y_Min = yMinTmp/100.0f;
        }
    }
    
    if (y_Max - y_Min == 0) {
        y_Max = 0;
    }
    
    if (r_y_Max - r_y_Min == 0) {
        r_y_Max = 0;
    }
    
    // sihua 调试，暂时屏蔽
    _yStepValue = (y_Max-y_Min) / self.yLabNumber;
    
    _rYStepValue = (r_y_Max - r_y_Min) / self.yLabNumber;
    
    NSLog(@"_yStepValue -- %f", _yStepValue);
    
    
    if (y_Max < 100) {
        NSInteger stepTemp = _yStepValue * 100;
        while (stepTemp%5 != 0) {//78.87
            stepTemp++;
        }
        _yStepValue = stepTemp/100.0f;
    }else{
        while ((int)(_yStepValue)%5 != 0) {
            _yStepValue += 1;
        }
        _yStepValue = (int)_yStepValue;
    }
    y_Max = _yStepValue * self.yLabNumber + y_Min;
    NSLog(@"y_Max -- %f", y_Max);
    if (y_Max - y_Min == 0) {
        y_Max = 1;
        y_Min = 0;
    }
    
    _chartScale = (self.bgView.frame.size.height - WZCChartTopHeight - WZCChartBottomHeight)/(y_Max - y_Min);
    _maxY = y_Max;
    _minY = y_Min;
    
    if (self.rYIndexArr.count == 0) { // 没有右侧数据的时候(没有传入这个参数)
        _r_y_chartScale = _chartScale;
        _rYStepValue = _yStepValue;
        r_y_Max = y_Max;
        _r_maxY = _maxY;
        r_y_Min = _minY;
        _r_minY = _minY;
    }
    else {
        if (r_y_Max < 100) {
            NSInteger stepTemp = _rYStepValue * 100;
            while (stepTemp%5 != 0) {//78.87
                stepTemp++;
            }
            _rYStepValue = stepTemp/100.0f;
        }else{
            while ((int)(_rYStepValue)%5 != 0) {
                _rYStepValue += 1;
            }
            _rYStepValue = (int)_rYStepValue;
        }
        r_y_Max = _rYStepValue * self.yLabNumber + r_y_Min;
        NSLog(@"r_y_Max -- %f", r_y_Max);
        if (r_y_Max - r_y_Min == 0) {
            r_y_Max = 1;
            r_y_Min = 0;
        }
        
        _r_y_chartScale = (self.bgView.frame.size.height - WZCChartTopHeight - WZCChartBottomHeight)/(r_y_Max - r_y_Min);
        _r_maxY = r_y_Max;
        _r_minY = r_y_Min;
        NSLog(@"_r_maxY -- %f, _r_minY -- %f", _r_maxY, _r_minY);
    }
    
    // 只有右侧元素的时候
    NSUInteger rIndex = [self.rYIndexArr[0] unsignedIntegerValue];
    BOOL isRLine = [self.yValuesArray indexOfObject:self.chartYValuesArr[0]] == rIndex;
    if (self.chartYValuesArr.count == 1 && isRLine && self.rYIndexArr.count != 0) {
        _chartScale = _r_y_chartScale;
        _yStepValue = _rYStepValue;
        y_Max = r_y_Max;
        _maxY = _r_maxY;
        _minY = _r_minY;
    }
    NSLog(@"isHaveRightElement -- %d", isHaveRightElement);
    if (isHaveRightElement == NO && self.rYIndexArr.count != 0) { // 没有右侧数据的时候(图例点击)
        _r_y_chartScale = _chartScale;
        _rYStepValue = _yStepValue;
        r_y_Max = y_Max;
        _r_maxY = _maxY;
        _r_minY = _minY;
    }
    //    if () {
    //        <#statements#>
    //    }
    
    
    [self drawY];
    [self drawRightY];
    [self drawX];
    if (self.yAssistLineEnable) {
        [self drawYAssistLine:self.contentView.contentSize];
    }
    [self initChart];
}


- (BOOL)checkData{
    self.noDataLab.hidden = NO;
    [self.noDataLab sizeToFit];
    self.noDataLab.center = CGPointMake(self.bgView.frame.size.width*0.5f, self.bgView.frame.size.height * 0.5f);
    if (self.xTitles.count==0) {
        return NO;
    }
    __block BOOL flag = NO;
    if (self.chartYValuesArr == nil) {
        return NO;
    }
    [self.chartYValuesArr enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        if (obj == nil) {
            flag = NO;
        }
        
        if (obj.count!=0) {
            flag = YES;
        }
    }];
    
#ifdef DEBUG
    NSLog(@"DEBUG...");
#else
    NSLog(@"RELESE...");
    return flag;
#endif
    
    for (id obj in self.xTitles) {
        NSAssert1([obj isKindOfClass:[NSString class]], @"检测到对象 %@ 不属于 NSString 类型 !!", obj);
    }
    
    for (int i = 0; i < self.chartYValuesArr.count; i ++) {
        id yObj = self.chartYValuesArr[i];
        NSAssert1([yObj isKindOfClass:[NSArray class]], @"检测到y_values中的对象 %@ 不属于 NSArray 类型 !!", yObj);
        NSArray *yArr = yObj;
        for (id obj in yArr) {
            NSAssert1([obj isKindOfClass:[NSString class]], @"检测到提供的数值 %@ 不属于 NSString 类型 !!", obj);
        }
    }
    
    return flag;
}

/**
 绘制Y轴
 */
- (void)drawY{
    [_unitLab removeFromSuperview];
    NSLog(@"self.yStepValue -- %f", self.yStepValue);
    CGFloat arrowWidth = self.coordWidth * 3;
    CGSize size = [self.yUnit sizeWithAttributes:@{NSFontAttributeName:self.labFont}];
    for (int i = 0; i < self.yLabNumber+1; i++) {
        NSString *yLabValueStr;
        if ((int)(i * _yStepValue+self.minY) == (i * _yStepValue+self.minY)) {
            yLabValueStr = [NSString stringWithFormat:@"%d",(int)(i * _yStepValue+self.minY)];
        }else{
            yLabValueStr = [NSString stringWithFormat:@"%0.2f",i * _yStepValue+self.minY];
        }
        
        CGSize tmpSize = [yLabValueStr sizeWithAttributes:@{NSFontAttributeName:self.labFont}];
        if (tmpSize.width>size.width) {
            size = tmpSize;
        }
    }
    size.width += 3;
    //绘制y轴
    //    UIView *yCoorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width + arrowWidth * 3 + self.coordWidth, self.frame.size.height)]; //初始化y轴的view
    UIView *yCoorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, yCoverWidth, self.bgView.frame.size.height)]; //初始化y轴的view
    //    yCoorView.backgroundColor = [UIColor purpleColor];
    _y_coor_view = yCoorView;
    UILabel *unitLab = [[UILabel alloc] init];
    unitLab.text = self.yUnit;
    //    unitLab.text = @"unitkkk";
    unitLab.textAlignment = NSTextAlignmentCenter;
    unitLab.font = self.labFont;
    //    unitLab.textColor = self.coordColor;
    unitLab.textColor = self.coordTextColor;
    [unitLab sizeToFit];
    CGPoint uCenter = unitLab.center;
    uCenter.x = yCoorView.center.x;
    unitLab.center = uCenter;
    unitLab.center = CGPointMake(yCoorView.center.x-15, self.center.y);
    //顺时针旋转90度
    unitLab.transform = CGAffineTransformMakeRotation((90.0f * M_PI) / -180.0f);
    
    _unitLab = unitLab;
    //    unitLab.backgroundColor = [UIColor redColor];
    [yCoorView addSubview:unitLab];
    
    UIBezierPath *yCoordsPath = [UIBezierPath bezierPath]; //绘制Y
    [yCoordsPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, yCoorView.frame.size.height - WZCChartBottomHeight + self.coordWidth * 0.5f)];
    [yCoordsPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, 0)];
    for (int i = 0 ; i < self.yLabNumber + 1; i ++) {
        CGFloat y = self.bgView.frame.size.height - i * _yStepValue * _chartScale - WZCChartBottomHeight;
        UILabel *yLab = [[UILabel alloc] initWithFrame:CGRectMake(0, y - size.height/2.0f, yCoverWidth, size.height)];
        yLab.font = self.labFont;
        //        yLab.backgroundColor = [UIColor orangeColor];
        NSString *yLabValueStr;
        if ((int)(i * _yStepValue+self.minY) == (i * _yStepValue+self.minY)) {
            yLabValueStr = [NSString stringWithFormat:@"%d",(int)(i * _yStepValue+self.minY)];
        }else{
            yLabValueStr = [NSString stringWithFormat:@"%0.2f",i * _yStepValue+self.minY];
        }
        yLab.text = yLabValueStr;
        //        yLab.backgroundColor = [UIColor redColor];
        yLab.textAlignment = NSTextAlignmentRight;
        //        yLab.textColor = self.coordColor;
        yLab.textColor = self.coordTextColor;
        [self.y_coor_view addSubview:yLab];
        
        if (i != 0) {
            UIBezierPath *yStepPath = [UIBezierPath bezierPath];
            [yStepPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, y)];
            [yStepPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth*2, y)];
            [yCoordsPath appendPath:yStepPath];
            
        }
    }
    //拼接 箭头
    UIBezierPath *allowPath = [UIBezierPath bezierPath];
    [allowPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth * 2, arrowWidth * 1.5f)];
    [allowPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, 0)];
    [allowPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth, arrowWidth * 1.5f)];
    [yCoordsPath appendPath:allowPath];
    
    CAShapeLayer *yCoordsLayer = [[CAShapeLayer alloc] initWithLayer:yCoorView.layer];
    yCoordsLayer.path = yCoordsPath.CGPath;
    //    yCoordsLayer.strokeColor = self.coordColor.CGColor;
    yCoordsLayer.strokeColor = [UIColor clearColor].CGColor;
    yCoordsLayer.lineWidth = self.coordWidth;
    yCoordsLayer.fillColor = [UIColor clearColor].CGColor;
    [self removeConstraint:contentLayoutLeft];
    contentLayoutLeft = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:yCoorView.frame.size.width - arrowWidth - self.coordWidth];
    [self addConstraint:contentLayoutLeft];
    [self.y_coor_view.layer addSublayer:yCoordsLayer];
    [self.bgView addSubview:yCoorView];
    [self layoutIfNeeded];
    self.contentView.contentSize = CGSizeMake(self.contentView.frame.size.width, 0);
}

/**
 绘制右侧Y轴
 */
- (void)drawRightY{
    [_rUnitLab removeFromSuperview];
    CGFloat arrowWidth = self.coordWidth * 3;
    CGSize size = [self.rYUnit sizeWithAttributes:@{NSFontAttributeName:self.labFont}];
    for (int i = 0; i < self.yLabNumber+1; i++) {
        NSString *yLabValueStr;
        if ((int)(i * _rYStepValue+self.r_minY) == (i * _rYStepValue+self.r_minY)) {
            yLabValueStr = [NSString stringWithFormat:@"%d",(int)(i * _rYStepValue+self.r_minY)];
        }else{
            yLabValueStr = [NSString stringWithFormat:@"%0.2f",i * _rYStepValue+self.r_minY];
        }
        
        CGSize tmpSize = [yLabValueStr sizeWithAttributes:@{NSFontAttributeName:self.labFont}];
        if (tmpSize.width>size.width) {
            size = tmpSize;
        }
    }
    size.width += 3;
    //绘制y轴
    UIView *yCoorView = [[UIView alloc] initWithFrame:CGRectMake(self.bgView.frame.size.width-yCoverWidth, 0, size.width + arrowWidth * 3 + self.coordWidth, self.bgView.frame.size.height)]; //初始化y轴的view
    //    yCoorView.backgroundColor = [UIColor purpleColor];
    _r_y_coor_view = yCoorView;
    
    //    _y_coor_view.backgroundColor = [UIColor redColor];
    // 单位标题
    UILabel *unitLab = [[UILabel alloc] init];
    unitLab.text = self.rYUnit;
    //    unitLab.text = @"unitkkk";
    unitLab.textAlignment = NSTextAlignmentCenter;
    unitLab.font = self.labFont;
    //    unitLab.textColor = self.coordColor;
    unitLab.textColor = self.coordTextColor;
    [unitLab sizeToFit];
    CGPoint uCenter = unitLab.center;
    uCenter.x = yCoorView.center.x;
    unitLab.center = uCenter;
    //    NSLog(@"center 测试 ： %f, %f", )
    unitLab.center = CGPointMake(yCoverWidth-7, yCoorView.center.y);
    //顺时针旋转90度
    unitLab.transform = CGAffineTransformMakeRotation((90.0f * M_PI) / -180.0f);
    
    _rUnitLab = unitLab;
    [yCoorView addSubview:unitLab];
    
    UIBezierPath *yCoordsPath = [UIBezierPath bezierPath]; //绘制Y
    [yCoordsPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, yCoorView.frame.size.height - WZCChartBottomHeight + self.coordWidth * 0.5f)];
    [yCoordsPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, 0)];
    // 刻度
    for (int i = 0 ; i < self.yLabNumber + 1; i ++) {
        CGFloat y = self.bgView.frame.size.height - i * _rYStepValue * _r_y_chartScale - WZCChartBottomHeight;
        UILabel *yLab = [[UILabel alloc] initWithFrame:CGRectMake(3, y - size.height/2.0f, size.width, size.height)];
        yLab.font = self.labFont;
        NSString *yLabValueStr;
        if ((int)(i * _rYStepValue+self.r_minY) == (i * _rYStepValue+self.r_minY)) {
            yLabValueStr = [NSString stringWithFormat:@"%d",(int)(i * _rYStepValue+self.r_minY)];
        }else{
            yLabValueStr = [NSString stringWithFormat:@"%0.2f",i * _rYStepValue+self.r_minY];
        }
        yLab.text = yLabValueStr;
        yLab.textAlignment = NSTextAlignmentLeft;
        //        yLab.textColor = self.coordColor;
        yLab.textColor = self.coordTextColor;
        [self.r_y_coor_view addSubview:yLab];
        
        if (i != 0) {
            UIBezierPath *yStepPath = [UIBezierPath bezierPath];
            [yStepPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, y)];
            [yStepPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth*2, y)];
            [yCoordsPath appendPath:yStepPath];
            
        }
    }
    //拼接 箭头
    UIBezierPath *allowPath = [UIBezierPath bezierPath];
    [allowPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth * 2, arrowWidth * 1.5f)];
    [allowPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, 0)];
    [allowPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth, arrowWidth * 1.5f)];
    [yCoordsPath appendPath:allowPath];
    
    CAShapeLayer *yCoordsLayer = [[CAShapeLayer alloc] initWithLayer:yCoorView.layer];
    yCoordsLayer.path = yCoordsPath.CGPath;
    //    yCoordsLayer.strokeColor = self.coordColor.CGColor;
    yCoordsLayer.strokeColor = [UIColor clearColor].CGColor;
    yCoordsLayer.lineWidth = self.coordWidth;
    yCoordsLayer.fillColor = [UIColor clearColor].CGColor;
    [self removeConstraint:contentLayoutLeft];
    contentLayoutLeft = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:yCoorView.frame.size.width - arrowWidth - self.coordWidth];
    [self addConstraint:contentLayoutLeft];
    [self.r_y_coor_view.layer addSublayer:yCoordsLayer];
    [self.bgView addSubview:yCoorView];
    [self layoutIfNeeded];
    self.contentView.contentSize = CGSizeMake(self.contentView.frame.size.width, 0);
}


/**
 绘制X轴
 */
- (void)drawX{
    [_xCoordsLayer removeFromSuperlayer];
    //1.获取最大lab的宽度
    __block CGFloat maxWidth = CGFLOAT_MIN;
    [self.xTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 决定X 轴刻度的宽度
        NSString *xStr = [obj componentsSeparatedByString:@" "].lastObject;
        CGSize objSize = [xStr sizeWithAttributes:@{NSFontAttributeName:self.labFont}];
        if (objSize.width > maxWidth) {
            maxWidth = objSize.width;
        }
    }];
    maxWidth += self.xLabspace*2.0f;
    //2.全显示的lab宽度
    self.finalLabWidth = (self.contentView.contentSize.width - WZCChartRight - WZCChartLeft)/self.xTitles.count + self.xLabspace*2.0f;
    //3.间隔几个title显示一个lab
    NSInteger spaceNumber = (maxWidth/self.finalLabWidth)/2+1;
    NSInteger visibleCount = (self.contentView.contentSize.width - WZCChartRight - WZCChartLeft) / maxWidth;
    //添加标签
    if (self.xLabArr == nil||self.xLabArr.count != self.xTitles.count) {
        [self.xLabArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.xLabArr = [NSMutableArray array];
        for (int i = 0; i < self.xTitles.count; i ++) {
            UILabel *xLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.frame.size.height - WZCChartBottomHeight + self.coordWidth, maxWidth, WZCChartBottomHeight - self.coordWidth)];
            xLab.font = self.labFont;
            //            xLab.backgroundColor = [UIColor purpleColor];
            xLab.textAlignment = NSTextAlignmentCenter;
            // x 轴刻度
            //            xLab.text = self.xTitles[i];
            //            xLab.text = @"5:00";
            
            // 目前只适用于NetZero 项目，将时间的日期去掉，只剩小时分钟
            xLab.text = [self.xTitles[i] componentsSeparatedByString:@" "].lastObject;
            
            xLab.hidden = YES;
            //            xLab.textColor = self.coordColor;
            xLab.textColor = self.coordTextColor;
            [self.contentView addSubview:xLab];
            [self.xLabArr addObject:xLab];
        }
    }
    for (int i = 0; i < self.xLabArr.count; i ++) {
        CGFloat centerX = (i + 0.5f) * self.finalLabWidth + WZCChartLeft;
        CGPoint center = self.xLabArr[i].center;
        center.x = centerX;
        self.xLabArr[i].center = center;
        self.xLabArr[i].hidden = self.finalLabWidth < maxWidth;
    }
    if (self.finalLabWidth < maxWidth) {
        for (int i = 0; i < visibleCount; i ++) {
            if (i * spaceNumber*2 + spaceNumber < self.xLabArr.count) {
                UILabel *lab = self.xLabArr[i * spaceNumber*2 + spaceNumber];
                if (CGRectGetMaxX(lab.frame) > self.contentView.contentSize.width) {
                    continue;
                }
                lab.hidden = NO;
            }
        }
    }
    
    [self drawXassistLine];
    //开始绘制横坐标
    UIBezierPath *xCoordsPath = [UIBezierPath bezierPath];
    [xCoordsPath moveToPoint:CGPointMake(0, 0)];
    // 最下方的一条横轴，非辅助线
    [xCoordsPath addLineToPoint:CGPointMake(self.contentView.contentSize.width - 5,0)];
    
    //    // sihua 暂时屏蔽
    //    //绘制箭头
    //    CGFloat arrowWidth = self.coordWidth * 3;
    //    UIBezierPath *xArrowPath = [UIBezierPath bezierPath];
    //    [xArrowPath moveToPoint:CGPointMake(self.contentView.contentSize.width - arrowWidth*1.5f - 3,  - arrowWidth)];
    //    [xArrowPath addLineToPoint:CGPointMake(self.contentView.contentSize.width - 3, 0)];
    //    [xArrowPath addLineToPoint:CGPointMake(self.contentView.contentSize.width - arrowWidth*1.5f - 3,arrowWidth)];
    //    [xCoordsPath appendPath:xArrowPath];
    
    CAShapeLayer *xCoordsLayer = [[CAShapeLayer alloc] init];
    xCoordsLayer.frame = CGRectMake(0, self.bgView.frame.size.height - WZCChartBottomHeight, self.contentView.contentSize.width, WZCChartBottomHeight);
    xCoordsLayer.path = xCoordsPath.CGPath;
    xCoordsLayer.strokeColor = self.coordColor.CGColor;
    xCoordsLayer.fillColor = [UIColor clearColor].CGColor;
    xCoordsLayer.lineWidth = self.coordWidth;
    [self.contentView.layer addSublayer:xCoordsLayer];
    _xCoordsLayer = xCoordsLayer;
    //    _xCoordsLayer.backgroundColor = [UIColor purpleColor].CGColor;
}




- (void)drawXassistLine{
    //    self.contentView.backgroundColor = [UIColor redColor];
    NSLog(@"contentview CSize : %f, FSize : %f", self.contentView.contentSize.width, self.contentView.frame.size.width);
    if (self.xAssistLineEnable) { //绘制辅助线
        [self.xAssistLayer removeFromSuperlayer];
        UIBezierPath *xAssistLinePath = [UIBezierPath bezierPath];
        for (int i = 0; i < self.xLabArr.count; i ++) {
            UILabel *lab = self.xLabArr[i];
            if (NO==lab.hidden) {
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:CGPointMake(lab.center.x, 0)];
                [path addLineToPoint:CGPointMake(lab.center.x, self.contentView.frame.size.height - WZCChartTopHeight-WZCChartBottomHeight)];
                [xAssistLinePath appendPath:path];
            }
        }
        CAShapeLayer *xAssistLayer = [CAShapeLayer layer];
        xAssistLayer.frame = CGRectMake(0, WZCChartTopHeight, self.contentView.contentSize.width, self.contentView.frame.size.height);
        xAssistLayer.path = xAssistLinePath.CGPath;
        xAssistLayer.strokeColor = self.xAssistLineColor.CGColor;
        xAssistLayer.lineWidth = self.xAssistLineWidth;
        xAssistLayer.fillColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:xAssistLayer];
        _xAssistLayer = xAssistLayer;
    }
}

//点击手势
- (void)tapGesture:(UITapGestureRecognizer *)recognizer{
    CGPoint p = [recognizer locationInView:self.contentView];
    //全显示的lab宽度
    [self touchPoint:p xLabWidth:self.finalLabWidth];
}


/**
 滑动手势
 
 @param recognizer recognizer description
 */
- (void)panGesture:(UIPanGestureRecognizer *)recognizer{
    CGPoint p = [recognizer locationInView:self.contentView];
    [self touchPoint:p xLabWidth:self.finalLabWidth];
}

// 捏合手势监听方法
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (self.scaleType == XChartViewScaleTypeNone) {
        return;
    }
    [self.markerLayer removeFromSuperlayer];
    [self.markerView removeFromSuperview];
    if (self.scaleType == XChartViewScaleTypeAfterGesture) {
        CGFloat width = self.contentView.frame.size.width;
        width *= recognizer.scale;
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            CGFloat width = self.contentView.contentSize.width;
            width *= recognizer.scale;
            CGFloat oldWidth = self.contentView.contentSize.width;
            [self scaleContentViewWidth:width];
            [self setOffsetWithOldWidth:oldWidth newWidth:width];
        }
    }else{
        static CGFloat localWidth;
        if (recognizer.state == UIGestureRecognizerStateBegan && recognizer.numberOfTouches == 2) {
            localWidth = self.contentView.contentSize.width;
            if (localWidth <= 0) {
                localWidth = self.contentView.frame.size.width;
            }
        }
        if (recognizer.numberOfTouches == 2) {
            CGFloat contentWidth = localWidth * recognizer.scale;
            if (contentWidth < self.contentView.frame.size.width) {
                contentWidth = self.contentView.frame.size.width;
            }
            CGFloat oldWidth = self.contentView.contentSize.width;
            [self scaleContentViewWidth:contentWidth];
            [self setOffsetWithOldWidth:oldWidth newWidth:self.contentView.contentSize.width];
        }
    }
}

- (void)setOffsetWithOldWidth:(CGFloat)oldWidth newWidth:(CGFloat)newWidth{
    //中心点
    CGFloat toScale = newWidth/oldWidth;
    CGFloat offsetX = toScale * (self.contentView.contentOffset.x+self.contentView.frame.size.width * 0.5f) - self.contentView.frame.size.width*0.5f;
    if (self.contentView.contentSize.width < self.contentView.frame.size.width * 1.5f||offsetX < 0) {
        offsetX = 0;
    }
    if (offsetX > self.contentView.contentSize.width - self.contentView.frame.size.width) {
        offsetX = self.contentView.contentSize.width - self.contentView.frame.size.width;
    }
    self.contentView.contentOffset = CGPointMake(offsetX, 0);
}


- (void)scaleContentViewWidth:(CGFloat)contentWidth{
    
    panGesture.enabled = NO;
    if (contentWidth <= self.contentView.frame.size.width) {
        contentWidth = self.contentView.frame.size.width;
        panGesture.enabled = YES;
    }
    self.contentView.contentSize = CGSizeMake(contentWidth, 0);
    [self drawX];
    if (self.yAssistLineEnable) {
        [self drawYAssistLine:self.contentView.contentSize];
    }
    [self scrollViewContentSizeDidChange:self.contentView.contentSize];
    
}


- (void)drawYAssistLine:(CGSize)size {
    [self.yAssistLayer removeFromSuperlayer];
    UIBezierPath *yAssistPath = [UIBezierPath bezierPath];
    for (int i = 1 ; i < self.yLabNumber + 1; i ++) {
        NSLog(@"i -- %d", i);
        
        //        CGFloat y;
        //        if ([_rYIndexArr containsObject:[NSNumber numberWithUnsignedInteger:i]]) {
        //            y = self.bgView.frame.size.height - i * _rYStepValue * _r_y_chartScale - WZCChartBottomHeight;
        //        }
        //        else {
        //            y = self.bgView.frame.size.height - i * _yStepValue * _chartScale - WZCChartBottomHeight;
        //        }
        
        //        NSLog(@"_rYStep -- %f, r_y_chartScale -- %f", _rYStepValue, _r_y_chartScale);
        //        NSLog(@"_yStepValue -- %f, _chartScale -- %f", _yStepValue, _chartScale);
        
        CGFloat y = self.bgView.frame.size.height - i * _rYStepValue * _r_y_chartScale - WZCChartBottomHeight;
        //        CGFloat y = self.bgView.frame.size.height - i * _yStepValue * _chartScale - WZCChartBottomHeight;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, y)];
        CGFloat maxX = [self isKindOfClass:NSClassFromString(@"XBarChartView")]?(self.contentView.contentSize.width - WZCChartRight):self.xLabArr.lastObject.center.x;
//        [path addLineToPoint:CGPointMake(maxX, y)];
        [path addLineToPoint:CGPointMake(self.contentView.contentSize.width-3, y)];
        [yAssistPath appendPath:path];
    }
    CAShapeLayer *yAssistLayer = [CAShapeLayer layer];
    yAssistLayer.frame = CGRectMake(0, 0, self.contentView.contentSize.width, self.contentView.frame.size.height);
    yAssistLayer.path = yAssistPath.CGPath;
    yAssistLayer.strokeColor = self.yAssistLineColor.CGColor;
    yAssistLayer.fillColor = [UIColor clearColor].CGColor;
    yAssistLayer.lineWidth = self.yAssistLineWidth;
    [self.contentView.layer addSublayer:yAssistLayer];
    _yAssistLayer = yAssistLayer;
    //    _yAssistLayer.backgroundColor = [UIColor yellowColor].CGColor;
}

/**
 点击了某个点后
 
 @param p 值
 */
- (void)touchPoint:(CGPoint)p xLabWidth:(CGFloat)labWidth{}

- (void)scrollViewContentSizeDidChange:(CGSize)size{
}

/**
 绘制标签
 
 @param drawX drawX description
 @param title title description
 @param yArr yArr description
 */
- (void)drawMarker:(CGFloat)drawX xTitle:(NSString *)title yValuesArr:(NSArray *)yArr indexPath:(NSIndexPath *)indexPath{
    [self.markerLayer removeFromSuperlayer];
    [self.markerView removeFromSuperview];
    //绘制竖线
    UIBezierPath *markerLinePath = [UIBezierPath bezierPath];
    [markerLinePath moveToPoint:CGPointMake(drawX, WZCChartTopHeight)];
    [markerLinePath addLineToPoint:CGPointMake(drawX, self.contentView.frame.size.height - WZCChartBottomHeight)];
    CAShapeLayer *markerLayer = [[CAShapeLayer alloc] initWithLayer:self.contentView.layer];
    markerLayer.path = markerLinePath.CGPath;
    markerLayer.lineWidth = self.markerLineWidth;
    markerLayer.lineJoin = kCALineCapRound;
    //    markerLayer.strokeColor = self.markerLineColor.CGColor;
    markerLayer.strokeColor = [UIColor redColor].CGColor;
    _markerLayer = markerLayer;
    [self.contentView.layer addSublayer:markerLayer];
    
    if (self.yUnit==nil) {
        self.yUnit = @"";
    }
    
    if (self.rYUnit == nil) {
        self.rYUnit = @"";
    }
    
    //显示数值
    __block CGFloat drawViewY = 0;
    NSMutableAttributedString *showMsg = [[NSMutableAttributedString alloc] init];
    [showMsg.mutableString appendFormat:@"  %@\n",title];
    
    [yArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *attributeDict = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0],
                                        NSForegroundColorAttributeName: self.chartColors[idx]};
        
        if (self.dataNameArr!=nil&&idx<self.dataNameArr.count) {
            
            if (indexPath) {
                
                NSMutableAttributedString *tempAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  •  %@: %@\n",self.dataNameArr[indexPath.section],obj]];
                [tempAttrStr setAttributes:attributeDict range:NSMakeRange(0, 3)];
                
                [showMsg appendAttributedString:tempAttrStr];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
                label.backgroundColor = [UIColor grayColor];
                label.textColor = [UIColor whiteColor];
                label.attributedText = showMsg;
                [self.bgView addSubview:label];
                
            }else{
                
                NSMutableAttributedString *tempAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  •  %@: %@\n",self.dataNameArr[idx],obj]];
                [tempAttrStr setAttributes:attributeDict range:NSMakeRange(0, 3)];
                
                [showMsg appendAttributedString:tempAttrStr];
            }
        }else{
            
            NSMutableAttributedString *tempAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  • 值%@: %@\n", (yArr.count==1)?@"":[NSString stringWithFormat:@"%zd",idx+1],obj]];
            [tempAttrStr setAttributes:attributeDict range:NSMakeRange(0, 3)];
            
            [showMsg appendAttributedString:tempAttrStr];
        }
        drawViewY += [obj floatValue];
    }];
    [showMsg deleteCharactersInRange:NSMakeRange(showMsg.length-1, 1)];
    if (drawViewY!=0) {
        float scale = [[self valueForKey:@"chartScale"] floatValue];
        drawViewY = self.contentView.frame.size.height - drawViewY/yArr.count * scale - WZCChartBottomHeight;
    }else{
        drawViewY = WZCChartTopHeight;
    }
    //显示数值的视图
    UILabel *markerView = [[UILabel alloc] init];
    //    markerView.text = showMsg;
    markerView.numberOfLines = 0;
    markerView.backgroundColor = self.markerBgColor;
    markerView.textColor = self.markerTextColor;
    markerView.layer.cornerRadius = 3.0f;
    markerView.layer.masksToBounds = YES;
    markerView.font = [UIFont systemFontOfSize:14];
    markerView.attributedText = showMsg;
    [markerView sizeToFit];
    //处理显示
    CGFloat maxX = self.contentView.contentOffset.x + self.contentView.frame.size.width;
    CGFloat maxY = self.contentView.frame.size.height - WZCChartBottomHeight;
    CGRect frame = markerView.frame;
    frame.origin.x = drawX;
    frame.origin.y = drawViewY;
    frame.size.height += 10.0f;
    frame.size.width += 10.0f;
    if (CGRectGetMaxX(frame) > maxX) {
        frame.origin.x -= (frame.size.width + 3.0f); //3 这个数值是更改显示值的黑框与线的距离(下面也是)
    }else{
        frame.origin.x += 3.0f;
    }
    if (CGRectGetMaxY(frame) > maxY) {
        frame.origin.y = maxY - frame.size.height;
    }
    if (frame.origin.y<0) {
        frame.origin.y = 0;
    }
    markerView.frame = frame;
    _markerView = markerView;
    [self.contentView addSubview:markerView];
}

- (CGFloat)distanceP1:(CGPoint)p1 toP2:(CGPoint)p2{
    CGFloat x2 = (p1.x - p2.x)*(p1.x - p2.x);
    return sqrt(x2);
}

- (void)initChart{}

//- (NSArray *)chartColors{
//    if (_chartColors&&_chartColors.count == self.yValuesArray.count) {
//        return _chartColors;
//    }
//    NSMutableArray *colors = [NSMutableArray arrayWithArray:_chartColors];
//    for (int i = (int)_chartColors.count; i < self.yValuesArray.count; i ++) {
//        [colors addObject:[self randomColor]];
//        UIColor *color = [self randomColor];
////        UIColor *color = [UIColor colorWithRed:i*30/255 green:i*30/255 blue:i*30/255 alpha:1.0];
//        [colors addObject:color];
//    }
//    _chartColors = colors;
//    return _chartColors;
//}

//// sihua 线的颜色
//- (UIColor *)randomColor{
////    NSArray *colorArr = @[[UIColor blueColor], [UIColor grayColor], [UIColor whiteColor],[UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor]];
////    return colorArr;
//    return [UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255.0f alpha:1];
//}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView.bounces = scrollView.contentOffset.x > 0;
}

@end


