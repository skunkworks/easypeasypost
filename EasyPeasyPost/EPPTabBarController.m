//
//  EPPTabBarController.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPTabBarController.h"
#import "EPPAPIKeyViewController.h"

@interface EPPTabBarController ()

@end

@implementation EPPTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self verifyAPIKey];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@", segue);
}

- (void)verifyAPIKey
{
    [self.tabBarController performSegueWithIdentifier:@"Set Up API Key" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
