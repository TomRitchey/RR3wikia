//
//  JsonDataGetterParent.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "JsonDataGetterParent.h"

@implementation JsonDataGetterParent
-(id)initWithURL:(NSString*)stringURL withLimit:(int)limit{
    if (!(self = [super init]))
    {return nil;}
    [self allocArrays];
    self.limit = limit;
    self.mainURL = [NSURL URLWithString:stringURL];
    return self;
}

-(void)dataDidDownload{
    [self extractJsonData];
}

-(void)downloadJsonData{
    //NSLog(@"%@ dasdasd",self.mainURL);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:self.mainURL];
    //NSLog(@"%@",self.mainURL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!data){
        }else{
            self.jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
        
        [self extractJsonData];
        if ([_delegate respondsToSelector:@selector(dataDidDownload)]) {
            [_delegate dataDidDownload];
        }
        
    }] resume];
}

-(void)extractJsonData{

    if (self.topTitles.count != 0){
        [self.topTitles removeAllObjects];
    }
    
    for(int i=0;i<[[self.jsonData objectForKey:@"items"] count];i++){
        NSObject *tempTitle =[[[self.jsonData objectForKey:@"items"] objectAtIndex: i] valueForKey:@"title"];
        
        [self.topTitles addObject:tempTitle];
    }

}

-(void)allocArrays{
    self.topTitles = [[NSMutableArray alloc]init];}
@end
