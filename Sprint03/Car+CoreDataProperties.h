//
//  Car+CoreDataProperties.h
//  Sprint03
//
//  Created by iLya Tkachev on 4/19/17.
//  Copyright © 2017 iLya Tkachev. All rights reserved.
//

#import "Car+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Car (CoreDataProperties)

+ (NSFetchRequest<Car *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *mark;
@property (nullable, nonatomic, copy) NSString *model;
@property (nullable, nonatomic, copy) NSString *logoImage;
@property (nullable, nonatomic, copy) NSString *carID;

@end

NS_ASSUME_NONNULL_END
