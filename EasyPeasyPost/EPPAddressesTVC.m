//
//  EPPAddressesTVC.m
//  EasyPeasyPost
//
//  Created by Richard Shin on 11/26/13.
//  Copyright (c) 2013 Richard Shin. All rights reserved.
//

#import "EPPAddressesTVC.h"
#import "EPPAddressDetailVC.h"

@interface EPPAddressesTVC ()

@property (nonatomic, strong) NSMutableArray *addresses;
// Keeps track of the address object being edited
@property (nonatomic, strong) EPPAddress *address;

@end

@implementation EPPAddressesTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.addresses = [NSMutableArray array];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Address Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    EPPAddress *address = self.addresses[indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@ - %@", address.name ? address.name : address.company, address.id];
    NSString *subtitle = [address description];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Edit address"]) {
        EPPAddressDetailVC *vc = (EPPAddressDetailVC *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.address = self.addresses[indexPath.row];
        vc.address = self.address;
    }
}

- (IBAction)saveNewAddress:(UIStoryboardSegue *)sender
{
    EPPAddressDetailVC *vc = (EPPAddressDetailVC *)sender.sourceViewController;
    EPPAddress *address = vc.address;
    [self.addresses addObject:address];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.addresses count]-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)updateAddress:(UIStoryboardSegue *)sender
{
    EPPAddress *oldAddress = self.address;
    NSUInteger idx = [self.addresses indexOfObject:oldAddress];
    EPPAddressDetailVC *vc = (EPPAddressDetailVC *)sender.sourceViewController;
    EPPAddress *newAddress = vc.address;
    
    [self.addresses replaceObjectAtIndex:idx withObject:newAddress];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx
                                                 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}
 

@end
