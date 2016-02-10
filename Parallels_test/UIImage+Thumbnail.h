//
//  UIImage+Thumbnail.h
//  Parallels_test
//
//  Created by Peter Molnar on 10/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)
- (UIImage *) makeThumbnailWithSize:(CGSize)size;
@end
