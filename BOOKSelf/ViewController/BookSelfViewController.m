//
//  BookSelfViewController.m
//  BOOKSelf
//
//  Created by Gagan on 17/06/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//
#define CollectionCellIdentifier @"CellIdentifier"

//Define for download
#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Downloaded Files"]
#define interruptedDownloadsArrayFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/InterruptedDownloadsFile/interruptedDownloads.txt"]

#define fontNameUsed @"Helvetica"
#define fontSizeUsed 13.0f
#define textColorOfLabels [UIColor darkGrayColor]
#define temporaryFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Temporary Files"]
#define fileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Downloaded Files"]
#define interruptedDownloadsArrayFileDestination [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/InterruptedDownloadsFile/interruptedDownloads.txt"]
#define keyForTitle @"fileTitle"
#define keyForFileHandler @"filehandler"
#define keyForTimeInterval @"timeInterval"
#define keyForTotalFileSize @"totalfilesize"
#define keyForFileSizeInUnits @"fileSizeInUnits"
#define keyForRemainingFileSize @"remainigFileSize"

#import "BookSelfViewController.h"
#import "TableCell.h"
@interface BookSelfViewController ()

@end

@implementation BookSelfViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCellIdentifier"];  //If you are using storyboard
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellWithReuseIdentifier:CollectionCellIdentifier];
    [self.myCollectionView setBackgroundColor:[UIColor clearColor]];
    UICollectionViewFlowLayout *flowlayout=(UICollectionViewFlowLayout*)self.myCollectionView.collectionViewLayout;
    flowlayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resetCollectionViewLayOut) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    //For download option
    urlArray = [[NSMutableArray alloc ]initWithObjects:@"http://dl.dropbox.com/u/97700329/file1.mp4",@"http://dl.dropbox.com/u/97700329/file2.mp4",@"http://dl.dropbox.com/u/97700329/file3.mp4",@"http://dl.dropbox.com/u/97700329/FileZilla_3.6.0.2_i686-apple-darwin9.app.tar.bz2",@"http://dl.dropbox.com/u/97700329/GCDExample-master.zip", nil];
    [self checkForInterruptedDownload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self  resetCollectionViewLayOut];
}

#pragma mark -method to set layout of CollectionView
-(void)resetCollectionViewLayOut
{
    UICollectionViewFlowLayout *flowLayout=(UICollectionViewFlowLayout*)self.myCollectionView.collectionViewLayout;
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        flowLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    }
    else
    {
        flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    }
}

-(void)createTemporaryFile:(NSString *)path
{
    NSLog(@"Directory path %@",path);
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:path contents:Nil attributes:Nil];
        if(!success)
            NSLog(@"Failed to create file");
        else {
            NSLog(@"success");
        }
    }
}

-(void)initializeDownloadingArrayIfNot
{
    if(!downloadingArray)
        downloadingArray = [[NSMutableArray alloc] init ];
}

-(void)createDirectoryIfNotExistAtPath:(NSString *)path
{
    NSLog(@"Directory path %@",path);
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    if(error)
        NSLog(@"Error while creating directory %@",[error localizedDescription]);
}

-(void)resumeInterruptedDownloads:(NSIndexPath *)indexPath :(NSString *)urlString
{
    ASIHTTPRequest *request = [self initializeRequestAndSetProperties:urlString isResuming:YES];
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:request.temporaryFileDownloadPath error:Nil] fileSize];
    if(size != 0)
    {
        NSString* range = @"bytes=";
        range = [range stringByAppendingString:[[NSNumber numberWithInt:size] stringValue]];
        range = [range stringByAppendingString:@"-"];
        [request addRequestHeader:@"Range" value:range];
    }
    if(indexPath)
    {
        [downloadingArray replaceObjectAtIndex:indexPath.row withObject:request];
        [downloadingRequestsQueue addOperation:request];
    }
    else
        [self insertTableviewCellForRequest:request];
}

#pragma mark-collectionView Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
   return   1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(urlArray.count == 0)
        return 1;
    else
        return urlArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TableCell *cell=(TableCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellIdentifier forIndexPath:indexPath];
    cell.nameLabel.text=[NSString stringWithFormat:@"IndexPath : %d",indexPath.row];
    cell.backgroundView.userInteractionEnabled=YES;
    cell.backgroundView.tag=200;
    cell.backgroundView.tag=indexPath.row;
    cell.cancelButton.tag=indexPath.row;
    cell.downloadProgressBar.tag=105;
    cell.detailLabel.tag=101;
    cell.nameLabel.tag=100;
    [cell bringSubviewToFront:cell.backgroundView];
    cell.StartPauseButton.tag=indexPath.row;
    [cell.StartPauseButton addTarget:self action:@selector(downloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.cancelButton addTarget:self action:@selector(CancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openHideView:)];
    tapGesture.numberOfTapsRequired=1;
    [cell.backgroundView addGestureRecognizer:tapGesture];
   tapGesture=nil;
    return cell;
}

-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return ([[UICollectionReusableView alloc]init]);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark-UICollectionViewDelegate flow Layout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(320, 206);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

-(void)openHideView:(UIGestureRecognizer*)sender
{
    UIView *view=[sender view];
    CGRect viewRect=[view frame];
    CGRect fullVisibleRect=CGRectMake(0, 148, 320, 58);
    if([NSStringFromCGRect(viewRect) isEqualToString:NSStringFromCGRect(fullVisibleRect)])
    {
        [self HideViewForProgress:view];
    }
    else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5];
        view.frame=fullVisibleRect;
        [UIView commitAnimations];
    }
}

-(void)HideViewForProgress:(UIView*)view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    view.frame=CGRectMake(0, 194, 320, 58);
    [UIView commitAnimations];
}

-(void)downloadButtonTapped:(UIButton *)sender
{
    NSLog(@"[sender tag] is : %d",[sender tag]);
    UIButton *btn=(UIButton*)sender;
    if(![btn.titleLabel.text isEqualToString:@"Download"])
    {
        [self pauseButtonTapped:sender];
    }
    else{
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
         UICollectionViewCell *cell = (UICollectionViewCell *)sender.superview.superview;
         NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
         [self addDownloadRequest:[urlArray objectAtIndex:indexPath.row]];
    }
}

-(void)checkForInterruptedDownload
{
    NSMutableArray *interruptedRequests = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    [interruptedRequests enumerateObjectsUsingBlock:^(NSString *str, NSUInteger index, BOOL *stop){
        if([urlArray containsObject:str])
            [urlArray removeObject:str];
    }];
}

-(ASIHTTPRequest *)initializeRequestAndSetProperties:(NSString *)urlString isResuming:(BOOL)isResuming
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    [request setAllowResumeForFileDownloads:YES];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setTimeOutSeconds:20.0];
    if(!request.userInfo)
        request.userInfo = [[NSMutableDictionary alloc] init];
    NSString *fileName = [request.userInfo objectForKey:keyForTitle];
    if(!fileName)
    {
        fileName = [request.url.absoluteString lastPathComponent];
        [request.userInfo setValue:fileName forKey:keyForTitle];
    }
    NSString *temporaryDestinationPath = [NSString stringWithFormat:@"%@/%@.download",temporaryFileDestination,fileName];
    [request setTemporaryFileDownloadPath:temporaryDestinationPath];
    if(!isResuming)
        [self createTemporaryFile:request.temporaryFileDownloadPath];
    
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/%@",fileDestination,fileName]];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [self initializeDownloadingRequestsQueueIfNot];
    return request;
}

-(void)addDownloadRequest:(NSString *)urlString
{
    [self initializeDownloadingArrayIfNot];
    [self createDirectoryIfNotExistAtPath:temporaryFileDestination];
    [self createDirectoryIfNotExistAtPath:fileDestination];
    
    [self createDirectoryIfNotExistAtPath:[interruptedDownloadsArrayFileDestination stringByDeletingLastPathComponent]];
    [self createTemporaryFile:interruptedDownloadsArrayFileDestination];
    [self writeURLStringToFileIfNotExistForResumingPurpose:urlString];
    
    [self insertTableviewCellForRequest:[self initializeRequestAndSetProperties:urlString isResuming:NO]];
}

-(void)initializeDownloadingRequestsQueueIfNot
{
    if(!downloadingRequestsQueue)
        downloadingRequestsQueue = [[NSOperationQueue alloc] init];
}

-(void)updateProgressForCell:(UICollectionViewCell *)cell withRequest:(ASIHTTPRequest *)request
{
    if(![request.userInfo isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    NSFileHandle *fileHandle = [request.userInfo objectForKey:keyForFileHandler];
    if(fileHandle)
    {
        unsigned long long partialContentLength = [fileHandle offsetInFile];
        unsigned long long totalContentLenght = [[request.userInfo objectForKey:keyForTotalFileSize] unsignedLongLongValue];
        unsigned long long remainingContentLength = totalContentLenght - partialContentLength;
        
        NSTimeInterval downloadTime = -1 * [[request.userInfo objectForKey:keyForTimeInterval] timeIntervalSinceNow];
        
        float speed = (partialContentLength - (totalContentLenght - [[request.userInfo objectForKey:keyForRemainingFileSize] unsignedLongLongValue])) / downloadTime;
        
        int remainingTime = (int)(remainingContentLength / speed);
		int hours = remainingTime / 3600;
		int minutes = (remainingTime - hours * 3600) / 60;
		int seconds = remainingTime - hours * 3600 - minutes * 60;
        
        NSString *remainingTimeStr = [NSString stringWithFormat:@""];
        
        if(hours>0)
            remainingTimeStr = [remainingTimeStr stringByAppendingFormat:@"%d Hours ",hours];
        if(minutes>0)
            remainingTimeStr = [remainingTimeStr stringByAppendingFormat:@"%d Min ",minutes];
        if(seconds>0)
            remainingTimeStr = [remainingTimeStr stringByAppendingFormat:@"%d sec",seconds];
        
        float percentComplete = (float)partialContentLength/totalContentLenght*100;
        float progressForProgressView = percentComplete / 100;
        
        [cell.subviews enumerateObjectsUsingBlock:^(UIView *cellSubView, NSUInteger index, BOOL *stop){
              [cellSubView.subviews enumerateObjectsUsingBlock:^(UIView *cellSub2View, NSUInteger index, BOOL *stop){
                  NSLog(@"cellSubView sub2views tag are : %d",cellSub2View.tag);
            if(cellSub2View.tag >= 100)
            {
                if(cellSub2View.tag == 100)
                {
                    UILabel *titleLabel = (UILabel *)cellSub2View;
                    [titleLabel setText:[NSString stringWithFormat:@"File Title: %@",[request.userInfo objectForKey:keyForTitle]]];
                }
                else if(cellSub2View.tag == 101)
                {
                    NSString *fileSizeInUnits = [request.userInfo objectForKey:keyForFileSizeInUnits];
                    if(!fileSizeInUnits)
                    {
                        fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                           [self calculateFileSizeInUnit:totalContentLenght],
                                           [self calculateUnit:totalContentLenght]];
                        [request.userInfo setValue:fileSizeInUnits forKey:keyForFileSizeInUnits];
                    }
                    NSString *detailLabelText = [NSString stringWithFormat:@"File Size: %@\nDownloaded: %.2f %@ (%.2f%%)\nSpeed: %.2f %@/sec\n",fileSizeInUnits,
                                                 [self calculateFileSizeInUnit:partialContentLength],
                                                 [self calculateUnit:partialContentLength],percentComplete,
                                                 [self calculateFileSizeInUnit:(unsigned long long) speed],
                                                 [self calculateUnit:(unsigned long long)speed]
                                                 ];
                    if(progressForProgressView == 1.0)
                        detailLabelText = [detailLabelText stringByAppendingFormat:@"Plz wait, copying file"];
                    else
                        detailLabelText = [detailLabelText stringByAppendingFormat:@"Time Left: %@",remainingTimeStr];
                    UILabel *detailedLabel = (UILabel *)cellSub2View;
                    [detailedLabel setText:detailLabelText];
                }
                else if(cellSub2View.tag == 105)
                {
                    NSLog(@"progressForProgressView is : %f",progressForProgressView);
                    UIProgressView *progressView = (UIProgressView *)cellSub2View;
                    progressView.progress = progressForProgressView;
                }
            }
              }];
        }];
    }
}

-(void)insertTableviewCellForRequest:(ASIHTTPRequest *)request
{
    if(downloadingArray.count == 0)
    {
        if(![downloadingArray containsObject:request])
        {
            [downloadingArray addObject:request];
            [downloadingRequestsQueue addOperation:request];
        }
    }
    else
    {
        if(![downloadingArray containsObject:request])
        {
            [downloadingArray addObject:request];
            [downloadingRequestsQueue addOperation:request];
        }
    }
}

-(float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return (float) (contentLength / pow(1024, 3));
    else if(contentLength >= pow(1024, 2))
        return (float) (contentLength / pow(1024, 2));
    else if(contentLength >= 1024)
        return (float) (contentLength / 1024);
    else
        return (float) (contentLength);
}

-(NSString *)calculateUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(1024, 3))
        return @"GB";
    else if(contentLength >= pow(1024, 2))
        return @"MB";
    else if(contentLength >= 1024)
        return @"KB";
    else
        return @"Bytes";
}

-(void)writeURLStringToFileIfNotExistForResumingPurpose:(NSString *)urlString
{
    NSMutableArray *interruptedDownloads = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    if(!interruptedDownloads)
        interruptedDownloads = [[NSMutableArray alloc] init];
    if(![interruptedDownloads containsObject:urlString])
    {
        [interruptedDownloads addObject:urlString];
        [interruptedDownloads writeToFile:interruptedDownloadsArrayFileDestination atomically:YES];
    }
}

-(void)removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:(NSString *)urlString
{
    NSMutableArray *interruptedDownloads = [NSMutableArray arrayWithContentsOfFile:interruptedDownloadsArrayFileDestination];
    [interruptedDownloads removeObject:urlString];
    [interruptedDownloads writeToFile:interruptedDownloadsArrayFileDestination atomically:YES];
}

-(void)removeRequest:(ASIHTTPRequest *)request :(NSIndexPath *)indexPath
{
    [downloadingArray removeObject:request];
}

-(void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

-(void)pauseButtonTapped:(UIButton *)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender superview].superview;
    NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
    if([[sender titleForState:UIControlStateNormal] isEqualToString:@"Pause"])
    {
        [sender setTitle:@"Resume" forState:UIControlStateNormal];
        [self downloadRequestPaused:[urlArray objectAtIndex:indexPath.row]];
    }
    else
    {
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
        [self resumeInterruptedDownloads:indexPath :[urlArray objectAtIndex:indexPath.row]];
    }
}

#pragma mark - ASIHTTPRequest Delegate -
-(void)requestStarted:(ASIHTTPRequest *)request
{
    [self downloadRequestStarted:request];
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    [downloadingArray enumerateObjectsUsingBlock:^(ASIHTTPRequest *req, NSUInteger index, BOOL *stop){
        if([req isEqual:request])
        {
            NSFileHandle *fileHandle = [req.userInfo objectForKey:keyForFileHandler];
            if(!fileHandle)
            {
                if(![req requestHeaders])
                {
                    fileHandle = [NSFileHandle fileHandleForWritingAtPath:req.temporaryFileDownloadPath];
                    [req.userInfo setValue:fileHandle forKey:keyForFileHandler];
                }
            }
            long long length = [[req.userInfo objectForKey:keyForTotalFileSize] longLongValue];
            if(length == 0)
            {
                length = [req contentLength];
                if (length != NSURLResponseUnknownLength)
                {
                    NSNumber *totalSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)length];
                    [req.userInfo setValue:totalSize forKey:keyForTotalFileSize];
                }
                [req.userInfo setValue:[NSDate date] forKey:keyForTimeInterval];
            }
            if([request requestHeaders])
            {
                NSString *range = [[request requestHeaders] objectForKey:@"Range"];
                NSString *numbers = [range stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                unsigned long long size = [numbers longLongValue];
                
                if(length != 0)
                {
                    [req.userInfo setValue:[NSNumber numberWithUnsignedLongLong:length] forKey:keyForRemainingFileSize];
                    length = length + size;
                    NSNumber *totalSize = [NSNumber numberWithUnsignedLongLong:(unsigned long long)length];
                    [req.userInfo setValue:totalSize forKey:keyForTotalFileSize];
                    
                    
                    fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:req.temporaryFileDownloadPath];
                    [req.userInfo setValue:fileHandle forKey:keyForFileHandler];
                    [fileHandle seekToFileOffset:size];
                }
            }
            index=[[self ArrayUniqueFileNameToDownload] indexOfObject:req.url.absoluteString.lastPathComponent];
            NSLog(@"index in didReceiveResponseHeaders is : %d",index );
            [self updateProgressForCell:[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] withRequest:req];
            [self downloadRequestReceivedResponseHeaders:request responseHeaders:responseHeaders];
            *stop = YES;
        }
    }];
}

-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    [downloadingArray enumerateObjectsUsingBlock:^(ASIHTTPRequest *req, NSUInteger index, BOOL *stop){
        if([req isEqual:request])
        {
            NSFileHandle *fileHandle = [req.userInfo objectForKey:keyForFileHandler];
			[fileHandle writeData:data];
            index=[[self ArrayUniqueFileNameToDownload] indexOfObject:req.url.absoluteString.lastPathComponent];
            NSLog(@"index in didReceiveData is : %d",index);
            [self updateProgressForCell:[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] withRequest:req];
            *stop = YES;
        }
    }];
}

-(void)requestDone:(ASIHTTPRequest *)request
{
    [self removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:request.url.absoluteString];
    [self removeRequest:request :[NSIndexPath indexPathForRow:[downloadingArray indexOfObject:request] inSection:0]];
    [self downloadRequestFinished:request];
}
- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    if([request.error.localizedDescription isEqualToString:@"The request was cancelled"])
    {
        
    }
    else
    {
        [self showAlertViewWithMessage:request.error.localizedDescription];
        UICollectionViewCell *cell = [self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:[downloadingArray indexOfObject:request] inSection:0]];
        [cell.subviews enumerateObjectsUsingBlock:^(UIView *cellSubview, NSUInteger index, BOOL *stop){
            if(cellSubview.tag == 1000)
            {
                UIButton *pauseButton = (UIButton *)cellSubview;
                [pauseButton setTitle:@"Retry" forState:UIControlStateNormal];
                *stop = YES;
            }
        }];
    }
    [self downloadRequestFailed:request];
}

-(void)CancelButtonPressed:(id)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[sender superview].superview;
    NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
    [self removeURLStringFromInterruptedDownloadFileIfRequestCancelByTheUser:[urlArray objectAtIndex:indexPath.row]];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[[downloadingArray objectAtIndex:indexPath.row] temporaryFileDownloadPath] error:&error];
    if(error)
        NSLog(@"Error while deleting filehandle %@",error);
    [self downloadRequestCanceled:[urlArray objectAtIndex:indexPath.row]];
    //Hide Download View
    UIView * cellBackgroundView=[[cell subviews]objectAtIndex:0];
    if([cellBackgroundView isKindOfClass:[UIView class]])
    {
        cellBackgroundView.backgroundColor=[UIColor redColor];
        [self HideViewForProgress:cellBackgroundView];
    }
}

//Enmurated file name to detect wihich file is in download progress
-(NSArray*)ArrayUniqueFileNameToDownload
{
    NSMutableArray *tempArray=[NSMutableArray array];
    for(NSString *strURL in urlArray)
    {
        [tempArray addObject:strURL.lastPathComponent];
    }
    return tempArray;
}

#pragma mark - ZeeDownloadsViewControllerDelegate -
-(void)downloadRequestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"Request userinfo %@",request.userInfo);
}

-(void)downloadRequestReceivedResponseHeaders:(ASIHTTPRequest *)request responseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"response Headers %@",responseHeaders);
}

-(void)downloadRequestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Request userinfo %@",request.userInfo);
    int indexCompleted=[[self ArrayUniqueFileNameToDownload] indexOfObject:[request.userInfo valueForKey:@"fileTitle"]];
    UICollectionViewCell *cell=[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexCompleted inSection:0]];
    UIView * cellBackgroundView=[[cell subviews]objectAtIndex:0];
    if([cellBackgroundView isKindOfClass:[UIView class]])
    {
        cellBackgroundView.backgroundColor=[UIColor greenColor];
        [self HideViewForProgress:cellBackgroundView];
    }
}

-(void)downloadRequestFailed:(ASIHTTPRequest *)request
{
    if([request.error.localizedDescription isEqualToString:@"The request was cancelled"])
    {
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:request.error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)downloadRequestPaused:(NSString *)requestUrlStr
{
    NSLog(@"Request paused %@",requestUrlStr);
    [self CancelRequestIWithUrlStr:requestUrlStr];
}

-(void)downloadRequestCanceled:(NSString *)requestUrlStr
{
    NSLog(@"Request canceled %@",requestUrlStr);
    [self CancelRequestIWithUrlStr:requestUrlStr];
}

-(void)CancelRequestIWithUrlStr:(NSString*)urlStr
{
    for(ASIHTTPRequest *req in downloadingArray)
    {
        if([req.url.absoluteString.lastPathComponent isEqualToString:urlStr.lastPathComponent])
        {
            [req cancel];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
