//
//  VKAOSItem.h
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKAOSItem : NSObject

@property(nonatomic,copy)   NSString*   url;
@property(nonatomic,copy)   NSString*   name;
@property(nonatomic,copy)   NSString*   relativePath;
@property(nonatomic,assign) BOOL        isFile;

@end
