//
//  CustomCell.m
//  ScrollView瀑布流
//
//  Created by WangXiaopeng on 16/5/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "CustomCell.h"
#import "WaterflowView.h"
#import "UIImageView+WebCache.h"
#import "Model.h"

@interface CustomCell()
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UILabel *priceLabel;
@end

@implementation CustomCell


+ (instancetype)cellWithWaterflowView:(WaterflowView *)waterflowView
{
    static NSString *ID = @"model";
    CustomCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[CustomCell alloc] init];
        cell.identifier = ID;
    }
    return cell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor whiteColor];
        [self addSubview:priceLabel];
        self.priceLabel = priceLabel;
    }
    return self;
}

- (void)setModel:(Model *)model {
    _model = model;
    
    self.priceLabel.text = model.price;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.img]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
    CGFloat priceX = 0;
    CGFloat priceH = 25;
    CGFloat priceY = self.bounds.size.height - priceH;
    CGFloat priceW = self.bounds.size.width;
    self.priceLabel.frame = CGRectMake(priceX, priceY, priceW, priceH);
}
@end
