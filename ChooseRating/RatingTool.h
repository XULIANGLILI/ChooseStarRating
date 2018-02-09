//
//  RatingTool.h
//  ChooseRating
//
//  Created by 梁立 on 2018/2/9.
//  Copyright © 2018年 XLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatingTool;
@protocol RatingToolDelegate <NSObject>
@optional
/**
 评分
 @param tool 工具条
 @param rating 当前评星
 */
- (void)ratingTool:(RatingTool *)tool currentRating:(float)rating;
@end

/// 表情类型
typedef NS_ENUM(NSUInteger, RatingType) {
    RatingTypeSlidingAndHalf = 0,        // 可滑动可半选
    RatingTypeSlidingAndFull = 1,         // 可滑动不可半选
    RatingTypeNOslidingAndHalf = 2,      // 不可滑动可半选
    RatingTypeNOSlidingAndFull = 3,       // 不可滑动不可半选
    RatingTypeIndicator = 4,             // 作为指示器
};

@interface RatingTool : UIView

/**
 初始化设置评星
 @param frame 工具条尺寸
 @param type 类型
 @param number 数量
 @param size 尺寸
 @param left 距左
 @param normal 未选中图片名称
 @param halfSelected 选中图片名称
 @param fullSelected 半选中图片名称
 @param delegate 代理
 */
- (instancetype)initWithFrame:(CGRect)frame ratingType:(RatingType)type starsNumber:(NSInteger)number currentRating:(float)rating ratingSize:(CGSize)size fromLeft:(CGFloat)left setImageNormal:(NSString *)normal halfSelected:(NSString *)halfSelected fullSelected:(NSString *)fullSelected WithDelegate:(id<RatingToolDelegate>)delegate;

/**
 设置评分

 @param rating 评分
 */
- (void)setDisplayRating:(float)rating;

/**
 获取当前评星
 */
- (float)getCurrentRating;
@end
