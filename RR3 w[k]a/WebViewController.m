//
//  WebViewController.m
//  RR3 w[k]a
//
//  Created by Kacper Augustyniak on 08.11.2015.
//  Copyright © 2015 Kacper Augustyniak. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController ()
{
    bool isGoBackChanged;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;


@end
@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    [self.forwardButton setTintColor:[UIColor grayColor]];
    [self.backButton
     setTintColor:[UIColor grayColor]];

    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.allowLoad = YES;
    self.navigationItem.title  = self.pageTitle;
    //NSLog(@"%@",self.url);
    NSMutableString *urlWithHeight = [NSMutableString stringWithFormat:self.url];

    NSURL *url = [NSURL URLWithString:urlWithHeight ];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
   
    [self.webView loadRequest:requestObj];
    
    //[self.scrollview addSubview:self.webView];
    
    
//    WKPreferences *thePreferences = [[WKPreferences alloc] init];
//    thePreferences.javaScriptEnabled = NO;
//    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
//    //theConfiguration.preferences = thePreferences;
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
//   
//    
//    //webView.navigationDelegate = self;
//    NSURL *nsurl = [NSURL URLWithString:self.url ];
//    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
//    [webView loadRequest:nsrequest];
//    [webView setUserInteractionEnabled:NO];
//    [self.view addSubview:webView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    self.allowLoad = YES;
    if([self.webView isLoading])
        {
            [self.webView stopLoading];
        }
    
}

#pragma mark web wiew (note notworking - no UIWebViewDelegate)

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
//NSLog(@" click?? ");
    if (navigationType == UIWebViewNavigationTypeOther) {
        
        //NSLog(@" click ");
    }  
    //return YES;
    //NSLog(@"%d",self.allowLoad);
    [self navigationButtonsColors];
    return self.allowLoad;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    self.allowLoad = NO;
   // NSLog(@" teraz ");
    //[self.webView setUserInteractionEnabled:self.allowLoad];
}

#pragma mark handling bottom bar buttons


- (IBAction)backButtonPressed:(id)sender {
    if ([self.webView canGoBack]){
        [self.webView goBack];
    }
}
- (IBAction)forwardButtonPressed:(id)sender {
    //NSLog(@"%d",self.webView.canGoForward);
    if ([self.webView canGoForward]){
        [self.webView goForward];
    }
}

- (void)navigationButtonsColors{
    if ([self.webView canGoForward]){
        [self.forwardButton setTintColor:self.view.tintColor];
    }else{
        [self.forwardButton setTintColor:[UIColor grayColor]];
    }
    if ([self.webView canGoBack]){
        [self.backButton setTintColor:self.view.tintColor];
    }else{
        [self.backButton setTintColor:[UIColor lightGrayColor]];
    }
    
    if (![self.webView canGoForward]&&![self.webView canGoBack]) {
        [self.toolbar setHidden:YES];
        //[self.navigationController setToolbarHidden:YES animated:YES];
    }else{
        //[self.navigationController setToolbarHidden:NO animated:YES];
        [self.toolbar setHidden:NO];
    }
}
//add pan gesture recognizer in storyboard
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if(translation.y > 0)
    {
        NSLog(@"Drag down");
    } else
    {
        NSLog(@"Drag up");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
