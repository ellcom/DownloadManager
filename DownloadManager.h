//
//  DownloadManager.h
//
//  Created by Elliot Adderton on 11/07/2014.
//

#import <Foundation/Foundation.h>

extern NSString *const DownloadMangerResponseError;
extern NSString *const DownloadMangerDownloadError;
extern NSString *const DownloadMangerHttpError;

@protocol DownloadManagerDelegate <NSObject>

@required

-(void) downloadDataFrom:(NSURL*)url didCompleteWithData:(id)data;
-(void) downloadDataFrom:(NSURL *)url didFailWithError:(NSError*)error;

@end

#import "DownloadOperation.h"

@interface DownloadManager : NSObject

+ (instancetype) instance;

- (NSOperation*)downloadDataFrom:(NSURL*)url configurationBlock:(DownloadConfigurationBlock)config delegate:(id) delegate option:(NSDictionary*)options;
- (void)cancelAllDownloads;

@end
