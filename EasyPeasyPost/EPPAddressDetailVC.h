//
//  EPPAddressDetailVC
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPPAddress.h"

@interface EPPAddressDetailVC : UITableViewController

// Setting this property before this VC is loaded will load the fields
// with the address data. After fields have been saved/updated, this VC
// initiates an unwind segue that gives the receiver the chance to grab
// the updated address through this property.
@property (nonatomic, strong) EPPAddress *address;

@end
