//
//  JsonDataGetterParent.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonDataGetterParent : NSObject


@property (strong, nonatomic) NSMutableArray *topTitles;
@property int limit;
@property BOOL dataDownloaded;
@property NSURL *mainURL;
@property id jsonData;

-(id)initWithURL:(NSString*)stringURL withLimit:(int)limit;
-(void)extractJsonData;
-(void)downloadJsonData;
@end
