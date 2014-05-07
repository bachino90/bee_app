//
//  BeeSecretViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSecretViewController.h"
#import "BeeCommentTableViewCell.h"
#import "BeeLastCommentsTableViewCell.h"
#import "BeeSecretView.h"
#import "Comment.h"
#import "BeeCommentView.h"
#import "BeeCommentFooterView.h"
#import "Reachability.h"

#import "CoreDataController.h"
#import "BeeSyncEngine.h"

#define HEADER_HEIGHT 50.0f

@interface BeeSecretViewController () <UITableViewDataSource, UITableViewDelegate, BeeCommentViewDelegate, BeeCommentTableViewCellDelegate, BeeLastCommentsTableViewCellDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BeeCommentView *commentView;
@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic, strong) NSArray *comments;

@property (nonatomic) BOOL isSendingComment;
@end

@implementation BeeSecretViewController {
    dispatch_once_t onceToken;
    NSMutableDictionary *rowHeightCache;
    BeeCommentTableViewCell *sizingCell;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)comments {
    if (_comments) {
        return _comments;
    }
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES];
    NSLog(@"%@",self.secret.comments);
    _comments = [self.secret.comments sortedArrayUsingDescriptors:@[descriptor]];
    
    return _comments;
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BeeSyncEngineSyncCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
        rowHeightCache = [NSMutableDictionary dictionary];
        self.tableView.tableFooterView = nil;
        self.comments = nil;
        
        [self.tableView reloadData];
        if (self.isSendingComment) {
            [self scrollToBottom];
            self.isSendingComment = NO;
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BeeSyncEngineSyncFailed" object:nil queue:nil usingBlock:^(NSNotification *note) {
        
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"BeeSyncEngineSyncAllCommentsCompleted" object:nil queue:nil usingBlock:^(NSNotification *note) {
    }];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BeeSyncEngineSyncCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BeeSyncEngineSyncFailed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BeeSyncEngineSyncAllCommentsCompleted" object:nil];
}

- (void)dealloc {
    [self unregisterForNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isSendingComment = NO;
    
    rowHeightCache = [NSMutableDictionary dictionary];
    
    BeeSecretView *headerView = [[BeeSecretView alloc]initWithSecret:self.secret];
    self.tableView.tableHeaderView = headerView;
    
    self.commentView.delegate = self;
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - self.commentView.frame.size.height);
    
    [self registerForNotifications];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    // FOOTER
    self.tableView.tableFooterView = [[BeeCommentFooterView alloc]init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[BeeSyncEngine sharedEngine]startSearchingRecentCommentsForSecret:self.secret];
    [self registerForNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtn:(UIButton *)sender {
    [self.delegate dismissBeeSecretViewController:self];
}

- (void)updateInterfaceWithReachability:(Reachability *)reach {
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    //BOOL connectionRequired = [reach connectionRequired];
    switch (netStatus) {
        case NotReachable:
            //[self.commentView setEnablePost:NO];
            break;
        default:
            [self.commentView setEnablePost:YES];
            break;
    }
}

-(void)scrollToBottom{
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    //[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height)];
}

#pragma mark - Reachability Notifications

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *reach = note.object;
    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:reach];
}

#pragma mark - Comment View delegate

- (void)commentView:(BeeCommentView *)commentView keyboardWillShown:(NSDictionary *)info {
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat newHeight = SCREEN_HEIGHT - kbSize.height - commentView.frame.size.height;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,  self.tableView.frame.origin.y, self.tableView.frame.size.width, newHeight);
    //[self scrollToBottom];
}

- (void)commentView:(BeeCommentView *)commentView keyboardWillHidden:(NSDictionary *)info {
    CGFloat newHeight = SCREEN_HEIGHT - commentView.frame.size.height;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,  self.tableView.frame.origin.y, self.tableView.frame.size.width, newHeight);
}

- (void)commentView:(BeeCommentView *)commentView resizeFrame:(CGRect)frame {
    CGFloat newHeight = frame.origin.y;
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,  self.tableView.frame.origin.y, self.tableView.frame.size.width, newHeight);
}

- (void)commentView:(BeeCommentView *)commentView postComment:(NSString *)comment {
    [self postComment:comment];
}

- (void)postComment:(NSString *)content {
    NSDictionary *comment = [NSDictionary dictionaryWithObjectsAndKeys:content, @"content", nil];
    self.isSendingComment = YES;
    [[BeeSyncEngine sharedEngine]startPostingComment:comment forSecret:self.secret];
}

- (void)rePostComment:(Comment *)comment {
    [[BeeSyncEngine sharedEngine] startRePostingComment:comment forSecret:self.secret];
}

- (void)deleteComment:(Comment *)comment {
    [[BeeSyncEngine sharedEngine] startDeletingComment:comment forSecret:self.secret];
}


#pragma mark - BeeCommentTableViewCell Delegate

- (void)commentCell:(BeeCommentTableViewCell *)cell rePostComment:(NSString *)content {
    [self rePostComment:cell.comment];
}

- (void)commentCell:(BeeCommentTableViewCell *)cell deleteComment:(NSString *)content {
    [self deleteComment:cell.comment];
}

#pragma mark - BeeLastCommentsTableViewCell Delegate

- (void)searchOldComments:(BeeLastCommentsTableViewCell *)cell {
    [[BeeSyncEngine sharedEngine]startSearchingOldCommentsForSecret:self.secret];
}

#pragma mark - Table View data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)cellIdentifier {
    static NSString *CellCommentIdentifier = @"BeeCommentTableViewCell";
    return CellCommentIdentifier;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.secret.comments.count > 0 && [self.secret.all_comments_loaded boolValue]) {
        return self.secret.comments.count;
    } else if (self.secret.comments.count > 0 && ![self.secret.all_comments_loaded boolValue]) {
        return self.comments.count + 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.secret.all_comments_loaded boolValue] && indexPath.row == 0) {
        BeeLastCommentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LastCommentsCell" forIndexPath:indexPath];
        [cell restartCell];
        cell.delegate = self;
        return cell;
    } else {
        BeeCommentTableViewCell *cell = (BeeCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
        
        Comment *comment;
        if ([self.secret.all_comments_loaded boolValue]) {
            comment = self.comments[indexPath.row];
        } else {
            comment = self.comments[indexPath.row - 1];
        }
        cell.comment = comment;
        cell.delegate = self;
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        return cell;
    }
}

#pragma mark - Table View delegate

- (void)adjustSizingCellWidthToTableWidth {
    sizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    dispatch_once(&onceToken, ^{
        sizingCell = (BeeCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
        [self adjustSizingCellWidthToTableWidth];
    });
    
    
    if (![self.secret.all_comments_loaded boolValue] && indexPath.row == 0) {
        return 50.0;
    }
    
    NSString *index;
    if (![self.secret.all_comments_loaded boolValue]) {
        index = [NSString stringWithFormat:@"%i",indexPath.row - 1];
    } else {
        index = [NSString stringWithFormat:@"%i",indexPath.row];
    }
    
    
    if (rowHeightCache[index] == nil) {
        if (![self.secret.all_comments_loaded boolValue]) {
            sizingCell.comment = self.comments[indexPath.row - 1];
        } else {
            sizingCell.comment = self.comments[indexPath.row];
        }
        CGFloat rowHeight = sizingCell.requiredCellHeight;
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        rowHeightCache[index] = @(rowHeight);
    }
    
    return [rowHeightCache[index] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.92];
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *likeTitle = [NSString stringWithFormat:@"L%i", [self.secret.likes_count integerValue]];
    [likeBtn setTitle:likeTitle forState:UIControlStateNormal];
    likeBtn.frame = CGRectMake(SCREEN_WIDTH - 50.0, 0.0, 40.0, HEADER_HEIGHT);
    [headerView addSubview:likeBtn];
    headerView.layer.borderColor = [UIColor grayColor].CGColor;
    headerView.layer.borderWidth = 1.0f;
    return headerView;
}


@end
