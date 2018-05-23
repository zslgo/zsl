//
//  DownloadModel.h
//  VIPDownload
//
//  Created by zhaosilei on 2018/5/14.
//  Copyright © 2018年 zhaosilei. All rights reserved.
//
//不要怂，就是干


#import <Foundation/Foundation.h>

@interface DownloadModel : NSObject

@property (nonatomic, copy) NSString        *fileName;
@property (nonatomic, copy) NSArray        *fileURLs;
@property (nonatomic, copy) NSString        *cellID;
@end
