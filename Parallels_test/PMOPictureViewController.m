//
//  PMOPictureViewController.m
//  Parallels_test
//
//  Created by Peter Molnar on 09/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import "PMOPictureViewController.h"

@interface PMOPictureViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;


@end

@implementation PMOPictureViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
  
    [self.scrollView addSubview:self.imageView];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden)
    {
        [self showBackButtonOnSplitViewController];
    }
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self updateScrollViewToPictureFit];
     } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Accessors

- (UIImageView *)imageView {
    
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

//Small trick, we are using the accessor to get access to the imageView's image, not for the self.image
- (UIImage *)image {
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.scrollView.zoomScale = 1.0;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;

    [self updateScrollViewToPictureFit];
    
}

- (void)setScrollView:(UIScrollView *)scrollView {

    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.02;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    
    //    Needs to set up, for the case whenself,image set before the scollview
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    [self startDownloadingImage];
    
}

#pragma mark - ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate


- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc
    willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        [self showBackButtonOnSplitViewController];
    }
}



#pragma mark - Helpers

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    
    dispatch_async(kBackGroundHighPriorityQueue, ^{
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (!error) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            completionBlock(YES,downloadedImage);
        } else {
            completionBlock(NO,nil);
        }
    });
}

-(void)startDownloadingImage {
    self.image = nil;
    
    if (self.imageURL) {
        if (!self.picture.image) { // Image hasn't been downloaded yet
            [self.spinner setHidden:NO];
            [self.spinner startAnimating];
            [self downloadImageWithURL:self.imageURL completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    self.image = image;
                    self.picture.image = image;
                    [self.spinner stopAnimating];
                    [self.spinner setHidden:YES];
                }
                dispatch_resume(kBackGroundNormalPriorityQueue);
            }];
        } else {
            [self.spinner setHidden:YES];
            self.image = self.picture.image;
        }
    }
}

- (void)updateScrollViewToPictureFit
{
    float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width, self.view.bounds.size.height / self.imageView.image.size.height);
    // Set back to self.scrollView.zoomScale=1.0; if they want to see the full image, in real size.
    self.scrollView.zoomScale=minZoom;

}

-(void)showBackButtonOnSplitViewController
{
    UIBarButtonItem *barButtonItem = self.splitViewController.displayModeButtonItem;
    barButtonItem.title = @"Show List";
    self.navigationItem.leftBarButtonItem = barButtonItem;

}


@end
