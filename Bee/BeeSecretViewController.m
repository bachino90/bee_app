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

#define HEADER_HEIGHT 50.0f

@interface BeeSecretViewController () <UITableViewDataSource, UITableViewDelegate, BeeCommentViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BeeCommentView *commentView;
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
    
    self.commentView = [[BeeCommentView alloc]init];
    self.commentView.delegate = self;
    [self.view addSubview:self.commentView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtn:(UIButton *)sender {
    [self.delegate dismissBeeSecretViewController:self];
}

#pragma mark - Comment View delegate

- (void)commentView:(BeeCommentView *)commentView keyboardWillShown:(NSDictionary *)info {
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat newHeight = self.tableView.frame.size.height - kbSize.height;
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
    
    Comment *comm = [[Comment alloc]initWithContent:comment];
    self.secret.comments = [self.secret.comments arrayByAddingObject:comm];
    [self.tableView reloadData];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"content", nil];
    NSDictionary *dictComment = [NSDictionary dictionaryWithObjectsAndKeys:params, @"comment", nil];
    [[BeeAPIClient sharedClient]POSTComment:dictComment forSecret:self.secret.secretID success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
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
    likeBtn.frame = CGRectMake(SCREEN_WIDTH - 100.0, 0.0, 40.0, HEADER_HEIGHT);
    [headerView addSubview:likeBtn];
    headerView.layer.borderColor = [UIColor grayColor].CGColor;
    headerView.layer.borderWidth = 1.0f;
    return headerView;
}


@end
