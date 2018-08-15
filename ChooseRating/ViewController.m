//
//  ViewController.m
//  ChooseRating
//
//  Created by 梁立 on 2018/2/9.
//  Copyright © 2018年 XLL. All rights reserved.
//

#import "ViewController.h"
#import "RatingTool.h"

@interface ViewController ()<RatingToolDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    RatingTool *tool = [[RatingTool alloc]initWithFrame:CGRectMake(30, 100, 300, 100)  ratingType:RatingTypeSlidingAndHalf starsNumber:6 currentRating:3.001 ratingSize:CGSizeMake(30, 50) fromLeft:0 setImageNormal:@"star_normal" halfSelected:@"star_halfselect" fullSelected:@"star_allselect" WithDelegate:self];
    [self.view addSubview:tool];
}

- (void)ratingTool:(RatingTool *)tool currentRating:(float)rating {
    NSLog(@"rating=%lf",rating);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
