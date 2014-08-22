//
//  DownloadManager.m
//
//  Created by Elliot Adderton on 11/07/2014.
//

#import "DownloadManager.h"

NSString * const DownloadMangerResponseError = @"DownloadMangerResponseError";
NSString * const DownloadMangerDownloadError = @"DownloadMangerDownloadError";
NSString * const DownloadMangerHttpError = @"DownloadMangerHttpError";

@implementation DownloadManager{

    NSOperationQueue *queue;
}

+(instancetype) instance
{
    static DownloadManager *singleton;
    static dispatch_once_t dispatch_once_token = 0;
    dispatch_once(&dispatch_once_token, ^{
        singleton = [[DownloadManager alloc] init];
    });
    
    return singleton;
}

- (instancetype)init
{
    if(self = [super init]){
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;

    }

    return self;
}

- (NSOperation*)downloadDataFrom:(NSURL*)url configurationBlock:(DownloadConfigurationBlock)config delegate:(id) delegate option:(NSDictionary*)options
{
    NSOperation *operation = [[DownloadOperation alloc] initWithUrl:url
                                                 configurationBlock:[config copy]
                                                           delegate:delegate option:options];
    [queue addOperation:operation];
    return operation;
    
}

- (void)cancelAllDownloads
{
    [queue cancelAllOperations];
}

@end
