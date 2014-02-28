//
//  BeeAddSecretViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeAddSecretViewController.h"
#import "BeeAPIClient.h"

@interface BeeAddSecretViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *publicButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation BeeAddSecretViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publicBtn:(UIBarButtonItem *)sender {
    NSDictionary *sec = [NSDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"content",
                                                                      @"00", @"about",
                                                                      @"", @"media_url", nil];
    NSDictionary *secret = [NSDictionary dictionaryWithObjectsAndKeys:sec, @"secret", nil];
    [[BeeAPIClient sharedClient]POSTSecret:secret success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.delegate publishSecret:secret];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (IBAction)cancelBtn:(UIBarButtonItem *)sender {
    [self.delegate cancelPublication];
}

@end
