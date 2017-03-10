//
//  AdressModel.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/3/9.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import "AdressModel.h"

@implementation AdressModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.adcode forKey:@"adcode"];
    [aCoder encodeObject:self.district forKey:@"district"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.adcode = [aDecoder decodeObjectForKey:@"adcode"];
        self.district = [aDecoder decodeObjectForKey:@"district"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.latitude = [[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
        self.longitude = [[aDecoder decodeObjectForKey:@"longitude"] doubleValue];
    }
    return self;
}

@end
