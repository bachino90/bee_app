//
//  BeeTableViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 18/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeTableViewController.h"
#import "BeeAddSecretViewController.h"
#import "BeeSecretViewController.h"
#import "BeeNavigationController.h"

#import "BeeTableViewCell.h"
#import "BeeRefreshControl.h"

@interface BeeTableViewController () <UITableViewDataSource, UITableViewDelegate, BeeAddSecretViewControllerDelegate, BeeSecretViewControllerDelegate>
@property (strong, nonatomic) NSArray *secrets;
@property (strong, nonatomic) BeeRefreshControl *refreshControl;

@property (nonatomic) BOOL isLoadingOldSecrets;
@property (nonatomic) BOOL isLoadingNewSecrets;
@property (nonatomic) BOOL loadedAllSecrets;


@end

@implementation BeeTableViewController {
    dispatch_once_t onceToken;
    NSMutableDictionary *rowHeightCache;
    BeeTableViewCell *sizingCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    rowHeightCache = [NSMutableDictionary dictionary];
    
    self.leftButton.tag = 1;
    self.refreshControl = [[BeeRefreshControl alloc]initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, [BeeRefreshControl height])];
    self.refreshControl.tableView = self.tableView;
    __weak BeeTableViewController *weakSelf = self;
    
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
     weakSelf.secrets = [mutableSecrets copy];
     [weakSelf.tableView reloadData];
     [weakSelf.refreshControl endRefreshing];
     weakSelf.isLoadingNewSecrets = NO;
     weakSelf.isLoadingOldSecrets = NO;
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
     
     }];
     };
     [self.refreshControl beginRefreshing];
     
    
    //[self followScrollView:self.tableView];
    //UIRefreshControl *rc = [[UIRefreshControl alloc]init];
    //rc.attributedTitle = [[NSAttributedString alloc]initWithString:@"Loading..."];
    //[self.tableView addSubview:rc];
    
    //[self refreshSecrets];
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
        self.secrets = [mutableSecrets copy];
        [self.tableView reloadData];
        //[self.refreshControl endRefreshing];
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

#pragma mark - Refresh Secrets

- (void)loadNewSecrets {
    [[BeeAPIClient sharedClient] GETRecentSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        self.secrets = [mutableSecrets copy];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
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
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
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
    return self.secrets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BeeTableViewCell *cell = (BeeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    Secret *secret = self.secrets[indexPath.row];
    cell.secret = secret;
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}


#pragma mark - Table View delegate

- (void)adjustSizingCellWidthToTableWidth {
    sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Secret Show Segue" sender:self.secrets[indexPath.row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
