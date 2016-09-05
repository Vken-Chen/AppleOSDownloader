//
//  VKAOSDownloader.h
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKAOSDownloader : NSObject

-(void)download:(NSString*)url saveTo:(NSString*)folder;

@end
