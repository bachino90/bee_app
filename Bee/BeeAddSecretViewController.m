//
//  BeeAddSecretViewController.m
//  Bee
//
//  Created by Emiliano Bivachi on 28/02/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "BeeAddSecretViewController.h"
#import "Secret.h"
#import "Secret+Bee.h"
#import "BeeAPIClient.h"
#import "Reachability.h"

#define TEXTVIEW_MARGIN 20.0f
#define PHOTO_BUTTON_MARGIN 20.0f
#define ORIGIN_DESVIO 50.0f
#define SMALL_SCREEN_HEIGHT 480.0f

@interface BeeAddSecretViewController () <UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publicButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *navBarBackgroundView;
@property (strong, nonatomic) UITextView *textView;

@property (nonatomic, strong) UITapGestureRecognizer *showTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *hideTapGesture;
@property (nonatomic, strong) Reachability *internetReachability;
@property (nonatomic) CGFloat lastHeight;
@property (nonatomic) CGFloat lastPhotoY;
@property (nonatomic) BOOL isFirst;

@property (nonatomic) NSInteger actualColor;
@property (nonatomic) NSInteger actualFont;
@property (nonatomic, readonly) NSString *about;
@property (nonatomic) BOOL keyboardIsShow;
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

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)dealloc {
    [self unregisterForKeyboardNotifications];
}

- (void)setActualColor:(NSInteger)actualColor {
    if (actualColor >= 0) {
        if (actualColor >= [Secret colors].count) {
            _actualColor = 0;
        } else {
            _actualColor = actualColor;
        }
    } else if (actualColor < 0) {
        _actualColor = [Secret colors].count - 1;
    }
    
    self.navBarBackgroundView.backgroundColor = [Secret colors][_actualColor];
    self.backgroundView.backgroundColor = [Secret colors][_actualColor];
}

- (void)setActualFont:(NSInteger)actualFont {
    if (actualFont >= 0) {
        if (actualFont >= [Secret fonts].count) {
            _actualFont = 0;
        } else {
            _actualFont = actualFont;
        }
    } else if (actualFont < 0) {
        _actualFont = [Secret fonts].count - 1;
    }
    
    self.textView.font = [Secret fonts][_actualFont];
    [self calculateHeightForTextView:self.textView];
}

- (NSString *)about {
    NSString *color = [NSString stringWithFormat:@"%i,",self.actualColor];
    NSString *font = [NSString stringWithFormat:@"%i",self.actualFont];
    return [color stringByAppendingString:font];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont beeFontWithSize:20.0],
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    [self.cancelButton setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.publicButton setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectZero];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.text = @"Cuentanos un secreto";
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.font = [UIFont systemFontOfSize:19];
    self.textView.delegate = self;
    self.textView.layer.borderWidth = 1.0f;
    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.actualColor = 0;
    self.actualFont = 0;
    
    [self.backgroundView addSubview:self.textView];
    [self calculateHeightForTextView:self.textView];
    
    self.showTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showKeyboard)];
    self.showTapGesture.numberOfTouchesRequired = 1;
    self.showTapGesture.numberOfTapsRequired = 1;
    
    self.hideTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    self.hideTapGesture.numberOfTouchesRequired = 1;
    self.hideTapGesture.numberOfTapsRequired = 1;
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeLeftColor:)];
    leftSwipe.numberOfTouchesRequired = 1;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeRightColor:)];
    rightSwipe.numberOfTouchesRequired = 1;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeUpFont:)];
    upSwipe.numberOfTouchesRequired = 1;
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(changeDownFont:)];
    downSwipe.numberOfTouchesRequired = 1;
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.view.gestureRecognizers = @[self.showTapGesture,leftSwipe,rightSwipe,upSwipe,downSwipe];
    
    [self registerForNotifications];
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    self.isFirst = YES;
    self.keyboardIsShow = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)publicBtn:(UIBarButtonItem *)sender {
    if (self.textView.text.length == 0 || [self.textView.text isEqualToString:@"Cuentanos un secreto"]) {
        return;
    }
    NSLog(@"%@",self.textView.text);
    NSDictionary *sec = [NSDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"content",
                                                                   self.about, @"about",
                                                                   @"", @"media_url", nil];
    NSDictionary *secret = [NSDictionary dictionaryWithObjectsAndKeys:sec, @"secret", nil];
    [[BeeAPIClient sharedClient]POSTSecret:secret success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.delegate publishSecret:secret];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (IBAction)addPhoto:(UIButton *)sender {
    UIImagePickerController  *eImagePickerController = [[UIImagePickerController alloc] init];
    eImagePickerController.delegate = self;
    
    eImagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    eImagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    eImagePickerController.showsCameraControls = YES;
    eImagePickerController.navigationBarHidden = NO;
    eImagePickerController.allowsEditing = YES;
    
    [self presentViewController:eImagePickerController animated:YES completion:nil];
}

- (IBAction)cancelBtn:(UIBarButtonItem *)sender {
    [self.delegate cancelPublication];
}

#pragma mark - Swipe Gesture

- (void)changeLeftColor:(UISwipeGestureRecognizer *)swipeGesture {
    self.actualColor++;
}

- (void)changeRightColor:(UISwipeGestureRecognizer *)swipeGesture {
    self.actualColor--;
}

- (void)changeUpFont:(UISwipeGestureRecognizer *)swipeGesture {
    self.actualFont++;
}

- (void)changeDownFont:(UISwipeGestureRecognizer *)swipeGesture {
    self.actualFont--;
}

#pragma mark - Keyboard dismiss

- (void)showKeyboard {
    [self.textView becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.textView resignFirstResponder];
    if (self.textView.text.length == 0) {
        self.textView.text = @"Cuentanos un secreto";
        self.isFirst = YES;
    }
}

#pragma mark - Calculate Text View Height

- (void)setNewHeight:(CGFloat)height {
    CGRect frame = self.textView.bounds;
    frame.size.height = height;
    
    frame.size.width = SCREEN_WIDTH - TEXTVIEW_MARGIN;
    self.textView.frame = frame;
    if (self.keyboardIsShow && SCREEN_HEIGHT <= SMALL_SCREEN_HEIGHT) {
        self.textView.center = CGPointMake(self.backgroundView.frame.size.width/2.0, (self.backgroundView.frame.size.height/2.0) - ORIGIN_DESVIO);
    } else {
        self.textView.center = CGPointMake(self.backgroundView.frame.size.width/2.0, self.backgroundView.frame.size.height/2.0);
    }
    
}

- (void)calculateHeightForTextView:(UITextView *)textView {
    CGFloat maxHeight = SCREEN_WIDTH - 2 * TEXTVIEW_MARGIN;
    CGSize maxSize = CGSizeMake(SCREEN_WIDTH - TEXTVIEW_MARGIN, maxHeight);
    CGSize requiredSize = [textView sizeThatFits:maxSize];
    if (self.lastHeight != requiredSize.height && requiredSize.height < maxHeight) {
        [self setNewHeight:requiredSize.height];
        self.lastHeight = requiredSize.height;
    }
}

#pragma mark - Text view delegate

//Begin

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.isFirst) {
        self.textView.text = @"";
        self.isFirst = NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

//End

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self hideKeyboard];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

//Change

- (void)textViewDidChange:(UITextView *)textView {
    [self calculateHeightForTextView:textView];
    if (self.textView.text.length > 0) {
        self.publicButton.enabled = YES;
    } else {
        self.publicButton.enabled = NO;
    }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
}

#pragma mark - Reachability Notifications

- (void)updateInterfaceWithReachability:(Reachability *)reach {
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    //BOOL connectionRequired = [reach connectionRequired];
    switch (netStatus) {
        case NotReachable:
            self.publicButton.enabled = NO;
            break;
        default:
            self.publicButton.enabled = YES;
            break;
    }
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *reach = note.object;
    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:reach];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat newOriginY = self.view.frame.size.height - kbSize.height;
    CGFloat photoY = self.photoButton.frame.origin.y + self.photoButton.frame.size.height;
    
    [self.view removeGestureRecognizer:self.showTapGesture];
    [self.view addGestureRecognizer:self.hideTapGesture];
    
    self.lastPhotoY = self.photoButton.frame.origin.y;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (newOriginY < photoY) {
        CGFloat newY = newOriginY - self.photoButton.frame.size.height - PHOTO_BUTTON_MARGIN;
        self.photoButton.frame = CGRectMake(self.photoButton.frame.origin.x, newY, self.photoButton.frame.size.width, self.photoButton.frame.size.height);
    }
    if (SCREEN_HEIGHT <= SMALL_SCREEN_HEIGHT) {
        CGFloat newTextViewY = self.textView.frame.origin.y - ORIGIN_DESVIO;
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, newTextViewY, self.textView.frame.size.width, self.textView.frame.size.height);
    }
    [UIView commitAnimations];
    
    self.keyboardIsShow = YES;
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    [self.view removeGestureRecognizer:self.hideTapGesture];
    [self.view addGestureRecognizer:self.showTapGesture];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGFloat newY = self.lastPhotoY;
    self.photoButton.frame = CGRectMake(self.photoButton.frame.origin.x, newY, self.photoButton.frame.size.width, self.photoButton.frame.size.height);
    if (SCREEN_HEIGHT <= SMALL_SCREEN_HEIGHT) {
        CGFloat newTextViewY = self.textView.frame.origin.y + ORIGIN_DESVIO;
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, newTextViewY, self.textView.frame.size.width, self.textView.frame.size.height);
    }
    [UIView commitAnimations];
    
    self.keyboardIsShow = NO;
}

@end
