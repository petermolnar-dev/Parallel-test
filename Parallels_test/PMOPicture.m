//
//  PMOPicture.m
//  Parallels_test
//
//  Created by Peter Molnar on 09/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import "PMOPicture.h"

@implementation PMOPicture

+ (instancetype)PictureFromDictionary:(NSDictionary *)pictureDetails baseURLAsStringForImage:(NSString *)baseURLAsString {
    PMOPicture *picture = [[PMOPicture alloc] init];
    
    [picture setImageDescription:[pictureDetails objectForKey:@"description"]];
    [picture setImageFileName:[pictureDetails objectForKey:@"image"]];
    [picture setImageTitle:[pictureDetails objectForKey:@"name"]];
    // Check if the URL ends with slash (/) character.
    if (![[baseURLAsString substringFromIndex:[baseURLAsString length]-1] isEqual:@"/"]) {
        baseURLAsString= [baseURLAsString stringByAppendingString:@"/"];
    }
    [picture setImageURL:[NSURL URLWithString:[baseURLAsString stringByAppendingString:picture.imageFileName]]];
    
    return picture;
}

@end
