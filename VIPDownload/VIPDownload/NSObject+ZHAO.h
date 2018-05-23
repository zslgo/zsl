//
//  NSObject+ZHAO.h
//  TestPch
//
//  Created by 4szhan.com on 16/7/13.
//  Copyright © 2016年 4szhan.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZHAO)

/**
 字典转模型
 */
+ (id)myModelWithDic:(NSDictionary *)dic;
/**
 打印模型
 */
- (void)myObjectToString;
@end
