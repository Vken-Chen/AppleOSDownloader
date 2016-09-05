//
//  VKAOSItemOperator.h
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VKAOSItem;
@interface VKAOSItemOperator : NSObject

-(void)workWithItem:(VKAOSItem*)item inFolder:(NSString*)folder;

@end
