//
//  VKAOSDownloader.m
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import "VKAOSDownloader.h"
#import "VKAOSHtmlParser.h"
#import "VKAOSItemOperator.h"
#import "VKAOSItem.h"



@interface VKAOSDownloader()

@property(nonatomic,retain) VKAOSHtmlParser*    parser;

@property(nonatomic,copy)   NSString*   root;

@end

@implementation VKAOSDownloader

-(id)init{
    self = [super init];
    if(self)
    {
        _parser = [VKAOSHtmlParser new];
        
    }
    return self;
}

-(void)download:(NSString*)url saveTo:(NSString*)folder
{
    NSLog(@"CONNECTING opensource.apple.com");
    if([_parser parseUrl:url])
    {
        NSLog(@"BEGIN DOWNLOADING\r");
        NSArray* childrens = [_parser.items copy];
        for(int i=0;i<childrens.count;i++)
        {
            id children = childrens[i];
            [self handleItem:children atFolder:folder inLevel:0];
        }
    }else
    {
        NSLog(@"download fail");
    }
}

-(void)handleItem:(VKAOSItem*)item atFolder:(NSString*)folder inLevel:(NSInteger)level
{
    if(item.isFile)
    {
        NSString* saveFile = [folder stringByAppendingPathComponent:item.name];
        if( [self fileExist:saveFile])
        {
            NSLog(@"3.file[%s] exists,SKIP!!!",[item.name UTF8String]);
        }else{
            NSLog(@"3.downloading file: %s",[item.name UTF8String]);
            [self downloadFile:item.url saveTo:saveFile];
        }
        NSLog(@"[END FOLDER] ===================================\r\r");
        NSLog(@"  ");
        
    }else{
        NSLog(@"  ");
        NSLog(@"[BEGIN FOLDER] %s",[item.name UTF8String]);
        
        //创建文件夹
        NSLog(@"1.create folder ");
        NSString* newFolder = [folder stringByAppendingPathComponent:item.name];
        NSError* error;
        [[NSFileManager defaultManager]createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:&error];
        
        //处理子文件
        if([_parser parseUrl:item.url])
        {
            NSArray* items = [_parser.items copy];
            //如果level==1，则表示版本选择，选择最新的版本
            if(level==0)
            {
                VKAOSItem* it =  [self theLastVersionItem:items]; //[items lastObject];
                NSLog(@"2.choose the version:%s",[it.name UTF8String]);
                [self handleItem:it atFolder:newFolder inLevel:level+1];
            }else{
                for(int i=0;i<items.count;i++)
                {
                    id it = items[i];
                    [self handleItem:it atFolder:newFolder inLevel:level+1];
                }
            }
        }
    }
}


-(void)downloadFile:(NSString*)urlString saveTo:(NSString*)saveFile
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    [data writeToFile:saveFile atomically:YES];
}

-(VKAOSItem*)theLastVersionItem:(NSArray*)array
{
    if(array.count==0)
        return nil;
    if(array.count==1)
        return array.firstObject;
    
    VKAOSItem* item = nil;
    for(int i=0;i<array.count;i++)
    {
        id it = array[i];
        if(item==nil)
            item = it;
        else {
            float oldVersion = [self versionOfItem:item];
            float newVersion = [self versionOfItem:it];
            if(newVersion>oldVersion)
            {
                item = it;
            }
        }
    }
    return item;
}

-(float)versionOfItem:(VKAOSItem*)item
{
    NSRange head = [item.name rangeOfString:@"-"];
    NSRange end = [item.name rangeOfString:@"tar"];
    NSRange versionRange = NSMakeRange(head.location+1, end.location-1-head.location-1);
    NSString* versionString = [item.name substringWithRange:versionRange];
    return [versionString floatValue];
}

-(NSString*)tabAtLevel:(NSInteger)level
{
    NSMutableString* tab = [NSMutableString new];
    for(int i=0;i<level;i++)
    {
        [tab appendFormat:@"    "];
    }
    return tab;
}


-(BOOL)fileExist:(NSString*)fileName
{
    return [[NSFileManager defaultManager]fileExistsAtPath:fileName];
}


@end
