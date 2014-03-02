//
//  BeeViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 27/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeViewController.h"
#import "BeeAddSecretViewController.h"
#import "BeeSecretViewController.h"
#import "BeeTableViewCell.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define FONT_SIZE 18.0f

#define FONT_SIZE 18.0f
#define LABEL_WIDTH 280.0f
#define LABEL_MINIMUM_HEIGHT 40.0f
#define LABEL_MAXIMUM_HEIGHT 280.0f
#define DEFAULT_LABEL_SIZE() CGSizeMake(280.0,90.0)

@interface BeeViewController () <UITableViewDataSource, UITableViewDelegate, BeeAddSecretViewControllerDelegate, BeeSecretViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *secrets;
@end

@implementation BeeViewController {
    dispatch_once_t onceToken;
    NSMutableDictionary *rowHeightCache;
    BeeTableViewCell *sizingCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    rowHeightCache = [NSMutableDictionary dictionary];
    [[BeeAPIClient sharedClient] GETSecretsAbout:@"" friends:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *mutableSecrets = [[NSMutableArray alloc]init];
        int i = 0;
        for (NSDictionary *secret in (NSArray *)responseObject) {
            mutableSecrets[i] = [[Secret alloc]initWithDictionary:secret];
            i++;
        }
        self.secrets = [mutableSecrets copy];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
