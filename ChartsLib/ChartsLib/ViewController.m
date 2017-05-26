//
//  ViewController.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/4/25.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "ViewController.h"
#import "XCharts.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lineTypeSwith;
@property (weak, nonatomic) IBOutlet UITextField *numberCount;   //每组多少数据
@property (weak, nonatomic) IBOutlet UITextField *sectionCount;  //多少组数据
/** chart view */
@property (nonatomic,weak) XBaseChartView *chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
        [self barOrLineType:nil];
    });
}
- (IBAction)lineTypeAction:(UISegmentedControl *)sender {
    if (_lineTypeSwith.selectedSegmentIndex == 0) { //曲线
        ((XLineChartView *)_chartView).chartType = XChartLineTypeCurve;
    }else{
        ((XLineChartView *)_chartView).chartType = XChartLineTypePolyline;
    }
    [_chartView strokeChart];
}
- (IBAction)barOrLineType:(UISegmentedControl *)sender {
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    XBaseChartView *chartView;
    if (sender.selectedSegmentIndex==0) { //折线图
        chartView = [[XLineChartView alloc] initWithFrame:self.contentView.bounds];
        if (_lineTypeSwith.selectedSegmentIndex == 0) { //曲线
            ((XLineChartView *)chartView).chartType = XChartLineTypeCurve;//设置绘制类型为曲线
        }else{
            ((XLineChartView *)chartView).chartType = XChartLineTypePolyline; //设置绘制类型为折现
        }
        ((XLineChartView *)chartView).showDot = YES;   //设置显示圆点
        ((XLineChartView *)chartView).gradientEnable = YES;  //设置启用渐变填充
    }else{   //柱状图
        chartView = [[XBarChartView alloc] initWithFrame:self.contentView.bounds];
    }
    self.lineTypeSwith.hidden = sender.selectedSegmentIndex==1;
    _chartView = chartView;
    [self setChartData:chartView];
    [self.contentView addSubview:chartView];
    [chartView strokeChart];
    chartView.scaleType = XChartViewScaleTypeFollowGesture;
    
}
- (IBAction)reStrock:(UIButton *)sender {
    [self setChartData:self.chartView];
    [self.chartView strokeChart];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
    
}

- (IBAction)sureAction:(id)sender {
    [self.view endEditing:YES];
    [self reStrock:nil];
}


- (void)setChartData:(XBaseChartView *)chartView{
    NSMutableArray *xTitles = [NSMutableArray array];
    NSMutableArray *yValues = [NSMutableArray array];
    for (int i = 0 ; i < [self.sectionCount.text integerValue]; i ++) {
        NSMutableArray *yArr = [NSMutableArray array];
        int max = arc4random_uniform(1000)+300;
        for (int j = 0; j < [self.numberCount.text integerValue]; j ++) {
            if(i == 0) [xTitles addObject:[NSString stringWithFormat:@"第%d个",j]];
            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
        }
        [yValues addObject:yArr];
    }
    chartView.xTitles = xTitles;    //设置X
    chartView.yValuesArray = yValues;  //设置Y
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

@end
