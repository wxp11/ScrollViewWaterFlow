//
//  WaterflowView.m
//  ScrollView瀑布流
//
//  Created by WangXiaopeng on 16/5/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "WaterflowView.h"
#import "WaterflowViewCell.h"
#define WaterflowViewDefaultNumberOfColumns 3//默认列数
#define WaterflowViewDefaultCellHeight 70//默认高度
#define WaterflowViewDefaultMargin 8//默认间距

@interface WaterflowView ()
/**
 *  所有cell的frame数据
 */
@property (nonatomic, strong) NSMutableArray *cellFramesArray;
/**
 *  正在展示的cell
 */
//存放在scrollView的cell，之所以用字典，因为可以用key来存取，方便添加和移除
//当，发现当前key值的cell在字典里面（也就是还在scrollView上，也许正在屏幕上，也许没有在屏幕上，但在scrollView上），直接从字典中取出即可，如果字典中不存在
//则去缓存池里取，如果缓存池没有，那么创建cell
@property (nonatomic, strong) NSMutableDictionary *displayingCellsDic;
/**
 *  缓存池(用Set， 存放离开屏幕的cell)
 */
@property (nonatomic, strong) NSMutableSet *reusableCellsSet;
@end

@implementation WaterflowView
@dynamic delegate;

#pragma mark -- 懒加载开空间
- (NSMutableArray *)cellFramesArray {
    if (_cellFramesArray == nil) {
        self.cellFramesArray = [NSMutableArray array];
    }
    return _cellFramesArray;
}
- (NSMutableDictionary *)displayingCellsDic {
    if (_displayingCellsDic == nil) {
        self.displayingCellsDic = [NSMutableDictionary dictionary];
    }
    return _displayingCellsDic;
}
- (NSMutableSet *)reusableCellsSet {
    if (_reusableCellsSet == nil) {
        self.reusableCellsSet = [NSMutableSet set];
    }
    return _reusableCellsSet;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

//在一个子视图将要被添加到另一个视图的时候发送此消息。当view将要移到superView时，刷新数据，避免手动刷新(第一次进入该页面时自动刷新数据)
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self reloadData];
}


#pragma mark -- 公共接口
/**
 *  cell的宽度
 */
- (CGFloat)cellWidth {
    //总列数
    NSInteger numberOfColumns = [self numberOFColumns];
    CGFloat leftM = [self marginForType:(WaterflowViewMarginTypeLeft)];
    CGFloat rightM = [self marginForType:(WaterflowViewMarginTypeRight)];
    CGFloat columnM = [self marginForType:(WaterflowViewMarginTypeColumn)];
    return (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
}


/**
 *  刷新数据
 */
- (void)reloadData {
    //清空之前的所有数据
    //移除正在显示的cell
    [self.displayingCellsDic.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];//让字典中每一个对象都调用同一个方法
    [self.displayingCellsDic removeAllObjects];
    [self.cellFramesArray removeAllObjects];
    [self.reusableCellsSet removeAllObjects];
    
    //cell的总数 要想成为数据源 此方法必须实现
    NSInteger numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
    //总列数
    NSInteger numberOfColumns = [self numberOFColumns];
    //间距
    CGFloat topM = [self marginForType:(WaterflowViewMarginTypeTop)];
    CGFloat bottomM = [self marginForType:(WaterflowViewMarginTypeBottom)];
    CGFloat leftM = [self marginForType:(WaterflowViewMarginTypeLeft)];
    CGFloat columnM = [self marginForType:(WaterflowViewMarginTypeColumn)];
    CGFloat rowM = [self marginForType:(WaterflowViewMarginTypeRow)];
    //cell宽度
    CGFloat cellW = [self cellWidth];
    
    //用一个C语言数组存放所有列的最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    //计算所有cell的frame
    for (int i = 0; i < numberOfCells; i++) {
        //cell处在第几列(最短的一列)
        NSInteger cellColumn = 0;
        //cell所处那列的最大Y值(最短那列的最大Y值)
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        //求出最短的一列
        for (int j = 1; j <numberOfColumns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        //询问代理i位置的高度
        CGFloat cellH = [self heightAtIndex:i];
        //cell的位置
        CGFloat cellX = leftM + cellColumn * (cellW + columnM);
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) {//首行
            cellY = topM;
        } else {
            cellY = maxYOfCellColumn + rowM;
        }
        //添加frame到数组中
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFramesArray addObject:[NSValue valueWithCGRect:cellFrame]];
        //更新最短那边列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
        //设置contentSize
        CGFloat contentH = maxYOfColumns[0];
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] > contentH) {
                contentH = maxYOfColumns[j];
            }
        }
        contentH += bottomM;
        self.contentSize = CGSizeMake(0, contentH);
    }
}
/**
 *  当UIScrollView滚动时会调用此方法。当scrollView滚动，除了会调用它的代理方法之外，还会时时调用这个方法。所以，在这个方法里面拿到当前显示在屏幕的cell，设置尺寸~~
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    //向数据源索要对应位置的cell
    NSInteger numberOfCells = self.cellFramesArray.count;
    for (int i = 0; i < numberOfCells; i++) {
        //取出i位置的frame
        CGRect cellFrame = [self.cellFramesArray[i] CGRectValue];
        //优先从字典中取出i位置的cell
        WaterflowViewCell *cell = self.displayingCellsDic[@(i)];
        //判断i位置对应的frame在不在屏幕上(能否看见)
        if ([self isInScreen:cellFrame]) {//在屏幕上
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                //存放到字典中
                self.displayingCellsDic[@(i)] = cell;
            }
        } else {//不在屏幕上
            if (cell) {
                //从scrollView和字典中移除
                [cell removeFromSuperview];
                //这个字典是用来记录正展示在屏幕上的数组的，没有在屏幕上了，应当移除相应的cell
                [self.displayingCellsDic removeObjectForKey:@(i)];
                //存放进缓存池 既然要循环利用，那么创建了，就不应该在WaterFlowView生命周期还未结束之前被销毁，那么将之放入缓存池
                [self.reusableCellsSet addObject:cell];
            }
        }
    }
}
//需要根据标示符去缓存池找到对应的cell
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    __block WaterflowViewCell *reusableCell = nil;
    [self.reusableCellsSet enumerateObjectsUsingBlock:^(WaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    if (reusableCell) {//被用了，就从缓存池中移除
        [self.reusableCellsSet removeObject:reusableCell];
    }
    return reusableCell;
}


#pragma mark -- 私有方法
//如果数据源响应此方法 则由数据源提供列数 否则返回默认列数(比如3列)
/**
 * 总列数
 */
- (NSInteger)numberOFColumns {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    } else {
        return WaterflowViewDefaultNumberOfColumns;
    }
}

/**
 *  index位置对应的高度
 */
- (CGFloat)heightAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    } else {
        return WaterflowViewDefaultCellHeight;
    }
}
/**
 *  间距
 */
- (CGFloat)marginForType:(WaterflowViewMarginType)type {
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    } else {
        return WaterflowViewDefaultMargin;
    }
}
/**
 *  判断一个cell在不在屏幕上。判断是否在屏幕上，只需要，最大的y大于contentOffset.y，最小的y小于contentOffset.y + self高度
 */
- (BOOL)isInScreen:(CGRect)frame {
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y + self.bounds.size.height);
}

#pragma mark -- 事件处理
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) {
        return;
    }
    
    //获得触摸点
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    __block NSNumber *selectIndex = nil;
    //判断触摸点在哪个cell上，没必要遍历所有的cell，只需要遍历，当前展示在scrollView的cell
    [self.displayingCellsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, WaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
    }
}

@end
