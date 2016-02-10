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
@property (nonatomic, strong) NSURL *imageURL;

@end

@implementation PMOPictureViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[self.picture.imageTitle stringByAppendingString:[@" - " stringByAppendingString:self.picture.imageDescription]]];
    [self setImageURL:[NSURL URLWithString:[kBaseURLForImages stringByAppendingString:self.picture.imageFileName]]];
    [self.scrollView addSubview:self.imageView];
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
    
    self.scrollView.zoomScale = 0.5;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
//      [self.imageView sizeToFit];
    
    [self.spinner stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
}

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    [self startDownloadingImage];
    
}

#pragma mark - ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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
        [self.spinner startAnimating];
        
        if (!self.picture.image) { // Image hasn't been downloaded yet
            [self downloadImageWithURL:self.imageURL completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    self.image = image;
                    [self.spinner stopAnimating];
                    self.picture.image = image;
                }
                dispatch_resume(kBackGroundNormalPriorityQueue);
            }];

  
        } else {
            self.image = self.picture.image;
            [self.spinner stopAnimating];
        }
        
    }
}
@end
