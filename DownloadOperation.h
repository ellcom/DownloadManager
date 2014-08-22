//
//  DownloadOperation.h
//
//  Created by Elliot Adderton on 11/07/2014.
//

#import <Foundation/Foundation.h>

typedef id (^DownloadConfigurationBlock)(NSData *data);

extern NSString* const DownloadOperationPostData;
extern NSString* const DownloadOperationTimeout;

#import "DownloadManager.h"

@interface DownloadOperation : NSOperation

@property(readonly, copy) NSURL *url;
@property(readonly, copy) NSDictionary *postData;
@property(readonly, weak) id<DownloadManagerDelegate> delegate;
@property(readonly,assign)NSTimeInterval timeout;

-(instancetype) initWithUrl:(NSURL*)url configurationBlock:(DownloadConfigurationBlock)config delegate:(id) delegate option:(NSDictionary*)options;

@end
