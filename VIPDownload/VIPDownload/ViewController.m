//
//  ViewController.m
//  VIPDownload
//
//  Created by zhaosilei on 2018/5/14.
//  Copyright © 2018年 zhaosilei. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "ZFDownloadManager.h"
#import "DownloadModel.h"
#import "NSObject+ZHAO.h"

#define  DownloadManager  [ZFDownloadManager sharedDownloadManager]
#define KVIEW_W self.view.frame.size.width
#define KVIEW_H self.view.frame.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * tempList;
@property (nonatomic, strong) NSMutableArray * fileFinishList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MaxDown"]) {
        
    }else{
        NSMutableArray * maxDown = [[NSMutableArray alloc] init];
        [maxDown addObject:@"zsl"];
        [[NSUserDefaults standardUserDefaults] setObject:maxDown forKey:@"MaxDown"];
    }
    
    self.dataArray = [[NSMutableArray alloc] init];
    self.tempList = [[NSMutableArray alloc] init];
    self.fileFinishList = [[NSMutableArray alloc] init];
    
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KVIEW_W, KVIEW_H-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    DownloadManager.downloadDelegate = self;
    
    [self creatData];

    
}
- (void)creatData{
    [self.dataArray removeAllObjects];
    [DownloadManager startLoad];
//    NSMutableArray *downladed = DownloadManager.finishedlist;
    NSMutableArray *downloading;

    NSArray * array1 = @[@"http://192.168.41.48/video/1.wmv",
                         @"http://192.168.41.48/video/blog.zip",
                         @"http://192.168.41.48/video/3.wmv",
                         @"http://192.168.41.48/video/4.wmv",
                         @"http://192.168.41.48/video/5.wmv",
                         ];
    
//    NSArray * array1 = @[@"http://120.25.226.186:32812/resources/videos/minion_02.mp4"];
    NSArray * array2 = @[@"http://192.168.41.48/video/6.wmv",
                         @"http://192.168.41.48/videos/7.wmv",
                         @"http://192.168.41.48/video/8.wmv",
                         @"http://192.168.41.48/video/9.wmv",
                         @"http://192.168.41.48/video/10.wmv",
                         ];
    NSArray * array3 = @[@"http://192.168.41.48/video/11.wmv",
                         @"http://192.168.41.48/video/12.wmv",
                         @"http://192.168.41.48/video/13.wmv",
                         
                         ];
    NSArray * array4 = @[@"http://192.168.41.48/video/14.wmv",
                         @"http://192.168.41.48/video/15.wmv",
                         ];
    NSArray * array5 = @[@"http://192.168.41.48/video/16.wmv",
                         @"http://192.168.41.48/video/17.wmv",
                         ];
    NSArray * array6 = @[@"http://192.168.41.48/video/18.wmv",
                         @"http://192.168.41.48/video/19.wmv",
                         ];
    NSMutableArray * arrays = [[NSMutableArray alloc] init];
    [arrays addObject:array1];
    [arrays addObject:array2];
    [arrays addObject:array3];
    [arrays addObject:array4];
    [arrays addObject:array5];
    [arrays addObject:array6];
    
    if (DownloadManager.downinglist) {
        downloading = DownloadManager.downinglist;
        self.tempList = downloading;
    }
    if (DownloadManager.finishedlist) {
        self.fileFinishList = DownloadManager.finishedlist;
    }
    for (int i =0; i<6; i++) {
        DownloadModel * model = [[DownloadModel alloc] init];
        model.fileName = [NSString stringWithFormat:@"test-%d",i+1];
        model.fileURLs = arrays[i];
        model.cellID = [NSString stringWithFormat:@"cell-%d",i];
        [self.dataArray addObject:model];
    }

//    for (ZFHttpRequest * request in downloading) {
////        [request myObjectToString];
//        NSLog(@"^^^^^^%@-----%@",request.url.absoluteString,request.originalURL.absoluteString);
//    }
    
    
//    NSLog(@"----=====%@",downloading);
//    NSLog(@"0000-----%@",DownloadManager.filelist);
//    NSLog(@"++++-----%@",DownloadManager.finishedlist);
    
    
    
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * identifier = @"cell";
    
    TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    DownloadModel * model = self.dataArray[indexPath.row];
    cell.urlArray = model.fileURLs;
    
    cell.downingList = self.tempList;
    cell.fileFinishList = self.fileFinishList;
    
    
    cell.downloadModel = model;
    
    
    
    
    
    return cell;
}

// 开始下载
- (void)startDownload:(ZFHttpRequest *)request
{
    NSLog(@"开始下载!");
}

// 下载中
- (void)updateCellProgress:(ZFHttpRequest *)request
{
    ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

// 下载完成
- (void)finishedDownload:(ZFHttpRequest *)request
{
    
    NSLog(@"\n\n\n");
    NSLog(@"下载完成----->\n");
    [request.userInfo[@"File"] myObjectToString];
    NSLog(@"下载完成<-----\n");
    NSLog(@"\n\n\n");
    
    
    
    ZFFileModel * model = request.userInfo[@"File"];
    TableViewCell *cell ;
    NSArray *cellArr = [self.tableView visibleCells];
    for (id obj in cellArr) {
        if([obj isKindOfClass:[TableViewCell class]]) {
            cell = (TableViewCell *)obj;
            for (NSString * urlString in cell.urlArray) {
                if ([urlString isEqualToString:model.fileURL]) {
                    cell.detailString = @"全部下载完成判断";
                }
            }
            
        }
    }
    [self.tableView reloadData];

}

// 更新下载进度
- (void)updateCellOnMainThread:(ZFFileModel *)fileInfo
{
//    [fileInfo myObjectToString];
//    NSLog(@"-----正在下载");
//    [self creatData];
//    NSArray *cellArr = [self.tableView visibleCells];
//    for (id obj in cellArr) {
//        if([obj isKindOfClass:[TableViewCell class]]) {
//
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
