//
//  VKAOSItemOperator.m
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import "VKAOSItemOperator.h"
#import "VKAOSItem.h"

@implementation VKAOSItemOperator

-(void)workWithItem:(VKAOSItem*)item inFolder:(NSString*)folder
{
    if(item ==nil)
        return ;
    
    if(item.isFile)
    {
        NSString* saveFile = [folder stringByAppendingPathComponent:item.name];
        [self downloadFile:item.url saveTo:saveFile];
    }else{
        NSString* newFolder = [folder stringByAppendingPathComponent:item.name];
        NSError* error;
        [[NSFileManager defaultManager]createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"create folder :%@ ",newFolder);
    }
}

-(void)downloadFile:(NSString*)urlString saveTo:(NSString*)saveFile
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    [data writeToFile:saveFile atomically:YES];
    
    NSLog(@"download file :%@ \tfrom:%@",saveFile,urlString);
}

@end
