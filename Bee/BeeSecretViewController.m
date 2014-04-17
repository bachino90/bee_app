//
//  BeeSecretViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSecretViewController.h"
#import "BeeCommentTableViewCell.h"
#import "BeeSecretView.h"
#import "Comment.h"
#import "BeeCommentView.h"
#import "Reachability.h"

#define HEADER_HEIGHT 50.0f

@interface BeeSecretViewController () <UITableViewDataSource, UITableViewDelegate, BeeCommentViewDelegate, BeeCommentTableViewCellDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BeeCommentView *commentView;
@property (nonatomic, strong) Reachability *internetReachability;
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

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)dealloc {
    [self unregisterForNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    rowHeightCache = [NSMutableDictionary dictionary];
    [[BeeAPIClient sharedClient]GETCommentsForSecret:self.secret.secretID success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableComments = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSDictionary *comment in (NSArray *)responseObject) {
            mutableComments[i] = [[Comment alloc]initWithDictionary:comment];
            i++;
        }
        self.secret.comments = [mutableComments copy];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    BeeSecretView *headerView = [[BeeSecretView alloc]initWithSecret:self.secret];
    self.tableView.tableHeaderView = headerView;
    
    self.commentView.delegate = self;
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - self.commentView.frame.size.height);
    
    [self registerForNotifications];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
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
            [self.commentView setEnablePost:NO];
            break;
        default:
            [self.commentView setEnablePost:YES];
            break;
    }
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
    
    __block Comment *comm = [[Comment alloc]initWithContent:comment];
    self.secret.comments = [self.secret.comments arrayByAddingObject:comm];
    [self.tableView reloadData];
    NSInteger index = [self.secret.comments indexOfObject:comm];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    BeeCommentTableViewCell *cell = (BeeCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [self postComment:comm withCell:cell];
}

- (void)postComment:(Comment *)comment withCell:(BeeCommentTableViewCell *)cell {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:comment.content, @"content", nil];
    NSDictionary *dictComment = [NSDictionary dictionaryWithObjectsAndKeys:params, @"comment", nil];
    comment.state = CommentDelivered;
    cell.comment = comment;
    __block Comment *comm = comment;
    [[BeeAPIClient sharedClient]POSTComment:dictComment inSecret:self.secret.secretID success:^(NSURLSessionDataTask *task, id responseObject) {
        comm.state = CommentSuccessDelivered;
        comm.createdAt = [NSDate date];
        cell.comment = comm;
        cell.delegate = nil;
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        comm.state = CommentFailDelivered;
        cell.comment = comm;
        cell.delegate = self;
        [self.tableView reloadData];
    }];
}

- (void)deleteComment:(Comment *)comment inCell:(BeeCommentTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray *array = [self.secret.comments mutableCopy];
    [array removeObjectAtIndex:indexPath.row];
    self.secret.comments = [array copy];
    [self.tableView reloadData];
}


#pragma mark - BeeCommentTableViewCell Delegate

- (void)commentCell:(BeeCommentTableViewCell *)cell rePostComment:(Comment *)comment {
    [self postComment:comment withCell:cell];
}

- (void)commentCell:(BeeCommentTableViewCell *)cell deleteComment:(Comment *)comment {
    [self deleteComment:comment inCell:cell];
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
    return self.secret.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BeeCommentTableViewCell *cell = (BeeCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    Comment *comment = self.secret.comments[indexPath.row];
    cell.comment = comment;
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
        sizingCell = (BeeCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
        [self adjustSizingCellWidthToTableWidth];
    });
    
    NSString *index = [NSString stringWithFormat:@"%i",indexPath.row];
    
    if (rowHeightCache[index] == nil) {
        sizingCell.comment = self.secret.comments[indexPath.row];
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
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *likeTitle = [NSString stringWithFormat:@"L%i", self.secret.likesCount];
    [likeBtn setTitle:likeTitle forState:UIControlStateNormal];
    likeBtn.frame = CGRectMake(SCREEN_WIDTH - 50.0, 0.0, 40.0, HEADER_HEIGHT);
    [headerView addSubview:likeBtn];
    headerView.layer.borderColor = [UIColor grayColor].CGColor;
    headerView.layer.borderWidth = 1.0f;
    return headerView;
}


@end
