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
  _webView.scrollView.delegate = self;
  self.webView.scalesPageToFit = YES;
  self.url = [self replaceCharacters:self.url];
  
  [self.forwardButton setTintColor:[UIColor grayColor]];
  [self.backButton setTintColor:[UIColor grayColor]];
  [self.toolbar setHidden:YES];
  _progressBar.progress = 0;
  
  self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
//  self.allowLoad = YES;
  self.navigationItem.title  = self.pageTitle;
  [self loadConnectionFromUrlWithString:self.url];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated {
  if([self.webView isLoading])
  {
    [self.webView stopLoading];
  }
  
}

- (void)dealloc{
  //NSLog(@"dealloc");
  [self.webView loadHTMLString:@"" baseURL:nil];
  [self.webView stopLoading];
  [self.webView setDelegate:nil];
  [self.webView removeFromSuperview];
  [self setWebView:nil];
  [[NSURLCache sharedURLCache] removeAllCachedResponses];
  [[NSURLCache sharedURLCache] setDiskCapacity:0];
  [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}


- (void)loadConnectionFromUrlWithString:(NSString*)urlString{
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
  
  NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  _downloadTask = [session downloadTaskWithRequest:requestObj];
  [_downloadTask resume];
}

#pragma mark - NSURLSessionTaskDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

  
  NSString *webData= [NSString stringWithContentsOfURL:location];
  //NSLog(@"%@",webData);
  
  NSError *error = nil;
  
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<div.*? class=\"wikia-ad noprint((.*((\n).*?)+))<\/div>" options:NSRegularExpressionCaseInsensitive error:&error];
  
  //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script(.*((\n).*?)+?)window.adslots2.push(.*((\n).+?)+?)<\/script>" options:NSRegularExpressionCaseInsensitive error:&error];
  
  NSString *modifiedString = [regex stringByReplacingMatchesInString:webData options:0 range:NSMakeRange(0, [webData length]) withTemplate:@" "];
  
  NSLog(@" html %@", modifiedString);
//  modifiedString = webData;
  
  [_webView loadHTMLString:modifiedString baseURL:[NSURL URLWithString:@"http://rr3.wikia.com/"]];
  //[_webView loadData:[NSData dataWithContentsOfURL:location] MIMEType:@"text/html" textEncodingName:@"@utf-8" baseURL:[NSURL URLWithString:@"http://rr3.wikia.com/"]];
  
  _progressBar.progress = 1;
  [UIView transitionWithView:_progressBar
                    duration:1.2
                     options:UIViewAnimationOptionTransitionCrossDissolve
                  animations:NULL
                  completion:NULL];
  
  _progressBar.hidden = YES;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
  _progressBar.progress = totalBytesWritten/totalBytesExpectedToWrite;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
      return NO;
      _progressBar.hidden = NO;
      [_downloadTask cancel];
      //[self loadConnectionFromUrlWithString:[[request URL]absoluteString]];
      [self navigationButtonsColors];
      //return NO;
    }
    [self navigationButtonsColors];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  [self navigationButtonsColors];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
  [self navigationButtonsColors];
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

# pragma mark scrolling behaviour

//add pan gesture recognizer in storyboard
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _currentToolbarFrame = self.toolbar.frame;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat yToolbarFrame = screenRect.size.height - self.toolbar.frame.size.height;
    
    //NSLog(@"translation %f", translation.y);
    
    if (screenHeight - self.toolbar.frame.origin.y > self.toolbar.frame.origin.y - yToolbarFrame && translation.y > 0) {
                [self showToolBar];
        }else{  [self hideToolbar];  }
    
}


- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    [self showToolBar];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat yToolbarFrame = screenRect.size.height - self.toolbar.frame.size.height;

    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];

    if (_currentToolbarFrame.origin.y - translation.y <= screenHeight
        && _currentToolbarFrame.origin.y  - translation.y
        >= yToolbarFrame
        && !self.toolbar.isHidden) {
                [self moveToolbar:self.toolbar withTranslation:translation];
    }

}

#pragma mark toolbar behaviour

-(void)moveToolbar:(UIToolbar*)tb withTranslation:(CGPoint)translation{
    tb.frame = CGRectMake(tb.frame.origin.x,
                          _currentToolbarFrame.origin.y - translation.y, tb.frame.size.width, tb.frame.size.height);
}

-(void)hideToolbar{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.2 animations:^{
        self.toolbar.frame = CGRectMake(self.toolbar.frame.origin.x, screenRect.size.height,self.toolbar.frame.size.width,self.toolbar.frame.size.height);
    }];
}

-(void)showToolBar{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.2 animations:^{
        self.toolbar.frame = CGRectMake(self.toolbar.frame.origin.x, screenRect.size.height - self.toolbar.frame.size.height,self.toolbar.frame.size.width,self.toolbar.frame.size.height);
    }];
}

#pragma mark - allert long press

-(void)addToAllertController{
    
}

-(NSString *)replaceCharacters:(NSString *)string{
  
  string = [string stringByReplacingOccurrencesOfString:@"%27"
                                             withString:@"'"];
  return string;
}


@end
