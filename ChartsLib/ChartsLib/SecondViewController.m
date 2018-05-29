//
//  SecondViewController.m
//  ChartsLib
//
//  Created by 邬志成 on 2017/5/27.
//  Copyright © 2017年 邬志成. All rights reserved.
//

#import "SecondViewController.h"
#import "XCharts.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet XLineChartView *lineChartView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    [self.lineChartView strokeChart];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self setChartData:self.lineChartView];
    
    self.lineChartView.animationEnable = YES;
    
    self.lineChartView.animationDuration = 5;
    
    [self.lineChartView strokeChart];
}
                                                                        

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setChartData:(XBaseChartView *)chartView{
    NSMutableArray *xTitles = [NSMutableArray array];
    NSMutableArray *yValues = [NSMutableArray array];
    for (int i = 0 ; i < 1; i ++) {
        NSMutableArray *yArr = [NSMutableArray array];
        int max = arc4random_uniform(1000)+300;
        for (int j = 0; j < 200; j ++) {
            if(i == 0) [xTitles addObject:[NSString stringWithFormat:@"第%d个",j]];
            [yArr addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(max)]];
        }
        [yValues addObject:yArr];
    }
    chartView.xTitles = xTitles;    //设置X
    chartView.yValuesArray = yValues;  //设置Y
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
