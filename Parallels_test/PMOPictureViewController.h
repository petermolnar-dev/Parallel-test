//
//  PMOPictureViewController.h
//  Parallels_test
//
//  Created by Peter Molnar on 09/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//
#define kBackGroundHighPriorityQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
#define kBackGroundNormalPriorityQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)



#import <UIKit/UIKit.h>
#include "PMOPicture.h"

@interface PMOPictureViewController : UIViewController

@property (nonatomic, strong) PMOPicture *picture;
@property (nonatomic, strong) NSURL *imageURL;
@end
