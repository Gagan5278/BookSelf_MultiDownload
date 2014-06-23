//
//  MultipleDownload.m
//
//  Copyright 2014 Gagan.
//

#import "MultipleDownload.h"


@implementation MultipleDownload

@synthesize urls, requests, receivedDownloadData,downloadCount ,delegate;

- init {
    if ((self = [super init])) {
		self.downloadCount = 0;
		NSMutableArray *array = [[NSMutableArray alloc] init];
		self.receivedDownloadData = array;
		array=nil ;
		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		self.requests = dict;
        dict=nil;
    }
    return self;
}

- (void)setDelegate:(id)val
{
    delegate = val;
}

- (id)delegate
{
    return delegate;
}


#pragma mark Methods
- (id)initWithUrls:(NSArray *)aUrls {
    if ((self = [self init]))
		[self requestWithUrls:aUrls];
	return self;
}

- (void)requestWithUrls:(NSArray *)aUrls {
    expectedLenthArray=[[NSMutableArray alloc]init];
	[receivedDownloadData removeAllObjects];
	[requests removeAllObjects];
    urls=nil;
	urls = [aUrls copy];
	
	for(NSInteger i=0; i< [urls count]; i++){
		NSMutableData *aData = [[NSMutableData alloc] init];
		[receivedDownloadData addObject: aData];
        aData=nil;		
		NSURLRequest *request = [[NSURLRequest alloc]initWithURL: [NSURL URLWithString: [urls objectAtIndex:i]]cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
								 timeoutInterval: 10
								 ];
		NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
		
		[requests setObject: [NSNumber numberWithInt: i] forKey: [NSValue valueWithNonretainedObject:connection]];
        connection=nil;
        request=nil;
	}
}

- (NSData *)dataAtIndex:(NSInteger)idx {
	return [receivedDownloadData objectAtIndex:idx];
}

- (NSString *)dataAsStringAtIndex:(NSInteger)idx {
	return [[NSString alloc] initWithData:[receivedDownloadData objectAtIndex:idx] encoding:NSUTF8StringEncoding] ;
}

#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSInteger i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
    [[receivedDownloadData objectAtIndex:i] setLength:0];
    [expectedLenthArray addObject:[NSNumber numberWithDouble:[response expectedContentLength]]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSInteger i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
    [[receivedDownloadData objectAtIndex:i] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSInteger i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
	downloadCount++;
	if ([delegate respondsToSelector:@selector(didFinishDownload:)])
        [delegate performSelector:@selector(didFinishDownload:) withObject: [NSNumber numberWithInt: i]];
	if(downloadCount >= [urls count]){
		if ([delegate respondsToSelector:@selector(didFinishAllDownload)])
			[delegate didFinishAllDownload];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    int i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
	if ([delegate respondsToSelector:@selector(didFailDownloadWithError: withRequest:)])
        [delegate performSelector:@selector(didFailDownloadWithError: withRequest:) withObject: error withObject:[NSNumber numberWithInt:i]];
}

@end
