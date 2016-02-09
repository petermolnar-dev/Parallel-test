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

@interface PMOPictureListTVC ()
@property (strong, nonatomic) NSMutableArray *pictureList;
@property (strong, nonatomic) PMOPicture *selectedPicture;

@end

@implementation PMOPictureListTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start the fetch on a diffrenet queue from the main
    
    dispatch_async(kBackGroundQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        kDataURL];
        [self performSelectorOnMainThread:@selector(fetchedRowData:)
                               withObject:data waitUntilDone:YES];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Only one section for the list
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.pictureList count];
    
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PictureCell"];
    PMOPicture *picture = [self.pictureList objectAtIndex:indexPath.row];

    NSString *pictureURL = [kBaseURLForImages stringByAppendingString:picture.imageFileName];
    
    
    
    // Start the fetch on a diffrenet queue from the main
    
    cell.imageView.image = [UIImage imageNamed:@"testimage"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIActivityIndicatorView *loadingActivity = [self addSpinnerToView:cell.imageView];

    // download the image asynchronously
    [self downloadImageWithURL:[NSURL URLWithString:pictureURL] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            // change the image in the cell
            cell.imageView.image = image;
            [loadingActivity stopAnimating];
            [loadingActivity removeFromSuperview];
            picture.image = image;
            
        }
    }];
    
    cell.textLabel.text = picture.imageTitle;
    cell.detailTextLabel.text = picture.imageDescription;

    
    return cell;
}


#pragma mark - Cell actions

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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




#pragma mark - Set Activity on view
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


#pragma mark - Custom actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
            if ([[segue identifier]  isEqual: @"ShowImage"]) {
                PMOPictureViewController *pvc = segue.destinationViewController;
                [pvc setPicture:self.selectedPicture];
            }
    
}



@end
