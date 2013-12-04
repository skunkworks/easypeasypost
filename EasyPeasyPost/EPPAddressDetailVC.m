//
//  EPPAddressDetailVC
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAddressDetailVC.h"

@interface EPPAddressDetailVC () <UITextFieldDelegate>

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

@property (nonatomic, strong) NSArray *fields;

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
    
    EPPAddress *address = self.address;
    if (address) {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int nextIndex = [self.fields indexOfObject:textField]+1;
    if ([self.fields count] > nextIndex) {
        [self.fields[nextIndex] becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)save:(UIBarButtonItem *)sender
{
    // We use this VC for both new and existing addresses, which is why we do this check
    if (!self.address) {
        self.address = [[EPPAddress alloc] init];
    }
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
    
    [self.address saveOnCompletion:^(EPPAddress *address, NSString *errorMessage) {
        if (errorMessage) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to save address"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            // Save updated address (now has ID and datetimes)
            self.address = address;
            
            // Perform segue
            [self performSegueWithIdentifier:@"Save new address" sender:self.address];
        }
    }];
}

- (IBAction)verify:(UIBarButtonItem *)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setAddress:)]) {
        [segue.destinationViewController performSelector:@selector(setAddress:) withObject:self.address];
    }
}


@end
