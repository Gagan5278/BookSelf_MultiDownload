//
//  TableCell.m
//  BOOKSelf
//
//  Created by Gagan on 17/06/14.
//  Copyright (c) 2014 Gagan. All rights reserved.
//

#import "TableCell.h"

@interface TableCell ()

@end

@implementation TableCell
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self)
    {
        self.backgroundView.backgroundColor=[UIColor colorWithPatternImage: [UIImage imageNamed:@"list-item.png"]];
        self.backgroundView.userInteractionEnabled=YES;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundView.frame=CGRectMake(0, 194, 320, 58);
}


@end
