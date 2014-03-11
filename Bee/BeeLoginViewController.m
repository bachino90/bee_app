//
//  BeeLoginViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 05/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BeeUser.h"

@interface BeeLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginBtn;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@end

@implementation BeeLoginViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Login Success Segue"]) {
       
    }
}

- (IBAction)signInTouched:(UIButton *)sender {
    if (self.userTextField.text.length > 0  &&
        self.passwordTextField.text.length > 0) {
        //mandar el sign in
        NSDictionary *loginParams = [NSDictionary dictionaryWithObjectsAndKeys:self.userTextField.text, @"email",
                                                                               self.passwordTextField.text, @"password", nil];
        [[BeeAPIClient sharedClient]loginUserWithData:loginParams success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)[task response];
            NSLog(@"%@",[resp allHeaderFields]);
            NSLog(@"%@",(NSDictionary *)responseObject);
            
            [[BeeUser sharedUser] setNewSession:(NSDictionary *)responseObject];
            [self.delegate finishSuccessLogin];

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"fail");
        }];
    }
}

- (IBAction)facebookLoginTouched:(UIButton *)sender {
    if (FBSession.activeSession.state == FBSessionStateOpen ||
        FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {
        [FBSession openActiveSessionWithReadPermissions:[BeeUser basicPermissions]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          [[BeeUser sharedUser]facebookSessionStateChanged:session state:status error:error];
        }];
    }
}

@end
