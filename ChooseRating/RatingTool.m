//
//  RatingTool.m
//  ChooseRating
//
//  Created by 梁立 on 2018/2/9.
//  Copyright © 2018年 XLL. All rights reserved.
//

#import "RatingTool.h"

@interface RatingTool ()

@property (nonatomic,weak) id<RatingToolDelegate> delegate;
@property (nonatomic,strong) NSMutableArray<UIImageView *>* ratingArray;
@end

@implementation RatingTool {
    float _lastRating;     // 最终评星数
    NSInteger _starsNumber;       // 星星数
    CGFloat _toolWidth;    // 工具条宽
    CGFloat _toolHeight;   // 工具条高
    CGFloat _leftSpace;    // 左侧距离
    CGFloat _space;        // 间距
    CGSize _itemSize;      // 星星尺寸
    RatingType _type;      // 类型
    
    UIImage *_normalImage;
    UIImage *_halfSelectedImage;
    UIImage *_fullSelectedImage;
}


- (instancetype)initWithFrame:(CGRect)frame ratingType:(RatingType)type starsNumber:(NSInteger)number currentRating:(float)rating ratingSize:(CGSize)size fromLeft:(CGFloat)left setImageNormal:(NSString *)normal halfSelected:(NSString *)halfSelected fullSelected:(NSString *)fullSelected WithDelegate:(id<RatingToolDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _type = type;
        _starsNumber = number;
        _leftSpace = left;
        _itemSize = size;
        
        _lastRating = 0.0;
        
        _normalImage = [UIImage imageNamed:normal];
        _fullSelectedImage = [UIImage imageNamed:fullSelected];
        _halfSelectedImage = (halfSelected.length == 0 || type == RatingTypeSlidingAndFull || type == RatingTypeNOSlidingAndFull) ? _fullSelectedImage : [UIImage imageNamed:halfSelected];
        
        self.delegate = delegate;
        
        _toolWidth = frame.size.width;
        _toolHeight = frame.size.height;
        
        if (_itemSize.height > _toolHeight) {   // 高度有问题时，调整高度与宽度
            _itemSize.height = _toolHeight;
            _itemSize.width = _itemSize.height;
        }
        _space = 0.00;
        if (_toolWidth >= left + _starsNumber * _itemSize.width) {   // 满足条件
            _space = (_toolWidth - (left + _starsNumber * _itemSize.width)) / (_starsNumber - 1);
        }else if (_toolWidth >= _starsNumber * _itemSize.width) { // 先取消左边边距，使等距
            _space = (_toolWidth - _starsNumber * _itemSize.width) / _starsNumber;
            _leftSpace = _space;
        }else {
            _leftSpace = 0.00;
            _space = 5.00;
            _itemSize.width = (_toolWidth - (_starsNumber - 1) * 5.00) / _starsNumber;
            _itemSize.height = _itemSize.width;
        }
        
        _ratingArray = [NSMutableArray array];
        for (NSInteger i = 0; i < _starsNumber; i ++ ) {
            UIImageView *ratingImageView = [[UIImageView alloc]initWithImage:_normalImage];
            ratingImageView.frame = CGRectMake(_leftSpace + i * (_itemSize.width + _space), (_toolHeight - _itemSize.height) / 2, _itemSize.width, _itemSize.height);
            [self addSubview:ratingImageView];
            ratingImageView.contentMode = UIViewContentModeScaleAspectFit;
            ratingImageView.userInteractionEnabled = NO;
            [_ratingArray addObject:ratingImageView];
        }
        
        [self setDisplayRating:rating];
    }
    return self;
    
}

-(void)setDisplayRating:(float)rating {
    for (UIImageView *imageView in _ratingArray) {  // 先全部设置为未选中
        imageView.image = _normalImage;
    }
    if (rating > _starsNumber) { // 防止计算错误
        rating = _starsNumber;
    }
    
    if (_type == RatingTypeSlidingAndFull || _type == RatingTypeNOSlidingAndFull) { // 不存在半星
        rating = ceilf(rating);
    }
    
    {
        NSInteger upRating = ceilf(rating * 2); // 向上取整
        
        if (upRating % 2 == 0 || _type == RatingTypeSlidingAndFull || _type == RatingTypeNOSlidingAndFull) {   // 为偶数 或 不存在半选
            for (int i = 0; i < _ratingArray.count; i ++ ) {
                if (i < (upRating + 1)/ 2) {
                    _ratingArray[i].image = _fullSelectedImage;
                }else {
                    _ratingArray[i].image = _normalImage;
                }
            }
            //            // 为整数
            //            _lastRating = ceilf(rating);
        }else {
            for (int i = 0; i < _ratingArray.count; i ++ ) {
                if (i * 2 < upRating - 1 ) {
                    _ratingArray[i].image = _fullSelectedImage;
                }else if (i * 2 == upRating - 1) {
                    _ratingArray[i].image = _halfSelectedImage;
                }else {
                    _ratingArray[i].image = _normalImage;
                }
            }
            //            // 存在半选
            //            _lastRating = upRating / 2.0;
        }
    }
    _lastRating = rating;
    if (_type != RatingTypeIndicator && [self.delegate respondsToSelector:@selector(ratingTool:currentRating:)]) {
        [self.delegate ratingTool:self currentRating:_lastRating];
    }
}
- (float)getCurrentRating {
    return _lastRating;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesRating:touches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_type == RatingTypeSlidingAndHalf || _type == RatingTypeSlidingAndFull) {
        [self touchesRating:touches];
    }else {
        [super touchesEnded:touches withEvent:event];
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_type == RatingTypeSlidingAndHalf || _type == RatingTypeSlidingAndFull) {
        [self touchesRating:touches];
    }else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesRating:(NSSet *)touches{
    if (_type == RatingTypeIndicator) return;    // 为指示器时，不可选
    
    CGPoint point = [[touches anyObject] locationInView:self];

    if (point.x < 0 || point.x > _toolWidth) return;  // 控件外
    
    float selected = (point.x - _leftSpace) / (_itemSize.width + _space);
    
    float rating = floorf(selected); // 向下取整
    
    if (point.x < _leftSpace) {   // 第一个
        rating = 0.0;
    }else if (point.x > (_leftSpace + (_itemSize.width + _space) * (_starsNumber - 1) + _itemSize.width * 0.5) ) {  // 最后位置防止不能全部选中
        rating = _starsNumber;
    }else if ((selected - rating) * (_itemSize.width + _space) > _itemSize.width) {
        rating = rating + 1;
    }
    else {
         rating = rating + (selected - rating) * (_itemSize.width + _space) / _itemSize.width;
    }
    
    if (rating != _lastRating) {
        [self setDisplayRating:rating];
    }
}

@end
