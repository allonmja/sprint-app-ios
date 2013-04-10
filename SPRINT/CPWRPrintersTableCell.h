//
//  CPWRPrintersTableCell.h
//  Sprint
//
//  Created by Vincent Sam on 4/1/13.
//  Copyright (c) 2013 Compuware. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CPWRPrintersTableCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *printerImageView;

@property (weak, nonatomic) IBOutlet UILabel *printerNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *printerLocationLabel;

@end
