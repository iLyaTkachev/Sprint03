//
//  MyTableViewCell.h
//  Sprint03
//
//  Created by iLya Tkachev on 4/15/17.
//  Copyright © 2017 iLya Tkachev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UILabel *myTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mySubtitleLabel;

@end
