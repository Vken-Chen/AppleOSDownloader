//
//  VKAOSHtmlParser.m
//  AppleOSDownloader
//
//  Created by vkenchen on 16/9/4.
//  Copyright © 2016年 Vkenchen. All rights reserved.
//

#import "VKAOSHtmlParser.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "VKAOSItem.h"

@interface VKAOSHtmlParser()

@property(nonatomic,copy)   VKOperationComplete callback;
@property(nonatomic,copy)   NSString*           url;
@property(nonatomic,retain) TFHpple *           hpple;
@property(nonatomic,retain) TFHppleElement*     body;


@end

@implementation VKAOSHtmlParser

-(void)parseUrl:(NSString*)url complete:(VKOperationComplete)block
{
    _callback = block;
    _url = url;
    
//    __weak VKAOSHtmlParser *weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//        
//    });
    
    if( [self loadHtmlContent])
    {
        if([self parseHtmlContent])
        {
            block(YES,nil,nil);
        }else{
            block(NO,nil,@"html parse error");
        }
        
    }else{
        block(NO,nil,@"html load error");
    }
    
}

-(BOOL)parseUrl:(NSString*)url
{
    _url = url;
    if( [self loadHtmlContent])
    {
        if([self parseHtmlContent])
        {
            return YES;
        }else{
            return FALSE;
        }
        
    }else{
        return FALSE;
    }
}

-(BOOL)loadHtmlContent
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_url]];
    if(data ==nil || data.length==0)
        return NO;
    TFHpple * doc  = [[TFHpple alloc] initWithHTMLData:data];
    self.hpple = doc;
    return YES;
}

-(BOOL)parseHtmlContent
{
    if(_items == nil)
    {
        _items = [NSMutableArray new];
    }else{
        [_items removeAllObjects];
        
    }
    
    NSArray* trs = [self.body searchWithXPathQuery:@"//tr"];
    for(TFHppleElement* tr in trs)
    {
        VKAOSItem* item = [self itemAtElement:tr];
        if(item == nil)
            continue;
        [_items addObject:item];
    }

    
    return YES;
}


-(void)setHpple:(TFHpple *)hpple
{
    _hpple = hpple;
    NSArray * elements  = [_hpple searchWithXPathQuery:@"//body"];
    //如果没有body标签，则不进行搜索
    if(elements.count<=0)
        return ;
    
    TFHppleElement*  bodyElement = [elements objectAtIndex:0];
    if(bodyElement == nil)
        return ;
    
    self.body = bodyElement;
}

-(VKAOSItem*)itemAtElement:(TFHppleElement*)trElement
{
    if(trElement ==nil || ![trElement.tagName isEqualToString:@"tr"])
        return nil;
    NSArray* tds = [trElement searchWithXPathQuery:@"//td"];
    if(tds == nil || [tds count]<=0)
        return nil;
    
    //title
    VKAOSItem* item = [VKAOSItem new];
    
    for(TFHppleElement* td in tds)
    {
        NSArray* as = [td searchWithXPathQuery:@"//a"];
        if(as == nil || as.count<=0 )
            continue;
        TFHppleElement* a = as[0];
        TFHppleElement* children = a.firstChild;
        
        
        if(a.children.count==1)
        {
            if([children.tagName isEqualToString:@"text"])
            {
                if([a.text isEqualToString:@"Parent Directory"])
                {
                    item = nil;
                    return item;
                }else{
                    
                    item.name = a.text;
                    if([item.name containsString:@"\\"])
                    {
                        item.isFile = NO;
                    }
                    
                    item.relativePath = a.attributes[@"href"];
                    item.url = [_url stringByAppendingString: item.relativePath];
                    
                }
            }else if([children.tagName isEqualToString:@"img"])
            {
                NSString* alt = children.attributes[@"alt"];
                if([alt isEqualToString:@"[DIR]"])
                {
                    item.isFile = NO;
                }else{
                    item.isFile = YES;
                }
            }
        }else{
            continue;
        }
        
    }
    
    return item;
}

@end
