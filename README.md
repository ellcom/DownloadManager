DownloadManager
===============

Simple iOS Download Manager

This is a simple and easy to use Download manager for iOS and Mac OSX. It should be used when something like AFNetworking is too much but NSData withURL isn't enough.

Works via a shared instance on the DownloadManager class then use

````
- (NSOperation*)downloadDataFrom:(NSURL*)url configurationBlock:(DownloadConfigurationBlock)config delegate:(id) delegate option:(NSDictionary*)options;
````

to fire off the requestion. The DownloadConfigurationBlock is used for converting NSData into a NSDictionary, UIImage, etc. if you don't define one then the NSData is just returned.


You have a DownloadOperationTimeout and DownloadOperationPostData option, the timeout is 10 by default. The DownloadOperationPostData should be keys and values of the data you want to post, otherwise a GET is made instead.

The results come back via making the calling View Controller a DownloadManagerDelegate, the following methods then become requied.

```
- (void)downloadDataFrom:(NSURL*)url didCompleteWithData:(id)data;
- (void)downloadDataFrom:(NSURL *)url didFailWithError:(NSError*)error;
````

