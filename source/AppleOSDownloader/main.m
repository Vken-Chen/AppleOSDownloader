//
//  main.m
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/2.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKAOSDownloader.h"

void startDownload(const char* path)
{
    VKAOSDownloader* downloader = [VKAOSDownloader new];
    NSString* savePath = [NSString stringWithUTF8String:path];
    if([savePath characterAtIndex:savePath.length-1] != '/')
    {
        savePath = [savePath stringByAppendingString:@"/"];
    }
    
    [downloader download:@"http://opensource.apple.com/source/" saveTo:savePath];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        if(argc == 1)
        {
           startDownload("./");
        }else if(argc == 3)
        {
            const char* type = argv[1];
            const char* value = argv[2];
            if(strcmp(type, "/f")==0)
            {
                startDownload(value);
            }else{
               NSLog(@"error parameters，AppleOSDownloader Or AppleOSDownloader /f /Users/xxx/Desktop");
            }
        }else{
            NSLog(@"error parameters，AppleOSDownloader Or AppleOSDownloader /f /Users/xxx/Desktop");
        }
        
        
    }
    return 0;
}



