//
//  Car+CoreDataProperties.m
//  Sprint03
//
//  Created by iLya Tkachev on 4/19/17.
//  Copyright © 2017 iLya Tkachev. All rights reserved.
//

#import "Car+CoreDataProperties.h"

@implementation Car (CoreDataProperties)

+ (NSFetchRequest<Car *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Car"];
}

@dynamic mark;
@dynamic model;
@dynamic logoImage;
@dynamic carID;

@end
