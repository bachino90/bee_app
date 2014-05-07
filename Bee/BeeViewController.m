//
//  BeeViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeViewController.h"
#import "Reachability.h"
#import "BeeAddSecretViewController.h"
#import "BeeSecretViewController.h"
#import "BeeNavigationController.h"

#import "BeeUser.h"
#import "BeeSyncEngine.h"
#import "CoreDataController.h"

#import "BeeNotificationView.h"
#import "BeeTableViewCell.h"
#import "BeeLastTableViewCell.h"
#import "JZRefreshControl.h"
#import "BeeRefreshControl.h"
#import "BeeFooterView.h"

@interface BeeViewController () <UITableViewDataSource, UITableViewDelegate, BeeAddSecretViewControllerDelegate, BeeSecretViewControllerDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BeeNotificationView *notificationView;
@property (strong, nonatomic) NSArray *secrets;
@property (strong, nonatomic) BeeRefreshControl *refreshControl;
@property (strong, nonatomic) BeeFooterView *footerView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic) BOOL isLoadingOldSecrets;
@property (nonatomic) BOOL isLoadingNewSecrets;
@property (nonatomic) BOOL loadedAllSecrets;
@end

@implementation BeeViewController {
    dispatch_once_t onceToken;
    NSMutableDictionary *rowHeightCache;
    BeeTableViewCell *sizingCell;
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BeeSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.isLoadingNewSecrets = NO;
        self.isLoadingOldSecrets = NO;
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:0];
        if (self.tableView.tableFooterView == nil && [sectionInfo numberOfObjects] > 0) {
            self.tableView.tableFooterView = self.footerView;
        }
        if (self.loadedAllSecrets) {
            [self.footerView stop];
        } else {
            [self.footerView start];
        }
        [self.refreshControl endRefreshing];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BeeSyncEngineSyncFailed" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.refreshControl endRefreshing];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BeeSyncEngineSyncAllSecretsCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.loadedAllSecrets = YES;
    }];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BeeSyncEngineSyncCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BeeSyncEngineSyncFailed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BeeSyncEngineSyncAllSecretsCompleted" object:nil];
}

- (void)dealloc {
    [self unregisterForNotifications];
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    CGRect frame = CGRectMake(0, 0, 200, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont beeFontWithSize:27.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.text = @"BeeApp";
    // emboss in the same way as the native title
    //[label setShadowColor:[UIColor darkGrayColor]];
    //[label setShadowOffset:CGSizeMake(0, -0.5)];
    self.navigationItem.titleView = label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    rowHeightCache = [NSMutableDictionary dictionary];
    
    // REACHABILITY
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    // SLIDE OUT
    self.leftButton.tag = 1;
    
    // REFRESH CONTROL
    self.refreshControl = [[BeeRefreshControl alloc]initWithFrame:CGRectMake(0.0, self.tableView.frame.origin.y, self.tableView.frame.size.width, [BeeRefreshControl height])];
    self.refreshControl.tableView = self.tableView;
    __weak BeeViewController *weakSelf = self;

    self.isLoadingOldSecrets = YES;
    self.loadedAllSecrets = NO;
    
    self.refreshControl.refreshBlock = ^{
        [weakSelf loadNewSecrets];
    };
    if ([[BeeUser sharedUser] isLoggedin]) {
        [self.refreshControl beginRefreshing];
    }
    
    // TABLE VIEW
    CGFloat tableViewHeight = SCREEN_HEIGHT - self.tableView.frame.origin.y;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, tableViewHeight);
    
    // FOOTER
    self.footerView = [[BeeFooterView alloc]init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self unregisterForNotifications];
}

- (BeeNotificationView *)notificationView {
    if (_notificationView) {
        return _notificationView;
    }
    _notificationView = [[BeeNotificationView alloc]initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height + 20.0, self.view.frame.size.width, 30.0)];
    return _notificationView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)movePanel:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 0: {
            [((BeeNavigationController *)self.navigationController).navDelegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [((BeeNavigationController *)self.navigationController).navDelegate movePanelRight];
            break;
        }
            
        default:
            break;
    }
}

- (void)updateInterfaceWithReachability:(Reachability *)reach {
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    //BOOL connectionRequired = [reach connectionRequired];
    switch (netStatus) {
        case NotReachable:
            self.notificationView.notificationText = @"Error de conexion";
            [self.view addSubview:self.notificationView];
            break;
        default:
            [self.notificationView removeFromSuperview];
            break;
    }
}

#pragma mark - Reachability Notifications

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *reach = note.object;
    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:reach];
}

#pragma mark - Refresh Secrets

- (void)refreshSecrets {
    [self.refreshControl beginRefreshing];
}

- (void)loadNewSecrets {
    self.isLoadingNewSecrets = YES;
    [[BeeSyncEngine sharedEngine]startRecentSync];
    /*
    [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        
        [BeeAPIClient sharedClient].secretRecentUpdate = ((Secret *)mutableSecrets.firstObject).created_at;
        if ([BeeAPIClient sharedClient].secretLastUpdate == nil) {
            [BeeAPIClient sharedClient].secretLastUpdate = ((Secret *)mutableSecrets.lastObject).created_at;
        }
        if (mutableSecrets.count > 0) {
            self.secrets = [mutableSecrets arrayByAddingObjectsFromArray:self.secrets];
        }
        [self.tableView reloadData];
        self.isLoadingNewSecrets = NO;
        self.isLoadingOldSecrets = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
     */
}

- (void)loadOldSecrets {
    if (self.isLoadingOldSecrets || self.isLoadingNewSecrets || self.loadedAllSecrets) {
        return;
    }
    self.isLoadingOldSecrets = YES;
    [[BeeSyncEngine sharedEngine]startOldSync];
    /*
    [[BeeAPIClient sharedClient] GETPastSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        NSLog(@"%@", (NSArray *)responseObject);
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        
        [BeeAPIClient sharedClient].secretLastUpdate = ((Secret *)mutableSecrets.lastObject).created_at;
        
        self.secrets = [self.secrets arrayByAddingObjectsFromArray:mutableSecrets];//[mutableSecrets copy];
        [self.tableView reloadData];
        self.isLoadingOldSecrets = NO;
        if (mutableSecrets.count == 0) {
            self.loadedAllSecrets = YES;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.isLoadingOldSecrets = NO;
    }];
     */
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshControl scrollViewDidScroll:scrollView];
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 100.0) {
        [self loadOldSecrets];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.refreshControl scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

#pragma mark - Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Add Secret Segue"]) {
        BeeAddSecretViewController *avc = (BeeAddSecretViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        avc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"Secret Show Segue"]) {
        BeeSecretViewController *bvc = (BeeSecretViewController *)[segue destinationViewController];
        bvc.secret = (Secret *)sender;
        bvc.delegate = self;
    }
}

#pragma mark - Bee Secret View Controller Delegate

- (void)dismissBeeSecretViewController:(BeeSecretViewController *)vc {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Bee Add Secret View Controller Delegate

- (void)cancelPublication {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)publishSecret:(NSDictionary *)secret {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.refreshControl beginRefreshing];
    }];
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *moc = [[CoreDataController sharedInstance]masterManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Secret"];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"created_at" ascending:NO];
    [fetchRequest setSortDescriptors:@[descriptor]];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:@"Secrets"];
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
    static NSString *CellIdentifier = @"BeeTableViewCell";
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

- (void)configureCell:(BeeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BeeTableViewCell *newCell = (BeeTableViewCell *)cell;
    Secret *secret = [self.fetchedResultsController objectAtIndexPath:indexPath];//self.secrets[indexPath.row];
    newCell.secret = secret;
    [newCell setNeedsLayout];
    [newCell layoutIfNeeded];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BeeTableViewCell *cell = (BeeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark - Table View delegate

/*
- (void)adjustSizingCellWidthToTableWidth {
    sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.secrets.count) {
        return 75.0;
    }
    
    dispatch_once(&onceToken, ^{
        sizingCell = (BeeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
        [self adjustSizingCellWidthToTableWidth];
    });
    
    NSString *index = [NSString stringWithFormat:@"%i",indexPath.row];
    
    if (rowHeightCache[index] == nil) {
        sizingCell.secret = self.secrets[indexPath.row];
        CGFloat rowHeight = sizingCell.requiredCellHeight;
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        rowHeightCache[index] = @(rowHeight);
    }
    
    return [rowHeightCache[index] floatValue];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SECRET_WIDTH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Secret Show Segue" sender:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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
            [self configureCell:(BeeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
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
