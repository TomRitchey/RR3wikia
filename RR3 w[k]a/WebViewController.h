//
//  WebViewController.h
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import <UIKit/UIKit.h>

@import WebKit;
@interface WebViewController : UIViewController <UIWebViewDelegate,UIScrollViewDelegate, NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSString *pageTitle;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (atomic) BOOL canGoBack;
@property (atomic) BOOL canGoForward;
@property (strong, nonatomic) NSMutableArray *backForwardlist;
@property (nonatomic) NSUInteger backForwardlistPosition;

@property (strong, nonatomic) NSURLSessionTask* downloadTask;

@property BOOL allowToolbar;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

@property (nonatomic) CGRect currentToolbarFrame;

@end
