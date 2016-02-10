//
//  PMOPictureListTVC.m
//  Parallels_test
//
//  Created by Peter Molnar on 08/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//
// App Transport Security should be completely switched off in order to access http:// resources by IP address:
// See NSExceptionDomains:
//    https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33
//


#import "PMOPictureListTVC.h"
#import "PMOPictureViewController.h"
#import "PMOPicture.h"
#import "UIImage+Thumbnail.h"

@interface PMOPictureListTVC ()
@property (strong, nonatomic) NSMutableArray *pictureList;
@property (strong, nonatomic) PMOPicture *selectedPicture;

@end

@implementation PMOPictureListTVC


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start the fetch on a background Queue
    
    dispatch_async(kBackGroundNormalPriorityQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        kDataURL];
        [self performSelectorOnMainThread:@selector(fetchedRowData:)
                               withObject:data waitUntilDone:YES];
    });

}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return [self.pictureList count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    PMOPicture *picture = [self.pictureList objectAtIndex:indexPath.row];
    
    NSString *pictureURL = [kBaseURLForImages stringByAppendingString:picture.imageFileName];
    
    UITableViewCell *cell= [self customizedCell];
    
    UIActivityIndicatorView *loadingActivity = [self addSpinnerToView:cell.imageView];
    
    
    if (!picture.thumbnailImage) {
    // Start the fetch on a background Queue
    [self downloadImageWithURL:[NSURL URLWithString:pictureURL] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            // change the image in the cell
            [self updateCellImageView:cell.imageView withDownloadedImage:image];
            
            [loadingActivity stopAnimating];
            [loadingActivity removeFromSuperview];
            // Caching the image and the thumbnail.
            picture.image = image;
            picture.thumbnailImage = cell.imageView.image;
            
        }
    }];
    } else {
        cell.imageView.image = picture.thumbnailImage;
        [self customizeImageView:cell.imageView];
        [loadingActivity stopAnimating];
        [loadingActivity removeFromSuperview];
        
    }
    
    cell.textLabel.text = picture.imageTitle;
    cell.detailTextLabel.text = picture.imageDescription;
    
    
    return cell;
}


#pragma mark - Cell actions

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_suspend(kBackGroundNormalPriorityQueue);

    [self setSelectedPicture:self.pictureList[indexPath.row]];
    [self performSegueWithIdentifier:@"ShowImage" sender:self];
}



#pragma mark - Helpers

-(void)fetchedRowData:(NSData *)dataInResponse {
    
    NSError *error;
    // Get the JSON data serialized
    NSArray *downloadedJSONData = [NSJSONSerialization JSONObjectWithData:dataInResponse
                                                                       options:0
                                                                         error:&error];
    self.pictureList = [[NSMutableArray alloc] init];
    for (id currentItem in downloadedJSONData) {
        PMOPicture *picture = [PMOPicture PictureFromDictionary:currentItem];
        [self.pictureList addObject:picture];
    }
 
     [self.tableView reloadData]; 
    
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    
    dispatch_async(kBackGroundNormalPriorityQueue, ^{
        
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (!error) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            
            completionBlock(YES,downloadedImage);
        } else {
            completionBlock(NO,nil);
        }
    });}


- (UIActivityIndicatorView *)addSpinnerToView:(UIView *)parentView {
    UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivity setColor:[UIColor blackColor]];
    [parentView addSubview:loadingActivity];
    [parentView bringSubviewToFront:loadingActivity];
    loadingActivity.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    loadingActivity.center = parentView.center;
    [loadingActivity startAnimating];
    
    return loadingActivity;
}

#pragma mark - Cell customizations

- (UITableViewCell *)customizedCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PictureCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.clipsToBounds = YES;
    
    cell.imageView.image = [UIImage imageNamed:@"testimage"];
    
    return cell;
    
}

- (void)updateCellImageView:(UIImageView *)imageView withDownloadedImage:(UIImage *)image
{
    imageView.image = [image makeThumbnailWithSize:imageView.frame.size];
    [self customizeImageView:imageView];

}

-(void)customizeImageView:(UIImageView *)currentImageView {
    // Get the image size,since it is already scaled for the device.
    // Imageview sizes is sometimes 0, when it comes on a dequed cell and cached image
    currentImageView.layer.cornerRadius = currentImageView.image.size.width/2;
    currentImageView.layer.borderColor = [UIColor colorWithRed:217.0/255 green:34.0/255 blue:49.0/255 alpha:1.0].CGColor;
    currentImageView.layer.borderWidth= 1.0f;
    
 
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
            if ([[segue identifier]  isEqual: @"ShowImage"]) {
                PMOPictureViewController *pvc = segue.destinationViewController;
                [pvc setPicture:self.selectedPicture];
            }
    
}



@end
