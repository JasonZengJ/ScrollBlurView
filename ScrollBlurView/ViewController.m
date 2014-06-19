//
//  ViewController.m
//  ScrollBlurView
//
//  Created by jason on 6/19/14.
//  Copyright (c) 2014 jason. All rights reserved.
//

#import "ViewController.h"
#import "ScrollBlurView.h"

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@property NSArray        *color;
@property UIButton       *blurViewButton;
@property ScrollBlurView *scrollBlurView;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        
        _color = @[[UIColor grayColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor yellowColor]];
        _blurViewButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 450, 100, 50)];
        _blurViewButton.backgroundColor   = [UIColor colorWithRed:0.1 green:0.7 blue:0.9 alpha:1.0];
        [_blurViewButton setTitle:@"blurView" forState:UIControlStateNormal];
        [_blurViewButton addTarget:self action:@selector(swipeView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_blurViewButton];
        [self.view addSubview:[self addDotButtonWithFrame:CGRectMake(100, 100, 50,50)]];
        [self.view addSubview:[self addDotButtonWithFrame:CGRectMake(30, 30, 50,50)]];
        [self.view addSubview:[self addDotButtonWithFrame:CGRectMake(150, 150, 50, 50)]];
        [self.view addSubview:[self addDotButtonWithFrame:CGRectMake(100, 250, 50, 50)]];
        [self.view addSubview:[self addDotButtonWithFrame:CGRectMake(200, 250, 50, 50)]];
        [self.view addSubview:[self addDotButtonWithFrame:CGRectMake(160, 350, 50, 50)]];
        
        
        _scrollBlurView = [[ScrollBlurView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
        
        // the method addBlurView of ScrollBlurView must invocated behind addSubview
        [self.view addSubview:_scrollBlurView];
        [_scrollBlurView addBlurView:self.view withRadius:0.4];
    }
    return self;
}

- (void) swipeView:(id)sender{
    
    [_scrollBlurView animateUpWithDuration:0.5];
    
}

- (UIButton*)addDotButtonWithFrame:(CGRect)frame
{
    
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.layer.cornerRadius = 25;
    button.backgroundColor = [_color objectAtIndex:random() % _color.count];
    
    return  button;
    
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
