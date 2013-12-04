//
//  EPPAPIKeyViewController.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAPIKeyViewController.h"
#import "EPPAPIKeyCheck.h"
#import "EPPSettings.h"

@interface EPPAPIKeyViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *apiKeyField;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) EPPSettings *settings;

@end

@implementation EPPAPIKeyViewController

- (EPPSettings *)settings {
    if (!_settings) _settings = [[EPPSettings alloc] init];
    return _settings;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.apiKeyField.text = [self.settings apiKey];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.settings setApiKey:self.apiKeyField.text];
}

- (IBAction)verify:(UIButton *)sender {
    NSString *apiKey = self.apiKeyField.text;
    [self.settings setApiKey:self.apiKeyField.text];
    
    [self deactivateUI];
    [self checkAPIKey:apiKey];
}

- (void)checkAPIKey:(NSString *)apiKey
{
    [EPPAPIKeyCheck checkAPIKey:apiKey onCompletion:^(BOOL verified, NSString *errorMessage)
    {
        if (verified) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"API key verified!"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to verify API key"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        [self activateUI];
    }];
}

- (void)activateUI
{
    self.apiKeyField.enabled = YES;
    self.verifyButton.enabled = YES;
    [self.verifyButton setTitle:@"Verify"
                       forState:UIControlStateNormal];
    [self.activityIndicator stopAnimating];
}

- (void)deactivateUI
{
    self.apiKeyField.enabled = NO;
    self.verifyButton.enabled = NO;
    [self.activityIndicator startAnimating];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField selectAll:self];
}

#pragma mark - Stuff to make the keyboard go away!

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.apiKeyField resignFirstResponder];
    [super touchesBegan:touches withEvent:event];
}
@end
