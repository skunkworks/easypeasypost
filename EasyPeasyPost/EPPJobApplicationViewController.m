//
//  EPPJobApplicationViewController.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 12/4/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPJobApplicationViewController.h"
#import "EPPJobApplication.h"

@interface EPPJobApplicationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *jobTitleField;
@property (weak, nonatomic) IBOutlet UITextView *buildTextView;

@end

@implementation EPPJobApplicationViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)sendApplication:(id)sender
{
    NSString *jobTitle = self.jobTitleField.text;
    NSString *build = self.buildTextView.text;

    EPPJobApplication *application = [[EPPJobApplication alloc] initWithJobTitle:jobTitle
                                                                           build:build];
    [application sendOnCompletion:^(NSString *errorMessage) {
        if (errorMessage) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sent job application"
                                                                message:@"Good luck!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


@end
