//
//  TableViewCell.m
//  VIPDownload
//
//  Created by zhaosilei on 2018/5/14.
//  Copyright © 2018年 zhaosilei. All rights reserved.
//

#import "TableViewCell.h"
#import "UIView+Banner.h"
#import "NSObject+ZHAO.h"
#import "ZFDownloadManager.h"

#define CELL_W self.frame.size.width
#define CELL_H self.frame.size.height

@interface TableViewCell()

@property (nonatomic, strong) NSString * cellID;

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UILabel * detailLabel;

@property (nonatomic, strong) UIButton * stateButton;

@property (nonatomic, strong) UIButton * deleteBtn;

@property (nonatomic, assign) BOOL isFirst;

@end


@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isFirst = YES;
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.stateButton];
    [self.contentView addSubview:self.deleteBtn];
}
- (void)layoutSubviews{
    
    self.titleLabel.frame = CGRectMake(5, 5, CELL_W/2-5, 40);
    self.detailLabel.frame = CGRectMake(5, self.titleLabel.bottom+5, CELL_W/2, 40);
    self.deleteBtn.frame = CGRectMake(CELL_W-5-40, (CELL_H-40)/2, 40, 40);
    self.stateButton.frame = CGRectMake(self.deleteBtn.left-5-40, self.deleteBtn.top, 40, 40);
    
}
- (void)setDownloadModel:(DownloadModel *)downloadModel{
    _downloadModel = downloadModel;
    self.cellID = downloadModel.cellID;
    self.titleLabel.text = downloadModel.fileName;
    
    /**
     注意：
     
     如果一个URL请求异常，那么该URL会很快结束，并且会放入已完成列表中
     并且plist文件中记录的总大小为0，已下载大小为1
     */
    
    
    /**
     遍历下载完的文件列表，匹配到本cell上的URL，获取相应的文件
     如果该文件的总大小为0，则说明下载是异常
     如果下载状态为ZFStopDownload，但是已下载的大小和总大小不相等，则下载异常
     */
    NSArray * finishList = self.fileFinishList;
    if (finishList.count > 0) {
        for (ZFFileModel * model in finishList) {
            for (NSString * urlString in self.urlArray) {
                if ([model.fileURL isEqualToString:urlString]) {
                    if (([model.fileSize isEqualToString:@"0"]) || (model.downloadState == ZFStopDownload && model.fileReceivedSize!=model.fileSize) ) {
                        
                        self.detailLabel.text = @"下载异常";
                        self.stateButton.selected = NO;
                        return;
                    }
                }
                
            }
        }
    }
    
    
    
    /**
     由于文件从前到后，不是存在临时文件列表，就是存在下载完成列表，所以
     当临时文件列表和下载完成列表都没有URL对应的文件，则说明该URL没有下载过
     只要第一个URL对应的没有，就没有
     */
    for (NSString * url in self.urlArray){
        NSString *name = [[url componentsSeparatedByString:@"/"] lastObject];
        NSString *tempfilePath = [TEMP_PATH(name) stringByAppendingString:@".plist"];
        if (![ZFCommonHelper isExistFile:FILE_PATH(name)] &&  ![ZFCommonHelper isExistFile:tempfilePath]) {
            
            self.detailLabel.text = @"视频暂未下载";
            self.stateButton.selected = NO;
            return;
        }
    }
    
    
    /**
     如果本cell上所有的URL都能在已下载完列表中找到，则说明下载完成
     由于异常在上面已判断，所以不用担心
     */
    int downloagCount = 0;
    
    if (finishList.count > 0) {
        for (ZFFileModel * model in finishList) {
            for (NSString * urlString in self.urlArray) {
                if ([model.fileURL isEqualToString:urlString]) {
                    downloagCount++;
                }
            }
        }
        if (downloagCount == self.urlArray.count) {
            self.detailLabel.text = @"下载完成";
            self.stateButton.selected = NO;
            return;
        }
    }
    
    
    
    /**
     temp里的缓存临时文件，对应该cell上的URL，如果有一个URL的状态是ZFDownloading，那么该cell就是正在下载状态
     */
    NSArray * downlingList = self.downingList;
    if (downlingList.count > 0) {
        for (ZFHttpRequest * request in downlingList) {
            ZFFileModel * model = request.userInfo[@"File"];
            for (NSString * urlString in self.urlArray) {
                if ([request.url.absoluteString isEqualToString:urlString]) {
                    
                    if (model.downloadState == ZFDownloading) {
                        self.detailLabel.text = @"正在下载";
                        self.stateButton.selected = YES;
                        return;
                    }
                    
                    
                }
            }
        }
        
    }
    
    
    self.detailLabel.text = @"暂停下载";
    self.stateButton.selected = YES;
}

- (void)setDetailString:(NSString *)detailString{
    
    if ([detailString isEqualToString:@"全部下载完成判断"]) {
        
        int downloagCount = 0;
        
        NSArray * finishList = self.fileFinishList;
        
        if (finishList.count > 0) {
            for (ZFFileModel * model in finishList) {
                for (NSString * urlString in self.urlArray) {
                    if ([model.fileURL isEqualToString:urlString]) {
                        downloagCount++;
                    }
                }
            }
            if (downloagCount == self.urlArray.count) {
                
                NSMutableArray * maxDown = [[NSMutableArray alloc] init];
                NSArray * maxDownArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"MaxDown"];
                [maxDown addObjectsFromArray:maxDownArray];
                if ([maxDown containsObject:self.cellID]) {
                    int temp = 1000;
                    for (int i = 0; i<maxDown.count; i++) {
                        if ([maxDown[i] isEqualToString:self.cellID]) {
                            temp = i;
                        }
                    }
                    [maxDown removeObjectAtIndex:temp];
                }
                [[NSUserDefaults standardUserDefaults] setObject:maxDown forKey:@"MaxDown"];
                
            }
        }
        
        
    }
 
    
}



- (void)stateBtnClick:(UIButton *)btn{
    
    NSLog(@"22123");

    //如果下载完成，该按钮点击无反应
    if([self.detailLabel.text isEqualToString:@"下载完成"]){

        return;
    }
    
    ZFDownloadManager * fileDownloadManager = [ZFDownloadManager sharedDownloadManager];
    
    
    /**
     注意：如果cell对应的URL数组中有一个URL异常，那么不影响其他URL的下载
     对于异常状态下点击按钮，那么找到该cell上的异常的URL，作为第一次下载
     作为第一次下载，ZFDownloadManager 会清除掉临时文件和已下载完文件中的该异常URL的信息
     */
    NSArray * finishList = self.fileFinishList;
    NSMutableArray * errorList = [[NSMutableArray alloc] init];
    for (ZFFileModel * model in finishList){
        
        for (NSString * urlString in self.urlArray) {
            if ([model.fileURL isEqualToString:urlString]) {
                if ([model.fileSize isEqualToString:@"0"] || (model.downloadState == ZFStopDownload && model.fileReceivedSize!=model.fileSize)) {
                    [errorList addObject:model];
                }
            }
        }
    }
    if (errorList.count > 0) {
        
        
//        NSMutableArray * maxDown = [[NSUserDefaults standardUserDefaults] objectForKey:@"MaxDown"];
//        
//        NSMutableSet * set = [[NSMutableSet alloc] initWithArray:maxDown];
//        if (set.count > 3) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"只能同时下载3个" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//            return;
//        }else{
//            [set addObject:self.cellID];
//            NSMutableArray * tempMaxDown = [[NSMutableArray alloc] init];
//            tempMaxDown = [[set allObjects] mutableCopy];
//            [[NSUserDefaults standardUserDefaults] setObject:tempMaxDown forKey:@"MaxDown"];
//        }
        
        self.detailLabel.text = @"正在下载";
        self.stateButton.selected = YES;
        
        NSArray * errorListArray = [NSArray arrayWithArray:errorList];
        for (ZFFileModel * model in errorListArray) {
            [[ZFDownloadManager sharedDownloadManager] downFileUrl:model.fileURL filename:model.fileName fileimage:nil];
            [ZFDownloadManager sharedDownloadManager].maxCount = 30;
        }
        return;
    }
    
    
    
    
    /**
     由于第一次下载和续传的方法不一致，所以要判断是不是首次下载
     只要该cell上的URLS有一个存在于临时文件或者已下载完列表中就不是第一次下载
     */
    for (NSString * url in self.urlArray){
        NSString *name = [[url componentsSeparatedByString:@"/"] lastObject];
        NSString *tempfilePath = [TEMP_PATH(name) stringByAppendingString:@".plist"];
        if ([ZFCommonHelper isExistFile:FILE_PATH(name)] || [ZFCommonHelper isExistFile:tempfilePath]) {
            self.isFirst = NO;
        }
    }
    
    
    
    if (self.isFirst) {

        
        NSMutableArray * maxDown = [[NSUserDefaults standardUserDefaults] objectForKey:@"MaxDown"];
        
        NSMutableSet * set = [[NSMutableSet alloc] initWithArray:maxDown];
        if (set.count > 3) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"只能同时下载3个" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }else{
            [set addObject:self.cellID];
            NSMutableArray * tempMaxDown = [[NSMutableArray alloc] init];
            tempMaxDown = [[set allObjects] mutableCopy];
            [[NSUserDefaults standardUserDefaults] setObject:tempMaxDown forKey:@"MaxDown"];
        }
        
        self.detailLabel.text = @"正在下载";
        self.stateButton.selected = YES;
        
        for (NSString * url in self.urlArray) {
            NSString *name = [[url componentsSeparatedByString:@"/"] lastObject];
            [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
            [ZFDownloadManager sharedDownloadManager].maxCount = 30;

        }
        
    }else{
        
        /**
         两种情况：暂停和继续下载
         
        */
        
        
        
        NSMutableArray * stateArray = [[NSMutableArray alloc] init];
        //把所有状态加到数组里
        NSArray * downLoadListArray = self.downingList;
        for (ZFHttpRequest * request in downLoadListArray) {
            for (NSString * url in self.urlArray) {
                if ([request.url.absoluteString isEqualToString:url]) {
                    ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
//                    [fileInfo myObjectToString];
                    NSNumber * number = [NSNumber numberWithInteger:fileInfo.downloadState];
                    [stateArray addObject:number];
                }
            }
        }
        
        ZFDownLoadState downloadState = ZFWillDownload;
        
//        NSLog(@"-------%@",stateArray);
        
        
        /**
         如果有一个状态是ZFDownloading，那么就说明是正在下载
         */
        NSArray * tempStateArray = [NSArray arrayWithArray:stateArray];
        for (NSNumber * number in tempStateArray) {
            NSInteger download = [number integerValue];
            
            if (download == ZFDownloading) {
                downloadState = ZFDownloading;
                break;
            }
        }
        
        
        
        if (downloadState == ZFDownloading) {
            
            NSMutableArray * maxDown = [[NSMutableArray alloc] init];
            NSArray * maxDownArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"MaxDown"];
            [maxDown addObjectsFromArray:maxDownArray];
            if ([maxDown containsObject:self.cellID]) {
                int temp = 1000;
                for (int i = 0; i<maxDown.count; i++) {
                    if ([maxDown[i] isEqualToString:self.cellID]) {
                        temp = i;
                    }
                }
                [maxDown removeObjectAtIndex:temp];
            }
            [[NSUserDefaults standardUserDefaults] setObject:maxDown forKey:@"MaxDown"];
            
            //如果当前是正在下载，点击按钮，则暂停下载
            self.stateButton.selected = NO;
            self.detailLabel.text = @"暂停下载";
            
            
            
            NSArray * array = [NSArray arrayWithArray:self.downingList];
            for (ZFHttpRequest * request in array) {
                
//                [request myObjectToString];
                
                for (NSString * url in self.urlArray) {
                    if ([request.url.absoluteString isEqualToString:url]) {
                        [fileDownloadManager stopRequest:request];
                    }
                }
            }
        }else{
            
            
            
            NSMutableArray * maxDown = [[NSUserDefaults standardUserDefaults] objectForKey:@"MaxDown"];
            
            NSMutableSet * set = [[NSMutableSet alloc] initWithArray:maxDown];
            if (set.count > 3) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"只能同时下载3个" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }else{
                [set addObject:self.cellID];
                NSMutableArray * tempMaxDown = [[NSMutableArray alloc] init];
                tempMaxDown = [[set allObjects] mutableCopy];
                [[NSUserDefaults standardUserDefaults] setObject:tempMaxDown forKey:@"MaxDown"];
            }
            
            //如果当前是暂停状态，点击按钮，则继续下载
            self.stateButton.selected = YES;
            self.detailLabel.text = @"正在下载";
            
            
            
            
            /**
             第一次点击按钮，就退出了，那么再进入isFirst=NO，
             1.如果有极端情况，就是第一次点击的时候，一共有5个请求，但是只有三个请求发出，那么还有两个没发出，就采用下面来分离继续请求和首次请求
             2.如果5个请求，三个已经下载完，还有两个没下载，分离请求
             
             */
            NSArray * array = [NSArray arrayWithArray:self.downingList];
            
            NSMutableArray * downloadingArray = [[NSMutableArray alloc] init];
            NSMutableArray * tempArray = [[NSMutableArray alloc] init];
            NSMutableArray * willDownloadArray = [[NSMutableArray alloc] initWithArray:self.urlArray];
            
            for (ZFHttpRequest * request in array) {
                for (NSString * url in self.urlArray) {
                    if ([request.url.absoluteString isEqualToString:url]) {
                        [downloadingArray addObject:request];
                        [tempArray addObject:url];
                    }
                }
            }
            
            [willDownloadArray removeObjectsInArray:tempArray];
            
            //temp里面有的，继续请求
            if (downloadingArray.count > 0) {
                NSArray * tempDownloadingArray = [NSArray arrayWithArray:downloadingArray];
                for (ZFHttpRequest * request in tempDownloadingArray) {
                    [fileDownloadManager resumeRequest:request];
                }
            }
            
            /**
             不在temp里的，分两种
                 1.已下载完，不作处理
                 2.一点都没下载的，开始下载
             */
            NSMutableArray * tempWillDown = willDownloadArray;
            if (willDownloadArray.count > 0) {
                NSArray * finishList = self.fileFinishList;
                NSArray * tempWillDownloadArray = [NSArray arrayWithArray:willDownloadArray];
                for (NSString * urlString in tempWillDownloadArray) {
                    for (ZFFileModel * model in finishList) {
                        if ([model.fileURL isEqualToString:urlString]) {
                            [tempWillDown removeObject:urlString];
                        }else{
                            
                        }
                    }
                }
            }
            if (tempWillDown.count > 0) {
                NSArray * tempWillDownArray = [NSArray arrayWithArray:tempWillDown];
                for (NSString * urlString in tempWillDownArray) {
                    NSString *name = [[urlString componentsSeparatedByString:@"/"] lastObject];
                    [[ZFDownloadManager sharedDownloadManager] downFileUrl:urlString filename:name fileimage:nil];
                    [ZFDownloadManager sharedDownloadManager].maxCount = 30;

                }
            }
            
            
            
        }
    }
    
    
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
//    btn.userInteractionEnabled = YES;
}
- (void)deleteBtnClick:(UIButton *)btn{
//    btn.userInteractionEnabled = NO;
    ZFDownloadManager * fileDownloadManager = [ZFDownloadManager sharedDownloadManager];
    
    NSArray * downlingList = self.downingList;
    
    for (ZFHttpRequest * request in downlingList) {
        for (NSString * url in self.urlArray) {
            if ([request.url.absoluteString isEqualToString:url]) {
                [fileDownloadManager deleteRequest:self.request];
            }
        }
    }
    
    
    if (self.deleteBtnClick) {
        self.deleteBtnClick();
    }
//    btn.userInteractionEnabled = YES;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        
    }
    return _titleLabel;
}
- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
    }
    return _detailLabel;
}
- (UIButton *)stateButton{
    if (!_stateButton) {
        _stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_stateButton setTitle:@"下载" forState:UIControlStateNormal];
        [_stateButton setImage:[UIImage imageNamed:@"menu_pause"] forState:UIControlStateNormal];
        [_stateButton setImage:[UIImage imageNamed:@"menu_play"] forState:UIControlStateSelected];
        _stateButton.layer.borderWidth = 1;
        _stateButton.layer.borderColor = [UIColor blueColor].CGColor;
        [_stateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stateButton addTarget:self action:@selector(stateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateButton;
}
- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        _deleteBtn.layer.borderColor = [UIColor blueColor].CGColor;
        _deleteBtn.layer.borderWidth = 1;
        [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




















@end








