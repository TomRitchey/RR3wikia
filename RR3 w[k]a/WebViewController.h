//
//  WebViewController.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property NSString *pageTitle;
@property NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
