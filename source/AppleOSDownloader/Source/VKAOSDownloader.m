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

    if([_parser parseUrl:url])
    {
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
        [self downloadFile:item.url saveTo:saveFile];
        NSLog(@"download file :%@ ",item.name);
    }else{
        
        //创建文件夹
        NSString* newFolder = [folder stringByAppendingPathComponent:item.name];
        NSError* error;
        [[NSFileManager defaultManager]createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"create folder :%@ ",item.name);
        //处理子文件
        if([_parser parseUrl:item.url])
        {
            NSArray* items = [_parser.items copy];
            //如果level==1，则表示版本选择，选择最新的版本
            if(level==0)
            {
                VKAOSItem* it = [items lastObject];
                NSLog(@"choose the version:%@",it.name);
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


@end
