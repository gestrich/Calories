//
//  Food.h
//  Calories
//
//  Created by Bill Gestrich on 12/28/14.
//  Copyright (c) 2014 Bill Gestrich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Food : NSManagedObject

@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;

@end
