//
//  JsonDataGetterParent.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JsonDataGetterDelegate <NSObject>

@required

-(void)dataDidDownload;

@end


@interface JsonDataGetterParent : NSObject


@property (strong, nonatomic) NSMutableArray *topTitles;
@property int limit;
@property BOOL dataDownloaded;
@property NSURL *mainURL;
@property id jsonData;
@property (atomic, weak) id  delegate;

-(id)initWithURL:(NSString*)stringURL withLimit:(int)limit;
-(void)extractJsonData;
-(void)downloadJsonData;
-(void)allocArrays;
@end
