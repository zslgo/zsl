//
//  TableViewCell.h
//  VIPDownload
//
//  Created by zhaosilei on 2018/5/14.
//  Copyright © 2018年 zhaosilei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFDownloadManager.h"
#import "DownloadModel.h"

typedef void(^ZFBtnClickBlock)(void);
typedef void(^ZFDeleteClickBlock)(void);

@interface TableViewCell : UITableViewCell


/** 下载按钮点击回调block */
@property (nonatomic, copy  ) ZFBtnClickBlock  btnClickBlock;
@property (nonatomic, copy  ) ZFDeleteClickBlock deleteBtnClick;

/** 该文件发起的请求 */
@property (nonatomic,retain ) ZFHttpRequest    *request;

@property (nonatomic, strong) NSArray * urlArray;

@property (nonatomic, strong) NSArray * downingList;

@property (nonatomic, strong) NSArray * fileFinishList;

@property (nonatomic, strong) DownloadModel * downloadModel;

@property (nonatomic, copy) NSString * detailString;

@end
