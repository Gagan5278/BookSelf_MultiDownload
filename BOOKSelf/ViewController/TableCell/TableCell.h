//
//  TableCell.h
//  BOOKSelf
//
//  Created by Gagan on 17/06/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgressBar;
@property (strong, nonatomic) IBOutlet UIButton *StartPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@end
