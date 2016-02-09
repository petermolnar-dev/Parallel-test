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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:self.picture.imageTitle];
    [self setImageURL:[NSURL URLWithString:[kBaseURLForImages stringByAppendingString:self.picture.imageFileName]]];
    [self.scrollView addSubview:self.imageView];
}

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
    
      [self.imageView sizeToFit];
    
    [self.spinner stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
}

#pragma mark - ScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL {
    
    _imageURL = imageURL;
    [self startDownloadingImage];
    
}

-(void)startDownloadingImage {
    self.image = nil;
    
    if (self.imageURL) {
        [self.spinner startAnimating];
        
        if (!self.picture.image) {
            NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
  
        } else {
            self.image = self.picture.image;
        }
        
    }
}
@end
