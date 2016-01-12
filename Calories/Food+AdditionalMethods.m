//
//  Food+AdditionalMethods.m
//  Calories
//
//  Created by Bill Gestrich on 4/6/15.
//  Copyright (c) 2015 Bill Gestrich. All rights reserved.
//

#import "Food+AdditionalMethods.h"

@implementation Food (AdditionalMethods)

-(NSString *)presentableDate{
    static NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    return [formatter stringFromDate:self.created];
}

@end
