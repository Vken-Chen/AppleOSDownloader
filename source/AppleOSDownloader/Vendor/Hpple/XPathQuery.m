#import "XPathQuery.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>


@implementation XPathQuery



+(NSDictionary*) dictionaryForNode:(xmlNodePtr)currentNode parent:(NSMutableDictionary *)parentResult isParent:(BOOL)parentContent
{
  NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];

  if (currentNode->name)
    {
      NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
      [resultForNode setObject:currentNodeContent forKey:@"nodeName"];
    }

  if (currentNode->content && currentNode->content != (xmlChar *)-1)
    {
      NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];

      if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
        {
            if(parentContent)
            {
                [parentResult setObject:[currentNodeContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"nodeContent"];
                return nil;
            }
            if (currentNodeContent != nil)
            {
                [resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
            }
//            NSLog(@"content: %@",currentNodeContent);
            return resultForNode;

        }
      else {
          [resultForNode setObject:currentNodeContent forKey:@"nodeContent"];          
      }


    }

  xmlAttr *attribute = currentNode->properties;
  if (attribute)
    {
      NSMutableArray *attributeArray = [NSMutableArray array];
      while (attribute)
        {
          NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
          NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
          if (attributeName)
            {
//                NSLog(@"Attribute Name Set: %@",attributeName);
              [attributeDictionary setObject:attributeName forKey:@"attributeName"];
            }

          if (attribute->children)
            {
                NSDictionary *childDictionary = [self dictionaryForNode:attribute->children parent: attributeDictionary isParent:TRUE];
              if (childDictionary)
                {
                  [attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
                }
            }

          if ([attributeDictionary count] > 0)
            {
              [attributeArray addObject:attributeDictionary];
            }
          attribute = attribute->next;
        }

      if ([attributeArray count] > 0)
        {
          [resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
        }
    }

  xmlNodePtr childNode = currentNode->children;
  if (childNode)
    {
      NSMutableArray *childContentArray = [NSMutableArray array];
      while (childNode)
        {
            NSDictionary *childDictionary = [self dictionaryForNode:childNode parent:resultForNode isParent:FALSE];
           
          if (childDictionary)
            {
              [childContentArray addObject:childDictionary];
            }
          childNode = childNode->next;
        }
      if ([childContentArray count] > 0)
        {
          [resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
        }
    }

  xmlBufferPtr buffer = xmlBufferCreate();
  xmlNodeDump(buffer, currentNode->doc, currentNode, 0, 0);

  NSString *rawContent = [NSString stringWithCString:(const char *)buffer->content encoding:NSUTF8StringEncoding];
  if (rawContent != nil)
  {
      [resultForNode setObject:rawContent forKey:@"raw"];
  }
    xmlBufferFree(buffer);
    
  return resultForNode;
}



+(NSArray *)perform:(xmlDocPtr)doc xPathQuery:(NSString *)query
{
  xmlXPathContextPtr xpathCtx;
  xmlXPathObjectPtr xpathObj;

  /* Create xpath evaluation context */
  xpathCtx = xmlXPathNewContext(doc);
  if(xpathCtx == NULL)
    {
      NSLog(@"Unable to create XPath context.");
      return nil;
    }

  /* Evaluate xpath expression */
  xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
  if(xpathObj == NULL) {
    NSLog(@"Unable to evaluate XPath.");
    xmlXPathFreeContext(xpathCtx);
    return nil;
  }

  xmlNodeSetPtr nodes = xpathObj->nodesetval;
  if (!nodes)
    {
      NSLog(@"Nodes was nil.");
      xmlXPathFreeObject(xpathObj);
      xmlXPathFreeContext(xpathCtx);
      return nil;
    }

  NSMutableArray *resultNodes = [NSMutableArray array];
  for (NSInteger i = 0; i < nodes->nodeNr; i++)
    {
        NSDictionary *nodeDictionary  = [self dictionaryForNode:nodes->nodeTab[i] parent: nil isParent:FALSE];
      
      if (nodeDictionary)
        {
          [resultNodes addObject:nodeDictionary];
        }
    }

  /* Cleanup */
  xmlXPathFreeObject(xpathObj);
  xmlXPathFreeContext(xpathCtx);

  return resultNodes;
}





+(NSArray*)performHTML:(NSData*) document xPathQuery:(NSString*) query
{
    return [self performHTML:document xPathQuery:query encoding:nil];
}

+(NSArray*)performHTML:(NSData*) document xPathQuery:(NSString*) query encoding:(NSString *)encoding
{
    xmlDocPtr doc;
    
    /* Load XML document */
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    
    doc = htmlReadMemory([document bytes], (int)[document length], "", encoded, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
    
    if (doc == NULL)
    {
        NSLog(@"Unable to parse.");
        return nil;
    }
    
    NSArray *result = [self perform:doc xPathQuery:query];
    xmlFreeDoc(doc);
    
    return result;
}

+(NSArray*)performXML:(NSData*) document xPathQuery:(NSString*) query
{
    return [self performXML:document xPathQuery:query encoding:nil];
}

+(NSArray*)performXML:(NSData*) document xPathQuery:(NSString*) query encoding:(NSString *)encoding
{
    xmlDocPtr doc;
    
    /* Load XML document */
    const char *encoded = encoding ? [encoding cStringUsingEncoding:NSUTF8StringEncoding] : NULL;
    
    doc = xmlReadMemory([document bytes], (int)[document length], "", encoded, XML_PARSE_RECOVER);
    
    if (doc == NULL)
    {
        NSLog(@"Unable to parse.");
        return nil;
    }
    
    
    NSArray *result = [self perform:doc xPathQuery:query];
    xmlFreeDoc(doc);
    
    return result;
}

@end

