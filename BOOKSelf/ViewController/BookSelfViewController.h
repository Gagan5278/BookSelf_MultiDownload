//
//  BookSelfViewController.h
//  BOOKSelf
//
//  Created by Gagan on 17/06/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//
#import "ASIHTTPRequest.h"
#import <UIKit/UIKit.h>
@class TableCell;
@interface BookSelfViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *urlArray;
    NSMutableArray *downloadingArray;
    NSOperationQueue *downloadingRequestsQueue;
}
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

//Methods for download files
-(void)downloadButtonTapped:(UIButton *)sender;
-(void)checkForInterruptedDownload;

-(void)initializeDownloadingArrayIfNot;
-(void)createDirectoryIfNotExistAtPath:(NSString *)path;
-(void)createTemporaryFile:(NSString *)path;
-(ASIHTTPRequest *)initializeRequestAndSetProperties:(NSString *)urlString isResuming:(BOOL)isResuming;
-(void)addDownloadRequest:(NSString *)urlString;
-(void)initializeDownloadingRequestsQueueIfNot;
-(void)updateProgressForCell:(UICollectionViewCell *)cell withRequest:(ASIHTTPRequest *)request;
-(void)resumeInterruptedDownloads:(NSIndexPath *)indexPath :(NSString *)urlString;
-(void)insertTableviewCellForRequest:(ASIHTTPRequest *)request;
-(float)calculateFileSizeInUnit:(unsigned long long)contentLength;
-(NSString *)calculateUnit:(unsigned long long)contentLength;
-(void)writeURLStringToFileIfNotExistForResumingPurpose:(NSString *)urlString;
-(void)removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:(NSString *)urlString;
-(void)removeRequest:(ASIHTTPRequest *)request :(NSIndexPath *)indexPath;
-(void)showAlertViewWithMessage:(NSString *)msg;
@end
