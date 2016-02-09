//
//  PMOPicture.h
//  Parallels_test
//
//  Created by Peter Molnar on 09/02/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMOPicture : NSObject
+ (instancetype)PictureFromDictionary:(NSDictionary *)pictureDetails;
@end
