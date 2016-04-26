//
//  PMOPictureListTVC.h
//  Parallels_test
//
//  Created by Peter Molnar on 08/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#define kBackGroundNormalPriorityQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kDataBaseURL @"http://93.175.29.76/web/wwdc/"
#define kDataURL [NSURL URLWithString:[kDataBaseURL stringByAppendingString:@"items.json"]]


#import <UIKit/UIKit.h>

@interface PMOPictureListTVC : UITableViewController

@end
