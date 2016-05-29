//
//  WaterflowView.h
//  ScrollView瀑布流
//
//  Created by WangXiaopeng on 16/5/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    WaterflowViewMarginTypeTop,//顶部间距
    WaterflowViewMarginTypeBottom,//底部间距
    WaterflowViewMarginTypeLeft,//左边间距
    WaterflowViewMarginTypeRight,//右边间距
    WaterflowViewMarginTypeColumn, //列间距
    WaterflowViewMarginTypeRow, //行间距
} WaterflowViewMarginType;

@class WaterflowView, WaterflowViewCell;

/**
 *  数据源协议
 */
@protocol WaterflowViewDataSource <NSObject>
//要想成为dataSource 必须实现的方法：1.一共多少个数据 2.对应位置上的cell
@required
/**
 *  一共多少个数据
 */
- (NSInteger)numberOfCellsInWaterflowView:(WaterflowView *)waterflowView;

/**
 *  返回index位置对应的cell
 */
- (WaterflowViewCell *)waterflowView:(WaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

//可选方法
@optional
/**
 *  一共有多少列
 */
- (NSInteger)numberOfColumnsInWaterflowView:(WaterflowView *)waterflowView;
@end

/**
 *  代理协议
 */
@protocol WaterflowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  第index位置cell对应的高度
 */
- (CGFloat)waterflowView:(WaterflowView *)waterflowView heightAtIndex:(NSInteger)index;

/**
 *  选中第index位置的cell
 */
- (void)waterflowView:(WaterflowView *)waterflowView didSelectAtIndex:(NSInteger)index;

/**
 *  返回间距
 */
- (CGFloat)waterflowView:(WaterflowView *)waterflowView marginForType:(WaterflowViewMarginType)type;
@end


/**
 *  瀑布流控件
 */
@interface WaterflowView : UIScrollView
/**
 *  数据源
 */
@property (nonatomic, weak) id<WaterflowViewDataSource> dataSource;
/**
 *  代理
 */
@property (nonatomic, weak) id<WaterflowViewDelegate> delegate;

/**
 *  刷新数据（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）
 */
- (void)reloadData;
/**
 *  cell的宽度
 */
- (CGFloat)cellWidth;
/**
 *  根据标识去缓存池查找可循环利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end

