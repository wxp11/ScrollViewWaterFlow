//
//  CustomCell.h
//  ScrollView瀑布流
//
//  Created by WangXiaopeng on 16/5/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "WaterflowViewCell.h"
@class WaterflowView, Model;

@interface CustomCell : WaterflowViewCell
+ (instancetype)cellWithWaterflowView:(WaterflowView *)waterflowView;
@property (nonatomic, strong) Model *model;
@end
