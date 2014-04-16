//
//  BeeNotificationsViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 04/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeNotificationsViewController.h"
#import "BeeNotificationTableViewCell.h"
#import "SettingsViewController.h"
#import "BeeUser.h"
#import "Notification.h"

@interface BeeNotificationsViewController () <UITableViewDataSource, UITableViewDelegate, SettingsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) NSDate *lastUpdateDate;
@end

@implementation BeeNotificationsViewController

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
    self.notifications = [NSArray array];
    [self refreshNotifications];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Settings Segue"]) {
        SettingsViewController *svc = (SettingsViewController *)[segue destinationViewController];
        svc.delegate = self;
    }
}

- (void)refreshNotifications {
    [[BeeAPIClient sharedClient]GETLastNotificationsSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableNotifications = [[NSMutableArray alloc]init];
        int i = 0;
        NSMutableArray *secretIDs = [NSMutableArray array];
        for (NSDictionary *notifications in (NSArray *)responseObject) {
            Notification *notif = [[Notification alloc]initWithDictionary:notifications];
            if (![secretIDs containsObject:notif.secretID]) {
                mutableNotifications[i] = notif;
                secretIDs[i] = notif.secretID;
            } else {
                NSInteger index = [secretIDs indexOfObject:notif.secretID];
                if (notif.isComment) {
                    ((Notification *)[mutableNotifications objectAtIndex:index]).isComment = YES;
                } else if (notif.isLike) {
                    ((Notification *)[mutableNotifications objectAtIndex:index]).isLike = YES;
                }
            }
            i++;
        }
        self.notifications = [mutableNotifications arrayByAddingObjectsFromArray:self.notifications];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (IBAction)signOut:(UIButton *)sender {
    [[BeeUser sharedUser] userSignOut];
}

- (IBAction)loginWithFacebook:(id)sender {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:[BeeUser basicPermissions]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [[BeeUser sharedUser]facebookSessionStateChanged:session state:state error:error];
         }];
    }
}

#pragma mark - SettingsViewController delegate

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Table View data source

- (NSString *)cellIdentifier {
    static NSString *CellIdentifier = @"BeeNotificationTableViewCell";
    return CellIdentifier;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BeeNotificationTableViewCell *cell = (BeeNotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}

#pragma mark - Table View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Secret Show Segue" sender:self.notifications[indexPath.row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
