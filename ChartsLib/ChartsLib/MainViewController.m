//
//  MainViewController.m
//  ChartsLib
//
//  Created by Pinken on 2017/8/22.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "MainViewController.h"
#import "XCharts.h"

@interface MainViewController ()

@property (strong, nonatomic) UIView *contentView;
// sihua 线条的类型
//@property (strong, nonatomic) UISegmentedControl *lineTypeSwith;
@property (strong, nonatomic) UITextField *numberCount;   //每组多少数据
@property (strong, nonatomic) UITextField *sectionCount;  //多少组数据
/** chart view */
@property (nonatomic,weak) XBaseChartView *chartView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.backgroundColor = [UIColor blueColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view layoutIfNeeded];
//        [self barOrLineType:nil];
        [self initChartView];
    });
    
//    UIButton *testBtn = [[UIButton alloc] init];
//    testBtn.frame = CGRectMake(100, 100, 90, 45);
//    testBtn.backgroundColor = [UIColor redColor];
//    [testBtn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:testBtn];
    
}

- (void)clickBtn {
    
    NSMutableArray *xTitles = [NSMutableArray array];
    NSMutableArray *yValues = [NSMutableArray array];
    //    for (int i = 0 ; i < [self.sectionCount.text integerValue]; i ++) {
    //        NSMutableArray *yArr = [NSMutableArray array];
    //        int max = arc4random_uniform(1000)+300;
    //        for (int j = 0; j < [self.numberCount.text integerValue]; j ++) {
    //            if(i == 0) [xTitles addObject:[NSString stringWithFormat:@"第%d个",j]];
    //            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
    //        }
    //        [yValues addObject:yArr];
    //    }
    
    for (int i = 0 ; i < 6; i ++) {
        NSMutableArray *yArr = [NSMutableArray array];
        for (int j = 0; j < 15; j ++) {
            //            if(i == 0) {
            //                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
            //            }
            //            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
            
            // 调试用
            if(i == 0)
                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
            
            [yArr addObject:[NSString stringWithFormat:@"%d",-(j+i*10+120)]];
            //            [yArr addObject:[NSString stringWithFormat:@"%d",j+10+100]];
            
        }
        [yValues addObject:yArr];
        
        
        //        [self.yChartArr replaceObjectAtIndex:[self.reportDatas indexOfObject:@"Grid"] withObject:yArr];
        
        NSLog(@"yValues -- %@", yValues);
    }
    
    NSArray *arr = @[@"10", @"50", @"30", @"69", @"80", @"100", @"90", @"120", @"150", @"135", @"170", @"155", @"300", @"189", @"179"];
    [yValues replaceObjectAtIndex:2 withObject:arr];
    
    
    //    for (int i = 0 ; i < 6; i ++) {
    //        NSMutableArray *yArr = [NSMutableArray array];
    //        int max = arc4random_uniform(1000)+300;
    //        for (int j = 0; j < 15; j ++) {
    ////            if(i == 0) {
    ////                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
    ////            }
    ////            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
    //
    //            // 调试用
    //            if(i == 0)
    //                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
    //                [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
    //        }
    //        [yValues addObject:yArr];
    //        NSLog(@"yValues -- %@", yValues);
    //    }
    
    //    chartView.dataNameArr = [NSMutableArray arrayWithArray:@[@"11", @"22", @"33", @"44", @"55", @"66"]] ;
    
    self.chartView.dataNameArr = [NSMutableArray arrayWithArray:@[@"SOC", @"Battery", @"Grid", @"Generator", @"Load", @"Solar"]] ;
    
    self.chartView.xTitles = xTitles;    //设置X
    self.chartView.xDetailTitles = xTitles;
    self.chartView.yValuesArray = yValues;  //设置Y
//    self.chartView.yUnit = @"Power(kW)";
//    self.chartView.rYUnit = @"SOC(%)";
//    self.chartView.chartTitle = @"图表";
    [self.chartView strokeChart];
}

- (void)initChartView {
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(15, 200, [UIScreen mainScreen].bounds.size.width - 30, 300)];
    // 230 230 250
    self.contentView.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:250/255.f alpha:1];
//    self.contentView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.contentView];
    
    // 设置绘制类型为曲线
    XBaseChartView *chartView;
    chartView = [[XLineChartView alloc] initWithFrame:self.contentView.bounds];
    ((XLineChartView *)chartView).chartType = XChartLineTypeCurve;
//    [_chartView strokeChart];
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    XBaseChartView *chartview;
//    // 设置绘制类型为曲线
//    ((XLineChartView *)_chartView).chartType = XChartLineTypeCurve;
    //设置显示圆点
    ((XLineChartView *)chartView).showDot = YES;
    //设置不启用渐变填充
    ((XLineChartView *)chartView).gradientEnable = NO;
    
    _chartView = chartView;
    
    chartView.showLineLeColor = [UIColor whiteColor];
    chartView.hideLineLeColor = [UIColor grayColor];
    
    [self setChartData:self.chartView];
    [self.contentView addSubview:self.chartView];
    [self.chartView strokeChart];
    self.chartView.scaleType = XChartViewScaleTypeFollowGesture;
    
}

- (void)setChartData:(XBaseChartView *)chartView{
    NSMutableArray *xTitles = [NSMutableArray array];
    NSMutableArray *yValues = [NSMutableArray array];
//    for (int i = 0 ; i < [self.sectionCount.text integerValue]; i ++) {
//        NSMutableArray *yArr = [NSMutableArray array];
//        int max = arc4random_uniform(1000)+300;
//        for (int j = 0; j < [self.numberCount.text integerValue]; j ++) {
//            if(i == 0) [xTitles addObject:[NSString stringWithFormat:@"第%d个",j]];
//            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
//        }
//        [yValues addObject:yArr];
//    }
    
    for (int i = 0 ; i < 6; i ++) {
        NSMutableArray *yArr = [NSMutableArray array];
        for (int j = 0; j < 15; j ++) {
            //            if(i == 0) {
            //                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
            //            }
            //            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
            
            // 调试用
            if(i == 0)
                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
            
            [yArr addObject:[NSString stringWithFormat:@"%d",-(j+i*10+120)]];
//            [yArr addObject:[NSString stringWithFormat:@"%d",j+10+100]];

        }
        [yValues addObject:yArr];
        

//        [self.yChartArr replaceObjectAtIndex:[self.reportDatas indexOfObject:@"Grid"] withObject:yArr];

        NSLog(@"yValues -- %@", yValues);
    }
    
    NSArray *arr = @[@"10", @"50", @"30", @"69", @"80", @"100", @"90", @"120", @"150", @"135", @"170", @"155", @"300", @"189", @"179"];
    [yValues replaceObjectAtIndex:2 withObject:arr];
    
//    for (int i = 0 ; i < 6; i ++) {
//        NSMutableArray *yArr = [NSMutableArray array];
//        int max = arc4random_uniform(1000)+300;
//        for (int j = 0; j < 15; j ++) {
////            if(i == 0) {
////                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
////            }
////            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
//
//            // 调试用
//            if(i == 0)
//                [xTitles addObject:[NSString stringWithFormat:@"X点%d",j]];
//                [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
//        }
//        [yValues addObject:yArr];
//        NSLog(@"yValues -- %@", yValues);
//    }
    
//    chartView.dataNameArr = [NSMutableArray arrayWithArray:@[@"11", @"22", @"33", @"44", @"55", @"66"]] ;
    
    chartView.dataNameArr = [NSMutableArray arrayWithArray:@[@"Line1", @"Line2", @"Line3", @"Line4", @"Line5", @"Line6"]] ;
    
    chartView.xTitles = xTitles;    //设置X
    chartView.yValuesArray = yValues;  //设置Y
    chartView.yUnit = @"Unit1(s)";
    chartView.rYUnit = @"Unit2(k)";
    chartView.chartTitle = @"Title";
    chartView.rYIndexArr = @[[NSNumber numberWithUnsignedInteger:2]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

