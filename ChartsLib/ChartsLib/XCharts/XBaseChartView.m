//
//  BaseChartView.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/4/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "XBaseChartView.h"


@interface XBaseChartView()<UIScrollViewDelegate>

/** y 坐标 view */
@property (nonatomic,weak) UIView *y_coor_view;

/** x 坐标 view */
@property (nonatomic,weak) UIScrollView *x_coor_view;

/** y刻度的间距值 */
@property (nonatomic,assign) CGFloat yStepValue;

/** 获取最大的Y */
@property (nonatomic,assign) CGFloat maxY;

/** X轴标签数组 */
@property (nonatomic,strong) NSMutableArray<UILabel *>*xLabArr;

/** X轴的layer层 */
@property (nonatomic,weak) CAShapeLayer *xCoordsLayer;

/** 比例值 */
@property (nonatomic,assign,readonly) CGFloat chartScale;

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
@property (nonatomic,weak) UILabel *unitLab;

/** 最小的Y */
@property (nonatomic,assign) CGFloat minY;

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

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (instancetype)init{
    NSAssert(NO, @"请使用 initWithFrame: 初始化方法");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initDefaultConfig];
        [self initViews];
    }
    return self;
}

- (void)initDefaultConfig{
    self.yLabNumber = 8;
    self.coordColor = [UIColor blackColor];
    self.coordWidth = 2.0f;
    self.labFont = [UIFont systemFontOfSize:11];
    self.xLabspace = 0;
    self.animationEnable = YES;
    self.animationDuration = 3.0f;
    self.yAssistLineEnable = YES;
    self.yAssistLineWidth = 1.0f;
    self.yAssistLineColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1.00];
    self.xAssistLineEnable = YES;
    self.xAssistLineWidth = 1.0f;
    self.xAssistLineColor = [UIColor colorWithRed:0.945 green:0.945 blue:0.945 alpha:1.00];
    //提示 默认配置
    self.markerBgColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.80];
    self.markerTextColor = [UIColor whiteColor];
    self.markerLineWidth = 1.5f;
    self.markerLineColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.00];
    
    self.scaleType = XChartViewScaleTypeFollowGesture;
}

- (void)initViews{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    _contentView = scrollView;
    [self addSubview:scrollView];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self addConstraints:@[top,right,bottom]];
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.contentView addGestureRecognizer:pin];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.contentView addGestureRecognizer:tap];
    
    //    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    //    [self.contentView addGestureRecognizer:panGesture];
    
    UILabel *noDataLab = [[UILabel alloc] init];
    noDataLab.text = @"没有数据";
    noDataLab.textColor = [UIColor colorWithRed:0.859 green:0.318 blue:0.286 alpha:1.00];
    [self addSubview:noDataLab];
    _noDataLab = noDataLab;
}

- (void)strokeChart{
    [self.y_coor_view removeFromSuperview];
    [self.markerView removeFromSuperview];
    [self.markerLayer removeFromSuperlayer];
    if (![self checkData]) {
        self.noDataLab.hidden = NO;
        self.userInteractionEnabled = NO;
        self.contentView.hidden = YES;
        return;
    }
    self.contentView.hidden = NO;
    self.userInteractionEnabled = YES;
    self.noDataLab.hidden = YES;
    __block CGFloat y_Max = -CGFLOAT_MAX;
    __block CGFloat y_Min = CGFLOAT_MAX;
    [_yValuesArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (y_Max < [obj floatValue]) {
                y_Max = [obj floatValue];
            }
            if ([obj floatValue]<y_Min) {
                y_Min = [obj floatValue];
            }
        }];
    }];
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
    
    
    if (y_Max - y_Min == 0) {
        y_Max = 0;
    }
    
    _yStepValue = (y_Max-y_Min) / self.yLabNumber;
    
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
    if (y_Max - y_Min == 0) {
        y_Max = 1;
        y_Min = 0;
    }
    
    _chartScale = (self.frame.size.height - WZCChartTopHeight - WZCChartBottomHeight)/(y_Max - y_Min);
    _maxY = y_Max;
    _minY = y_Min;
    [self drawY];
    [self drawX];
    if (self.yAssistLineEnable) {
        [self drawYAssistLine:self.contentView.contentSize];
    }
    [self initChart];
}


- (BOOL)checkData{
    self.noDataLab.hidden = NO;
    [self.noDataLab sizeToFit];
    self.noDataLab.center = CGPointMake(self.frame.size.width*0.5f, self.frame.size.height * 0.5f);
    if (self.xTitles.count==0) {
        return NO;
    }
    __block BOOL flag = NO;
    if (self.yValuesArray == nil) {
        return NO;
    }
    [self.yValuesArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
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
    
    for (int i = 0; i < self.yValuesArray.count; i ++) {
        id yObj = self.yValuesArray[i];
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
    UIView *yCoorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width + arrowWidth * 3 + self.coordWidth, self.frame.size.height)]; //初始化y轴的view
    _y_coor_view = yCoorView;
    UILabel *unitLab = [[UILabel alloc] init];
    unitLab.text = self.yUnit;
    unitLab.textAlignment = NSTextAlignmentCenter;
    unitLab.font = self.labFont;
    unitLab.textColor = self.coordColor;
    [unitLab sizeToFit];
    CGPoint uCenter = unitLab.center;
    uCenter.x = yCoorView.center.x;
    unitLab.center = uCenter;
    _unitLab = unitLab;
    [yCoorView addSubview:unitLab];
    
    UIBezierPath *yCoordsPath = [UIBezierPath bezierPath]; //绘制Y
    [yCoordsPath moveToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, yCoorView.frame.size.height - WZCChartBottomHeight + self.coordWidth * 0.5f)];
    [yCoordsPath addLineToPoint:CGPointMake(CGRectGetMaxX(yCoorView.frame) - self.coordWidth - arrowWidth, 0)];
    for (int i = 0 ; i < self.yLabNumber + 1; i ++) {
        CGFloat y = self.frame.size.height - i * _yStepValue * _chartScale - WZCChartBottomHeight;
        UILabel *yLab = [[UILabel alloc] initWithFrame:CGRectMake(0, y - size.height/2.0f, size.width, size.height)];
        yLab.font = self.labFont;
        NSString *yLabValueStr;
        if ((int)(i * _yStepValue+self.minY) == (i * _yStepValue+self.minY)) {
            yLabValueStr = [NSString stringWithFormat:@"%d",(int)(i * _yStepValue+self.minY)];
        }else{
            yLabValueStr = [NSString stringWithFormat:@"%0.2f",i * _yStepValue+self.minY];
        }
        yLab.text = yLabValueStr;
        yLab.textAlignment = NSTextAlignmentRight;
        yLab.textColor = self.coordColor;
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
    yCoordsLayer.strokeColor = self.coordColor.CGColor;
    yCoordsLayer.lineWidth = self.coordWidth;
    yCoordsLayer.fillColor = [UIColor clearColor].CGColor;
    [self removeConstraint:contentLayoutLeft];
    contentLayoutLeft = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:yCoorView.frame.size.width - arrowWidth - self.coordWidth];
    [self addConstraint:contentLayoutLeft];
    [self.y_coor_view.layer addSublayer:yCoordsLayer];
    [self addSubview:yCoorView];
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
        CGSize objSize = [obj sizeWithAttributes:@{NSFontAttributeName:self.labFont}];
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
            UILabel *xLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - WZCChartBottomHeight + self.coordWidth, maxWidth, WZCChartBottomHeight - self.coordWidth)];
            xLab.font = self.labFont;
            xLab.textAlignment = NSTextAlignmentCenter;
            xLab.text = self.xTitles[i];
            xLab.hidden = YES;
            xLab.textColor = self.coordColor;
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
    [xCoordsPath addLineToPoint:CGPointMake(self.contentView.contentSize.width - 3,0)];
    //绘制箭头
    CGFloat arrowWidth = self.coordWidth * 3;
    UIBezierPath *xArrowPath = [UIBezierPath bezierPath];
    [xArrowPath moveToPoint:CGPointMake(self.contentView.contentSize.width - arrowWidth*1.5f - 3,  - arrowWidth)];
    [xArrowPath addLineToPoint:CGPointMake(self.contentView.contentSize.width - 3, 0)];
    [xArrowPath addLineToPoint:CGPointMake(self.contentView.contentSize.width - arrowWidth*1.5f - 3,arrowWidth)];
    [xCoordsPath appendPath:xArrowPath];
    
    CAShapeLayer *xCoordsLayer = [[CAShapeLayer alloc] init];
    xCoordsLayer.frame = CGRectMake(0, self.frame.size.height - WZCChartBottomHeight, self.contentView.contentSize.width, WZCChartBottomHeight);
    xCoordsLayer.path = xCoordsPath.CGPath;
    xCoordsLayer.strokeColor = self.coordColor.CGColor;
    xCoordsLayer.fillColor = [UIColor clearColor].CGColor;
    xCoordsLayer.lineWidth = self.coordWidth;
    [self.contentView.layer addSublayer:xCoordsLayer];
    _xCoordsLayer = xCoordsLayer;
}




- (void)drawXassistLine{
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

- (void)drawYAssistLine:(CGSize)size{
    [self.yAssistLayer removeFromSuperlayer];
    UIBezierPath *yAssistPath = [UIBezierPath bezierPath];
    for (int i = 1 ; i < self.yLabNumber + 1; i ++) {
        CGFloat y = self.frame.size.height - i * _yStepValue * _chartScale - WZCChartBottomHeight;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, y)];
        CGFloat maxX = [self isKindOfClass:NSClassFromString(@"XBarChartView")]?(self.contentView.contentSize.width - WZCChartRight):self.xLabArr.lastObject.center.x;
        [path addLineToPoint:CGPointMake(maxX, y)];
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
    markerLayer.strokeColor = self.markerLineColor.CGColor;
    _markerLayer = markerLayer;
    [self.contentView.layer addSublayer:markerLayer];
    
    if (self.yUnit==nil) {
        self.yUnit = @"";
    }
    
    //显示数值
    __block CGFloat drawViewY = 0;
    NSMutableString *showMsg = [[NSMutableString alloc] init];
    [showMsg appendFormat:@"  %@\n",title];
    [yArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.dataNameArr!=nil&&idx<self.dataNameArr.count) {
            if (indexPath) {
                [showMsg appendFormat:@"  %@: %@ %@\n",self.dataNameArr[indexPath.section],obj,self.yUnit];
            }else{
                [showMsg appendFormat:@"  %@: %@ %@\n",self.dataNameArr[idx],obj,self.yUnit];
            }
        }else{
            [showMsg appendFormat:@"  值%@: %@ %@\n",(yArr.count==1)?@"":[NSString stringWithFormat:@"%zd",idx+1],obj,self.yUnit];
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
    markerView.text = showMsg;
    markerView.numberOfLines = 0;
    markerView.backgroundColor = self.markerBgColor;
    markerView.textColor = self.markerTextColor;
    markerView.layer.cornerRadius = 3.0f;
    markerView.layer.masksToBounds = YES;
    markerView.font = [UIFont systemFontOfSize:14];
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

- (NSArray *)chartColors{
    if (_chartColors&&_chartColors.count == self.yValuesArray.count) {
        return _chartColors;
    }
    NSMutableArray *colors = [NSMutableArray arrayWithArray:_chartColors];
    for (int i = (int)_chartColors.count; i < self.yValuesArray.count; i ++) {
        [colors addObject:[self randomColor]];
    }
    _chartColors = colors;
    return _chartColors;
}

- (UIColor *)randomColor{
    return [UIColor colorWithRed:arc4random_uniform(255)/255.0f green:arc4random_uniform(255)/255.0f blue:arc4random_uniform(255)/255.0f alpha:1];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    scrollView.bounces = scrollView.contentOffset.x > 0;
}

@end
