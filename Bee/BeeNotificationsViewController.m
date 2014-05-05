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

#import "CoreDataController.h"
#import "BeeSyncEngine.h"

#import "BeeUser.h"
#import "Notification.h"

@interface BeeNotificationsViewController () <UITableViewDataSource, UITableViewDelegate, SettingsViewControllerDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)  NSFetchedResultsController *fetchedResultsController;
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
    [self loadNewNotifications];
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

- (void)loadNewNotifications {
    [[BeeSyncEngine sharedEngine]startSearchingRecentNotifications];
    /*
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
    */
}

- (void)loadOldNotifications {
    
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

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self.refreshControl scrollViewDidScroll:scrollView];
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 100.0) {
        //[self loadOldSecrets];
    }
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *moc = [[CoreDataController sharedInstance]masterManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"updated_at" ascending:NO];
    [fetchRequest setSortDescriptors:@[descriptor]];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Notification"];
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

#pragma mark - Table View data source

- (NSString *)cellIdentifier {
    static NSString *CellIdentifier = @"BeeNotificationTableViewCell";
    return CellIdentifier;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    if ([sectionInfo numberOfObjects] > 0) {
        NSLog(@"%i",[sectionInfo numberOfObjects]);
        return [sectionInfo numberOfObjects];
    }
    else return 0;
}

- (void)configureCell:(BeeNotificationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //BeeNotificationTableViewCell *newCell = (BeeNotificationTableViewCell *)cell;
    Notification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.notification = notification;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BeeNotificationTableViewCell *cell = (BeeNotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Secret Show Segue" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SECRET_WIDTH/2.0;
}

#pragma mark - NSFetchedResultsController Delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(BeeNotificationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}



@end
