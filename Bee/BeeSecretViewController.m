//
//  BeeSecretViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSecretViewController.h"
#import "BeeCommentTableViewCell.h"
#import "BeeTableViewCell.h"
#import "Comment.h"

@interface BeeSecretViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
        NSLog(@"%@",[responseObject description]);
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtn:(UIButton *)sender {
    [self.delegate dismissBeeSecretViewController:self];
}

#pragma mark - Table View data source

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


@end
