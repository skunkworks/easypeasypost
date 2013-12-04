//
//  EPPAddressDetailVC
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAddressDetailVC.h"

@interface EPPAddressDetailVC () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *companyField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *street1Field;
@property (weak, nonatomic) IBOutlet UITextField *street2Field;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (weak, nonatomic) IBOutlet UITextField *idField;
@property (weak, nonatomic) IBOutlet UITextField *createdAtField;
@property (weak, nonatomic) IBOutlet UITextField *updatedAtField;

@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) EPPAddress *verifiedAddress;

@end

@implementation EPPAddressDetailVC

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
    
    if (self.address) {
        [self updateFieldsWithAddress:self.address];
    } else {
        self.address = [[EPPAddress alloc] init];
    }
    
    self.fields = @[self.nameField, self.companyField, self.phoneField, self.emailField,
                    self.street1Field, self.street2Field, self.cityField, self.stateField,
                    self.zipField, self.countryField];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Have the return key move to the next field. When there are no more fields, dismiss keyboard.
    int nextIndex = [self.fields indexOfObject:textField]+1;
    if ([self.fields count] > nextIndex) {
        [self.fields[nextIndex] becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Disallow editing of the readonly fields
    if (textField == self.idField ||
        textField == self.createdAtField ||
        textField == self.updatedAtField) {
        return NO;
    }
    return YES;
}

- (void)updateFieldsWithAddress:(EPPAddress *)address
{
    self.idField.text = address.id;
    self.nameField.text = address.name;
    self.companyField.text = address.company;
    self.emailField.text = address.email;
    self.phoneField.text = address.phone;
    self.street1Field.text = address.street1;
    self.street2Field.text = address.street2;
    self.cityField.text = address.city;
    self.stateField.text = address.state;
    self.zipField.text = address.zip;
    self.countryField.text = address.country;
    
    self.createdAtField.text = [NSDateFormatter localizedStringFromDate:address.createdAt
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterShortStyle];
    self.updatedAtField.text = [NSDateFormatter localizedStringFromDate:address.updatedAt
                                                              dateStyle:NSDateFormatterMediumStyle
                                                              timeStyle:NSDateFormatterShortStyle];

}

- (void)updateAddressWithFields:(EPPAddress *)address
{
    self.address.name = self.nameField.text;
    self.address.company = self.companyField.text;
    self.address.email = self.emailField.text;
    self.address.phone = self.phoneField.text;
    self.address.street1 = self.street1Field.text;
    self.address.street2 = self.street2Field.text;
    self.address.city = self.cityField.text;
    self.address.state = self.stateField.text;
    self.address.zip = self.zipField.text;
    self.address.country = self.countryField.text;
}

- (IBAction)save:(id)sender
{
    [self updateAddressWithFields:self.address];
    
    [self.address saveOnCompletion:^(NSString *errorMessage) {
        if (errorMessage) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to save address"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            // Don't have to update address -- saveOnCompletion: modifies the object directly
            [self performSegueWithIdentifier:@"Save new address" sender:self.address];
        }
    }];
}

- (IBAction)update:(id)sender
{
    [self updateAddressWithFields:self.address];
    
    [self.address saveOnCompletion:^(NSString *errorMessage) {
        if (errorMessage) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to update address"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            // Perform unwind segue
            [self performSegueWithIdentifier:@"Update existing address" sender:self.address];
        }
    }];
}

- (IBAction)verify:(id)sender
{
    [self updateAddressWithFields:self.address];
    
    [self.address verifyOnCompletion:^(EPPAddress *address, NSString *errorMessage) {
        UIAlertView *alertView;
        if (address) {
            if (errorMessage) {
                alertView = [[UIAlertView alloc] initWithTitle:@"Error verifying address"
                                                       message:errorMessage
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
            } else {
                self.verifiedAddress = address;
                alertView = [[UIAlertView alloc] initWithTitle:@"Overwrite address fields with verified address?"
                                                       message:[address description]
                                                      delegate:self
                                             cancelButtonTitle:@"No"
                                             otherButtonTitles:@"Yes", nil];
            }
        }
        else {
            alertView = [[UIAlertView alloc] initWithTitle:@"Error verifying address"
                                                   message:errorMessage
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
        }
        [alertView show];
    }];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        self.address = self.verifiedAddress;
        [self updateFieldsWithAddress:self.verifiedAddress];
    }
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
