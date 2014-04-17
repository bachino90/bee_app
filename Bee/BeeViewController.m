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

#import "BeeNotificationView.h"
#import "BeeTableViewCell.h"
#import "BeeLastTableViewCell.h"
#import "JZRefreshControl.h"
#import "BeeRefreshControl.h"

@interface BeeViewController () <UITableViewDataSource, UITableViewDelegate, BeeAddSecretViewControllerDelegate, BeeSecretViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BeeNotificationView *notificationView;
@property (strong, nonatomic) NSArray *secrets;
@property (strong, nonatomic) BeeRefreshControl *refreshControl;

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
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
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
    
    [self registerForNotifications];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    self.leftButton.tag = 1;
    self.refreshControl = [[BeeRefreshControl alloc]initWithFrame:CGRectMake(0.0, self.tableView.frame.origin.y, self.tableView.frame.size.width, [BeeRefreshControl height])];
    self.refreshControl.tableView = self.tableView;
    __weak BeeViewController *weakSelf = self;

    self.isLoadingOldSecrets = YES;
    self.loadedAllSecrets = NO;
    
    self.refreshControl.refreshBlock = ^{
        weakSelf.isLoadingNewSecrets = YES;
        [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
            int i = 0;
            for (NSDictionary *secret in (NSArray *)responseObject) {
                mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
                i++;
            }
            
            [BeeAPIClient sharedClient].secretRecentUpdate = ((Secret *)mutableSecrets.firstObject).createdAt;
            if ([BeeAPIClient sharedClient].secretLastUpdate == nil) {
                [BeeAPIClient sharedClient].secretLastUpdate = ((Secret *)mutableSecrets.lastObject).createdAt;
            }
            if (mutableSecrets.count > 0) {
                if (weakSelf.secrets.count > 0 && [((Secret *)mutableSecrets.lastObject).secretID isEqualToString:((Secret *)weakSelf.secrets.firstObject).secretID]) {
                    [mutableSecrets removeLastObject];
                }
                weakSelf.secrets = [mutableSecrets arrayByAddingObjectsFromArray:weakSelf.secrets];
                [weakSelf.tableView reloadData];
            }
            [weakSelf.refreshControl endRefreshing];
            weakSelf.isLoadingNewSecrets = NO;
            weakSelf.isLoadingOldSecrets = NO;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        }];
    };
    [self.refreshControl beginRefreshing];
    
    CGFloat tableViewHeight = SCREEN_HEIGHT - self.tableView.frame.origin.y;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, tableViewHeight);
    
    //[self followScrollView:self.tableView];
    //UIRefreshControl *rc = [[UIRefreshControl alloc]init];
    //rc.attributedTitle = [[NSAttributedString alloc]initWithString:@"Loading..."];
    //[self.tableView addSubview:rc];
    
    //[self refreshSecrets];
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

- (void)refreshSecrets {
    self.isLoadingNewSecrets = YES;
    [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        
        [BeeAPIClient sharedClient].secretRecentUpdate = ((Secret *)mutableSecrets.firstObject).createdAt;
        [BeeAPIClient sharedClient].secretLastUpdate = ((Secret *)mutableSecrets.lastObject).createdAt;
        
        self.secrets = [mutableSecrets arrayByAddingObjectsFromArray:self.secrets];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        self.isLoadingNewSecrets = NO;
        self.isLoadingOldSecrets = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
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
            //[self.commentView setEnablePost:NO];
            self.notificationView.notificationText = @"Error de conexion";
            [self.view addSubview:self.notificationView];
            break;
        default:
            //[self.commentView setEnablePost:YES];
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

- (void)loadNewSecrets {
    [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        
        [BeeAPIClient sharedClient].secretRecentUpdate = ((Secret *)mutableSecrets.firstObject).createdAt;
        if ([BeeAPIClient sharedClient].secretLastUpdate == nil) {
            [BeeAPIClient sharedClient].secretLastUpdate = ((Secret *)mutableSecrets.lastObject).createdAt;
        }
        if (mutableSecrets.count > 0) {
            self.secrets = [mutableSecrets arrayByAddingObjectsFromArray:self.secrets];
        }
        [self.tableView reloadData];
        self.isLoadingNewSecrets = NO;
        self.isLoadingOldSecrets = NO;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)loadOldSecrets {
    if (self.isLoadingOldSecrets || self.isLoadingNewSecrets || self.loadedAllSecrets) {
        return;
    }
    self.isLoadingOldSecrets = YES;
    [[BeeAPIClient sharedClient] GETPastSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        NSLog(@"%@", (NSArray *)responseObject);
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        
        [BeeAPIClient sharedClient].secretLastUpdate = ((Secret *)mutableSecrets.lastObject).createdAt;
        
        self.secrets = [self.secrets arrayByAddingObjectsFromArray:mutableSecrets];//[mutableSecrets copy];
        [self.tableView reloadData];
        self.isLoadingOldSecrets = NO;
        if (mutableSecrets.count == 0) {
            self.loadedAllSecrets = YES;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.isLoadingOldSecrets = NO;
    }];
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
        [self.tableView reloadData];
    }];
}

- (void)publishSecret:(NSDictionary *)secret {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View data source

- (NSString *)cellIdentifier {
    static NSString *CellIdentifier = @"BeeTableViewCell";
    return CellIdentifier;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.secrets.count > 0)
        return self.secrets.count + 1;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.secrets.count) {
        BeeLastTableViewCell *cell = (BeeLastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BeeLastTableViewCell" forIndexPath:indexPath];
        if (self.loadedAllSecrets) {
            [cell.activityIndicatorView stopAnimating];
        } else {
            [cell.activityIndicatorView startAnimating];
        }
        return cell;
    } else {
        BeeTableViewCell *cell = (BeeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
        Secret *secret = self.secrets[indexPath.row];
        cell.secret = secret;
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        return cell;
    }
}


#pragma mark - Table View delegate

- (void)adjustSizingCellWidthToTableWidth {
    sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
}

/*
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
    if (indexPath.row == self.secrets.count) {
        return 75.0;
    }
    return SECRET_WIDTH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Secret Show Segue" sender:self.secrets[indexPath.row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}
 
@end
