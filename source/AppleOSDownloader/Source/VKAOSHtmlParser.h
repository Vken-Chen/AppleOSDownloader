//
//  VKAOSHtmlParser.h
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKAOS.h"

@interface VKAOSHtmlParser : NSObject

@property(nonatomic,retain) NSMutableArray*     items;

-(BOOL)parseUrl:(NSString*)url;

-(void)parseUrl:(NSString*)url complete:(VKOperationComplete)block;

@end
