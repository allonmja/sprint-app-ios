//
//  CPWRButtonStyles.m
//  Sprint
//
//  Created by Vincent Sam on 4/4/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import "CPWRButtonStyles.h"

@implementation CPWRButtonStyles

/*
 Function Purpose: Beautiful custom buttons for the LesMasions app
 Paramaters: Button to desgin
 Return type: void
 Notes: Create custom button design for the application. Change images to suite your taste
 */
- (void)designButton:(UIButton *)button
{
    UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [button setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [button setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
}

@end
