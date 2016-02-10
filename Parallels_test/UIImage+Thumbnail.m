//
//  UIImage+Thumbnail.m
//  Parallels_test
//
//  Created by Peter Molnar on 10/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)
- (UIImage *) makeThumbnailWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}

@end
