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

@interface PMOPictureListTVC ()
@property (strong, nonatomic) NSArray *pictureList;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PictureCell"];
    

    NSString *pictureURL = [kBaseURLForImages stringByAppendingString:[[self.pictureList objectAtIndex:indexPath.row] objectForKey:@"image"]];
    
    
    // Start the fetch on a diffrenet queue from the main
    
    __weak UITableViewController *weakSelf = self;

    dispatch_async(kBackGroundQueue, ^{
         NSLog(@"%@ start to fetxh", pictureURL);
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:pictureURL]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            cell.imageView.image = [UIImage imageWithData: data];
            NSLog(@"%@ fetched", pictureURL);
            [weakSelf.tableView reloadData];
        });

    });
    
    cell.textLabel.text = [[self.pictureList objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[self.pictureList objectAtIndex:indexPath.row] objectForKey:@"description"];

    
    return cell;
}


#pragma mark - Helpers

-(void)fetchedRowData:(NSData *)dataInResponse {
    
    NSError *error;
    // Get the JSON data serialized
    NSArray *downloadedJSONData = [NSJSONSerialization JSONObjectWithData:dataInResponse
                                                                       options:0
                                                                         error:&error];
    self.pictureList = downloadedJSONData;
    NSLog(@"%@", self.pictureList);
     [self.tableView reloadData]; 
    
}

-(void)fetchedPictureData:(NSData *)dataInResponse {
    
    NSError *error;
    // Get the JSON data serialized
    NSArray *downloadedJSONData = [NSJSONSerialization JSONObjectWithData:dataInResponse
                                                                  options:0
                                                                    error:&error];
    self.pictureList = downloadedJSONData;
    NSLog(@"%@", self.pictureList);
    [self.tableView reloadData];
    
}


@end
