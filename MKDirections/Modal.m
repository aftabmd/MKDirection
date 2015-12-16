//
//  Modal.m
//  MKDirections
//
//  Created by Neeraj Mishra on 8/5/15.
//  Copyright (c) 2015 Neeraj Mishra. All rights reserved.
//

#import "Modal.h"

@implementation Modal

+(Modal *)instanceofclass:(NSDictionary *)dict
{
    Modal *obj = [[Modal alloc]init];
    obj.lat = [[[dict valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lat"];
    obj.lang =[[[dict valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lng"];
    obj.name = [NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
    return obj;
}

@end
