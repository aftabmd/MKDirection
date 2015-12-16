//
//  Modal.h
//  MKDirections
//
//  Created by Neeraj Mishra on 8/5/15.
//  Copyright (c) 2015 Neeraj Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Modal : NSObject

@property (nonatomic,strong)NSString *lat;
@property (nonatomic,strong)NSString *lang;
@property (nonatomic,strong)NSString *name;

+(Modal *)instanceofclass:(NSDictionary*) dict;

@end
