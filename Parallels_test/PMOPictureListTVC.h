//
//  PMOPictureListTVC.h
//  Parallels_test
//
//  Created by Peter Molnar on 08/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#define kBackGroundQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kDataURL [NSURL URLWithString:@"http://93.175.29.76/web/wwdc/items.json"]


#import <UIKit/UIKit.h>

@interface PMOPictureListTVC : UITableViewController

@end
