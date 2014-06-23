//
//  MultipleDownload.h
//
//
#import <UIKit/UIKit.h>

@protocol DownloadData <NSObject>

@optional
- (void)didFinishDownload:(NSNumber*)idx;
- (void)didFinishAllDownload;
-(void)DownloadProgressWithExpectedLength:(double)expectedLength WithDownloadLength:(double)downloadedLength AtIndex:(int)fileIndex;
-(void)didFailDownloadWithError:(NSError*)error withRequest:(int)index;
@end

@interface MultipleDownload : NSObject {
	NSMutableArray *urls;
	NSMutableDictionary *requests;
	NSMutableArray *receivedDownloadData;
	NSInteger downloadCount;
	id <DownloadData> delegate;
    NSMutableArray *expectedLenthArray;
}

@property (nonatomic,retain) NSMutableArray *urls;
@property (nonatomic,retain) NSMutableDictionary *requests;
@property (nonatomic,retain) NSMutableArray *receivedDownloadData;
@property(nonatomic,retain) id <DownloadData>delegate;
@property NSInteger downloadCount;

- (id)initWithUrls:(NSArray *)aUrls;
- (void)requestWithUrls:(NSArray *)aUrls;
- (NSData *)dataAtIndex:(NSInteger)idx;
- (NSString *)dataAsStringAtIndex:(NSInteger)idx;
- (void)setDelegate:(id)val;

@end
