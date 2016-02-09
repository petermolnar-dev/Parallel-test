//
//  PMOPicture.m
//  Parallels_test
//
//  Created by Peter Molnar on 09/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import "PMOPicture.h"

@implementation PMOPicture
+ (instancetype)PictureFromDictionary:(NSDictionary *)pictureDetails {
    PMOPicture *picture = [[PMOPicture alloc] init];
    
    [picture setImageDescription:[pictureDetails objectForKey:@"description"]];
    [picture setImageFileName:[pictureDetails objectForKey:@"image"]];
    [picture setImageTitle:[pictureDetails objectForKey:@"name"]];
    
    return picture;
}
@end
