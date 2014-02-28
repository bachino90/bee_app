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
#import "BeeAPIClient.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define FONT_SIZE 18.0f

#define FONT_SIZE 18.0f
#define LABEL_WIDTH 280.0f
#define LABEL_MINIMUM_HEIGHT 40.0f
#define LABEL_MAXIMUM_HEIGHT 280.0f
#define DEFAULT_LABEL_SIZE() CGSizeMake(280.0,90.0)

@interface BeeViewController () <UITableViewDataSource, UITableViewDelegate, BeeAddSecretViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *secrets;
@end

@implementation BeeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
        bvc.secret = (NSDictionary *)sender;
        //bvc.delegate = self;
    }
}

#pragma mark - Bee Add Secret View Controller Delegate

- (void)cancelPublication {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publishSecret:(NSDictionary *)secret {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - Table View data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.secrets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BeeTableViewCell";
    BeeTableViewCell *cell = (BeeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Secret *secret = self.secrets[indexPath.row];
    cell.secret = secret;
    return cell;
}


#pragma mark - Table View delegate
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [self.secrets[indexPath.row][@"content"] boundingRectWithSize:DEFAULT_LABEL_SIZE() options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE]} context:ctx];
    if (textRect.size.height < LABEL_MINIMUM_HEIGHT) {
        textRect.size.height = LABEL_MINIMUM_HEIGHT;
    } else if (textRect.size.height > LABEL_MAXIMUM_HEIGHT) {
        textRect.size.height = LABEL_MAXIMUM_HEIGHT;
    }

    CGFloat rowHeight = 20.0f + textRect.size.height + 30.0f + 6.0f + 8.0f;
    return rowHeight;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Secret Show Segue" sender:self.secrets[indexPath.row]];
}

@end
