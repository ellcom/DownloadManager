//
//  DownloadOperation.m
//
//  Created by Elliot Adderton on 11/07/2014.
//

#import "DownloadOperation.h"

NSString* const DownloadOperationPostData = @"DownloadOperationPostData";
NSString* const DownloadOperationTimeout = @"DownloadOperationTimeout";

@interface DownloadOperation()

@property(readwrite, copy) NSURL *url;
@property(readwrite, copy) NSDictionary *postData;
@property(readwrite, weak) id<DownloadManagerDelegate> delegate;
@property(nonatomic,copy) DownloadConfigurationBlock config;
@property(readwrite,assign)NSTimeInterval timeout;

@end

@implementation DownloadOperation


-(instancetype) initWithUrl:(NSURL*)url configurationBlock:(DownloadConfigurationBlock)config delegate:(id) delegate option:(NSDictionary*)options
{
    if (self = [super init])
    {
        NSAssert(url != nil, @"DownloadOperation: URL Cannot be nil");
        NSAssert([[url absoluteString] length], @"URL Cannot be empty");
        self.url = url;
        
        NSAssert(delegate != nil, @"DownloadOperation: Delegate Cannot be nil");
        self.delegate = delegate;
        
        if (config)
        {
            self.config = [config copy];
        }
        
        if (options) {
            if ([options objectForKey:DownloadOperationPostData]) {
                self.postData = [options objectForKey:DownloadOperationPostData];
            }
            if ([options objectForKey:DownloadOperationTimeout]) {
                self.timeout = (NSTimeInterval)[[options objectForKey:DownloadOperationTimeout] doubleValue];
            } else {
                self.timeout = 10;
            }
        }
    }
    
    return self;
}

-(void) main
{
    if (self.isCancelled)
    {
        return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //NSURLCacheStorageNotAllowed ->? Currently a bug with apple
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: self.url
                                                  cachePolicy: 0
                                              timeoutInterval: self.timeout];
    NSHTTPURLResponse *response;
    NSError *error;
    
    if (self.postData!=nil) {
        request.HTTPMethod = @"POST";
        NSData *postData = [self encodeDictionary:self.postData];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
        //NSLog(@"%@",[NSString stringWithUTF8String:[postData bytes]]);
        request.HTTPBody = postData;
    }
    
    id data = [NSURLConnection sendSynchronousRequest: request
                                    returningResponse: &response
                                                error: &error];
    if (self.isCancelled)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return;
    }
    
    if(!error && [response statusCode] != 200)
    {
        NSLog(@"Status Code: %li for url: %@", (long)[response statusCode],[self.url absoluteString]);
        error = [[NSError alloc] initWithDomain: DownloadMangerResponseError
                                           code: 200
                                       userInfo: nil];
    }
    
    if (data!=nil && ((NSData*)data).length && !error)
    {
        if(self.config != nil)
        {
            data = self.config(data);
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate downloadDataFrom:[self.url copy] didCompleteWithData:[data copy]];
        });
        /*[(NSObject*)self.delegate performSelectorOnMainThread: @selector(downloadDataFrom:didCompleteWithData:)
                                                   withObject: @[self.url, [data copy]]
                                                waitUntilDone: NO];*/
    }
    else
    {
        
        if (!error)
        {
            error = [[NSError alloc] initWithDomain: DownloadMangerDownloadError
                                               code: 200
                                           userInfo: nil];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate downloadDataFrom:[self.url copy] didFailWithError:[error copy]];
        });
        /*[(NSObject*)self.delegate performSelectorOnMainThread: @selector(downloadDataFrom:didFailWithError:)
                                                   withObject: @[self.url, error]
                                                waitUntilDone: NO];*/
    }
}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        //NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    NSLog(@"Send to server: %@", encodedDictionary);
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}



@end
