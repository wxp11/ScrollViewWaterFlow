//
//  ViewController.m
//  ScrollView瀑布流
//
//  Created by WangXiaopeng on 16/5/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "ViewController.h"
#import "WaterflowView.h"
#import "Model.h"
#import "CustomCell.h"//继承自WaterflowViewCell
@interface ViewController ()<WaterflowViewDataSource,WaterflowViewDelegate>
@property (nonatomic, strong) WaterflowView *waterflowView;//瀑布流控件
@property (nonatomic, strong) NSMutableArray *dataArray;//数据源
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];//数据源开空间
    [self readData];//读取数据
    [self createWaterflowView];//配置瀑布流控件
}
#pragma mark -- 读取数据
- (void)readData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    for (NSDictionary *dic in array) {
        Model *model = [[Model alloc] init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
}
#pragma mark -- 创建瀑布流控件
- (void)createWaterflowView {
    self.waterflowView = [[WaterflowView alloc] initWithFrame:self.view.bounds];
    _waterflowView.dataSource = self;
    _waterflowView.delegate = self;
    _waterflowView.backgroundColor = [UIColor redColor];
    // 跟随着父控件的尺寸而自动伸缩
    _waterflowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_waterflowView];
}
#pragma mark -- 数据源方法
//个数
- (NSInteger)numberOfCellsInWaterflowView:(WaterflowView *)waterflowView {
    return self.dataArray.count;
}
//列数(如不实现，默认3列)
- (NSInteger)numberOfColumnsInWaterflowView:(WaterflowView *)waterflowView {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // 竖屏
        return 3;
    } else {
        //横屏
        return 5;
    }
}

//cell
- (WaterflowViewCell *)waterflowView:(WaterflowView *)waterflowView cellAtIndex:(NSUInteger)index {
    CustomCell *cell = [CustomCell cellWithWaterflowView:waterflowView];
    cell.model = [self.dataArray objectAtIndex:index];
    return cell;
}
//屏幕旋转完毕 重新加载数据
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //    NSLog(@"屏幕旋转完毕");
    [self.waterflowView reloadData];
}
#pragma mark -- 代理方法
//高度
- (CGFloat)waterflowView:(WaterflowView *)waterflowView heightAtIndex:(NSInteger)index {
    //取出index位置的model
    Model *model = [self.dataArray objectAtIndex:index];
    //根据图片的宽高比 算出cell的高度
    return waterflowView.cellWidth * model.h / model.w;
}
//间距(可选，如不实现，默认为8)
//- (CGFloat)waterflowView:(WaterflowView *)waterflowView marginForType:(WaterflowViewMarginType)type {
//    
//}

//点击cell
- (void)waterflowView:(WaterflowView *)waterflowView didSelectAtIndex:(NSInteger)index {
    Model *model = self.dataArray[index];
    NSLog(@"点击了第%ld个cell,价格是%@",index,model.price);
}


@end



