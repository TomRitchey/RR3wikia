//
//  JsonDataGetter.m
//  Top GoT Chars
//
//  Created by Kacper Augustyniak on 07.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "JsonDataGetter.h"

@interface JsonDataGetter ()

@end

@implementation JsonDataGetter

-(id)init{
    if (!(self = [super init]))
        return nil;
    [self allocArrays];
    self.limit = 75;
    NSString *category = @"Characters";
    NSString *stringURL=[NSString stringWithFormat:@"http://rr3.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",category,self.limit];
    self.mainURL = [NSURL URLWithString:stringURL];
    self.dataDownloaded = NO;
    return self;
}

-(id)initWithLimit:(int)limit{
    if (!(self = [super init]))
    {return nil;}
    [self allocArrays];
    NSString *category = @"Characters";
    self.limit = limit;
    NSString *stringURL=[NSString stringWithFormat:@"http://rr3.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",category,self.limit];
    self.mainURL = [NSURL URLWithString:stringURL];
    
    self.dataDownloaded = NO;
    return self;
}

-(id)initWithCategory:(NSString*)category withLimit:(int)limit{

    if (!(self = [super init]))
    {return nil;}
    [self allocArrays];
    //NSLog(@"%@",self.category);
    self.limit = limit;
    NSString *stringURL=[NSString stringWithFormat:@"http://rr3.wikia.com/api/v1/Articles/Top?expand=1&category=%@&limit=%i",category,self.limit];
    self.mainURL = [NSURL URLWithString:stringURL];
    
    //NSLog(@"%@ dasdasd",self.mainURL);
    self.dataDownloaded = NO;
    return self;
}

-(id)initWithURL:(NSString*)stringURL{
    if (!(self = [super init]))
    {return nil;}
    [self allocArrays];
    self.mainURL = [NSURL URLWithString:stringURL];
    self.limit = 75;
    self.dataDownloaded = NO;
    return self;
}
-(void)dealloc{
    @try {
        [self removeObserver:self forKeyPath:@"self.dataDownloaded"];
    }
    @catch (NSException *exception) {
        
    }
}

-(void)allocArrays{
    [super allocArrays];
    self.topThumbnails = [[NSMutableArray alloc]init];
    self.topUrls = [[NSMutableArray alloc]init];
    
}

-(void)downloadJsonData{
     //NSLog(@" self data = %hhd",self.dataDownloaded);
    [self addObserver:self forKeyPath:@"self.dataDownloaded" options:NSKeyValueObservingOptionOld context:NULL];
    [super downloadJsonData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"self.dataDownloaded"]&& self.dataDownloaded == YES) {
        //NSLog(@" self data = %hhd",self.dataDownloaded);
        [self extractJsonData];
    }
}

-(void)extractJsonData{
    
    [super extractJsonData];
    if (self.topThumbnails.count != 0){
        [self.topThumbnails removeAllObjects];
        [self.topUrls removeAllObjects];
    }

    for(int i=0;i<[[self.jsonData objectForKey:@"items"] count];i++){
        
        NSObject *tempUrl = [NSString stringWithFormat:@"%@%@",[self.jsonData valueForKey:@"basepath"],[[[self.jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"url"]];
        [self.topUrls addObject:tempUrl];
        
        
        NSString *urlThumbnail = [[[self.jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"thumbnail"];
        [self.topThumbnails addObject:urlThumbnail];
        
    }
    
    //NSLog(@"%@",self.topTitles);
}

-(void)sortInAlphabeticalOrder{
    NSMutableArray *combined = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < self.topTitles.count; i++) {
        [combined addObject: @{@"title" : self.topTitles[i], @"thumbnail_address": self.topThumbnails[i],@"articleURLs" : self.topUrls[i]}];
    }
    
    [combined sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    self.topTitles = [combined valueForKey:@"title"];
    self.topThumbnails = [combined valueForKey:@"thumbnail_address"];
    self.topUrls = [combined valueForKey:@"articleURLs"];
}

#pragma mark Getters

-(NSMutableArray*)getTopTitles{
    if (!self.jsonData) {
        return nil;
    }
    return self.topTitles;
}

-(NSMutableArray*)getTopUrls{
    if (!self.jsonData) {
        return nil;
    }
    return self.topUrls;
}

-(NSMutableArray*)getTopThumbnails{
    if (!self.jsonData) {
        return nil;
    }
    return self.topThumbnails;
}

@end
