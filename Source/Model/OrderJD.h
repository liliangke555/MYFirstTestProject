//
//  OrderJD.h
//  kyExpress
//
//  Created by mu on 16/12/22.
//  Copyright © 2016年 kyExpress. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderJD : NSObject

@property (nonatomic,copy)NSString *recode;
@property (nonatomic,copy)NSString *time;
@property (nonatomic,copy)NSString *state;

/** 记录文字高度 **/
@property (assign, nonatomic) CGFloat  contentH;
@property (nonatomic,assign) CGFloat titleH;
@property (nonatomic,assign) CGFloat stateH;

+(NSArray *)RouteModelWithArr:(NSArray *)array;

@end
