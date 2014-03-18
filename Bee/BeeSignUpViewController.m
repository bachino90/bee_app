//
//  BeeSignUpViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 17/03/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeSignUpViewController.h"
#import "BeeUser.h"

@interface BeeSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmation;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation BeeSignUpViewController

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

- (IBAction)signUpTouched:(id)sender {
    if (self.userEmail.text.length > 0  &&
        self.password.text.length > 0 &&
        self.passwordConfirmation.text.length > 0 &&
        [self.password.text isEqualToString:self.passwordConfirmation.text]) {
        //mandar el sign in
        NSDictionary *loginParams = [NSDictionary dictionaryWithObjectsAndKeys:self.userEmail.text, @"email",
                                                                               self.password.text, @"password",
                                                                               self.passwordConfirmation.text, @"password_confirmation", nil];
        [[BeeAPIClient sharedClient]signupUserWithData:loginParams success:^(NSURLSessionDataTask *task, id responseObject) {
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

- (IBAction)cancelTouched:(id)sender {
    [self.delegate cancelSignUp];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
