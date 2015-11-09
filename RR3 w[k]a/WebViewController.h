//
//  WebViewController.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>

@import WebKit;
@interface WebViewController : UIViewController <UIWebViewDelegate>

@property NSString *pageTitle;
@property NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
//@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rewindButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

@property bool allowLoad;

@end
