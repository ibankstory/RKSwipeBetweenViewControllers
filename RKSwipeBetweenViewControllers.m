//
//  RKSwipeBetweenViewControllers.m
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for regular updates

#import "RKSwipeBetweenViewControllers.h"

//%%% customizeable button attributes
CGFloat X_BUFFER = 2.0; //%%% the number of pixels on either side of the segment
CGFloat Y_BUFFER = 8.0; //%%% number of pixels on top of the segment
CGFloat HEIGHT = 30.0; //%%% height of the segment

//%%% customizeable selector bar attributes (the black bar under the buttons)
CGFloat BOUNCE_BUFFER = 10.0; //%%% adds bounce to the selection bar when you scroll
CGFloat ANIMATION_SPEED = 0.2; //%%% the number of seconds it takes to complete the animation
//CGFloat SELECTOR_Y_BUFFER = 40.0; //%%% the y-value of the bar that shows what page you are on (0 is the top)
//CGFloat SELECTOR_HEIGHT = 2.0; //%%% thickness of the selector bar

CGFloat X_OFFSET = 8.0; //%%% for some reason there's a little bit of a glitchy offset.  I'm going to look for a better workaround in the future

CGFloat BUTTON_WIDTH = 80.0;
CGFloat NAVIGATION_VIEW_Y = 64;
@interface RKSwipeBetweenViewControllers ()

@property (nonatomic) UIScrollView *pageScrollView;
@property (nonatomic) NSInteger currentPageIndex;
@property (nonatomic) BOOL isPageScrollingFlag; //%%% prevents scrolling / segment tap crash
@property (nonatomic) BOOL hasAppearedFlag; //%%% prevents reloading (maintains state)
@property (nonatomic) UIView *navigationBarBackgroundView;
@end

@implementation RKSwipeBetweenViewControllers
@synthesize viewControllerArray;
@synthesize selectionBar;
@synthesize pageController;
@synthesize navigationView;
@synthesize buttonText;
@synthesize SELECTOR_HEIGHT;
@synthesize SELECTOR_Y_BUFFER;

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

    viewControllerArray = [[NSMutableArray alloc]init];
    self.currentPageIndex = 0;
    self.isPageScrollingFlag = NO;
    self.hasAppearedFlag = NO;
    
    if (SELECTOR_HEIGHT == 0){
        SELECTOR_HEIGHT = 2;
    }
    
    if (SELECTOR_Y_BUFFER == 0) {
        SELECTOR_Y_BUFFER = 100;
    }
    
    if (!self.navigationBarColor) {
        self.navigationBarColor = [UIColor clearColor];
    }
    
    self.navigationBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, NAVIGATION_VIEW_Y)];
    self.navigationBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationBarBackgroundView.backgroundColor = self.navigationBarColor;
    [self.view insertSubview:self.navigationBarBackgroundView belowSubview:self.navigationBar];
    
}

#pragma mark Customizables

//%%% color of the status bar
-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
//    return UIStatusBarStyleDefault;
}

//%%% sets up the tabs using a loop.  You can take apart the loop to customize individual buttons, but remember to tag the buttons.  (button.tag=0 and the second button.tag=1, etc)
-(void)setupSegmentButtons {
    
    navigationView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAVIGATION_VIEW_Y,self.view.frame.size.width,44)];
    navigationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(!self.navigationViewBackgroundColor){
        self.navigationViewBackgroundColor = [UIColor clearColor];
    }
    
    navigationView.backgroundColor = self.navigationViewBackgroundColor;
    
    NSInteger numControllers = [viewControllerArray count];
    
    if (!buttonText) {
         buttonText = [[NSArray alloc]initWithObjects: @"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",nil]; //%%%buttontitle
    }
    
    if (!self.selectedButtonColor) {
        self.selectedButtonColor = [UIColor colorWithWhite:1 alpha:1];
    }
    
    if (!self.normalButtonColor) {
        self.normalButtonColor = [UIColor colorWithWhite:1 alpha:0.7];
    }
    
    if (!self.buttonFont) {
        self.buttonFont = [UIFont systemFontOfSize:14];
    }
    
    for (int i = 0; i<numControllers; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((BUTTON_WIDTH*i), Y_BUFFER, BUTTON_WIDTH, HEIGHT)];
        
        [navigationView addSubview:button];
        
        button.tag = i; //%%% IMPORTANT: if you make your own custom buttons, you have to tag them appropriately
        
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitle:[buttonText objectAtIndex:i] forState:UIControlStateNormal]; //%%%buttontitle
        [button.titleLabel setFont:self.buttonFont];
        
        if (i == 0) {
            [button setTitleColor:self.selectedButtonColor forState:UIControlStateNormal];
        }else{
            [button setTitleColor:self.normalButtonColor forState:UIControlStateNormal];
        }
    }
    
    navigationView.contentSize = CGSizeMake(numControllers*BUTTON_WIDTH, navigationView.frame.size.height);
    navigationView.showsHorizontalScrollIndicator = NO;
    navigationView.scrollEnabled = NO;
    [self.view addSubview:navigationView];

    
    //%%% example custom buttons example:
    /*
    NSInteger width = (self.view.frame.size.width-(2*X_BUFFER))/3;
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER, Y_BUFFER, width, HEIGHT)];
    UIButton *middleButton = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+width, Y_BUFFER, width, HEIGHT)];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+2*width, Y_BUFFER, width, HEIGHT)];
    
    [self.navigationBar addSubview:leftButton];
    [self.navigationBar addSubview:middleButton];
    [self.navigationBar addSubview:rightButton];
    
    leftButton.tag = 0;
    middleButton.tag = 1;
    rightButton.tag = 2;
    
    leftButton.backgroundColor = [UIColor colorWithRed:0.03 green:0.07 blue:0.08 alpha:1];
    middleButton.backgroundColor = [UIColor colorWithRed:0.03 green:0.07 blue:0.08 alpha:1];
    rightButton.backgroundColor = [UIColor colorWithRed:0.03 green:0.07 blue:0.08 alpha:1];
    
    [leftButton addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleButton addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [leftButton setTitle:@"left" forState:UIControlStateNormal];
    [middleButton setTitle:@"middle" forState:UIControlStateNormal];
    [rightButton setTitle:@"right" forState:UIControlStateNormal];
     */
    
    [self setupSelector];
}


//%%% sets up the selection bar under the buttons on the navigation bar
-(void)setupSelector {
    
    
    selectionBar = [[UIView alloc]initWithFrame:CGRectMake( (navigationView.frame.size.width/2) - (BUTTON_WIDTH/2) ,SELECTOR_Y_BUFFER,BUTTON_WIDTH, SELECTOR_HEIGHT)];
    if (!self.selectionBarColor) {
        self.selectionBarColor = [UIColor whiteColor];
    }
    selectionBar.backgroundColor = self.selectionBarColor; //%%% sbcolor
    selectionBar.alpha = 1.0; //%%% sbalpha
    [self.view addSubview:selectionBar];
    
}
- (void)updateSelectionBarFrame{
    selectionBar.frame = CGRectMake((navigationView.frame.size.width/2) - (BUTTON_WIDTH/2) ,SELECTOR_Y_BUFFER,BUTTON_WIDTH, SELECTOR_HEIGHT);
}

//generally, this shouldn't be changed unless you know what you're changing
#pragma mark Setup

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasAppearedFlag) {
        [self setupPageViewController];
        [self setupSegmentButtons];
        self.hasAppearedFlag = YES;
        [self updateNavigationViewOffset:self.pageScrollView];
    }
}

- (void)viewDidLayoutSubviews
{
    [self updateSelectionBarFrame];
}

//%%% generic setup stuff for a pageview controller.  Sets up the scrolling style and delegate for the controller
-(void)setupPageViewController {
    pageController = (UIPageViewController*)self.topViewController;
    pageController.delegate = self;
    pageController.dataSource = self;
    [pageController setViewControllers:@[[viewControllerArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

//%%% this allows us to get information back from the scrollview, namely the coordinate information that we can link to the selection bar.
-(void)syncScrollView {
    for (UIView* view in pageController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            self.pageScrollView.delegate = self;
        }
    }
}

//%%% methods called when you tap a button or scroll through the pages
// generally shouldn't touch this unless you know what you're doing or
// have a particular performance thing in mind

#pragma mark Movement

//%%% when you tap one of the buttons, it shows that page,
//but it also has to animate the other pages to make it feel like you're crossing a 2d expansion,
//so there's a loop that shows every view controller in the array up to the one you selected
//eg: if you're on page 1 and you click tab 3, then it shows you page 2 and then page 3
-(void)tapSegmentButtonAction:(UIButton *)button {

    [self updateSelectedButton:button.tag];
    
    if (!self.isPageScrollingFlag) {
        
        NSInteger tempIndex = self.currentPageIndex;
        
        __weak typeof(self) weakSelf = self;
        
        //%%% check to see if you're going left -> right or right -> left
        if (button.tag > tempIndex) {
            
            //%%% scroll through all the objects between the two points
            for (int i = (int)tempIndex+1; i<=button.tag; i++) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                    
                    //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                    //then it updates the page that it's currently on
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:i];

                    }
                }];
            }
        }
        
        //%%% this is the same thing but for going right -> left
        else if (button.tag < tempIndex) {
            for (int i = (int)tempIndex-1; i >= button.tag; i--) {
                [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:i];
                    }
                }];
            }
        }
    }
    
    
}

//%%% makes sure the nav bar is always aware of what page you're on
//in reference to the array of view controllers you gave
-(void)updateCurrentPageIndex:(int)newIndex {
    self.currentPageIndex = newIndex;
}

- (void)updateSelectedButton:(NSInteger)index{
    
    for (id subview in navigationView.subviews) {
        
        if ([subview isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)subview;
            if (button.tag == index) {
                [button setTitleColor:self.selectedButtonColor forState:UIControlStateNormal];
            }else{
                [button setTitleColor:self.normalButtonColor forState:UIControlStateNormal];
            }
        }
        
        
    }
}

//%%% method is called when any of the pages moves.
//It extracts the xcoordinate from the center point and instructs the selection bar to move accordingly
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavigationViewOffset:scrollView];
}

- (void)updateNavigationViewOffset:(UIScrollView *)scrollView {
    
    CGFloat view_width = navigationView.frame.size.width;
    
    CGFloat center = ((view_width - scrollView.contentOffset.x)*2) / [viewControllerArray count];

    NSInteger xCoor = self.currentPageIndex * BUTTON_WIDTH - (navigationView.frame.size.width/2 - BUTTON_WIDTH/2);
    
    NSInteger current_xCoor = (xCoor - center);
    
    NSInteger next_xCoor = xCoor + BUTTON_WIDTH;
    
    NSInteger previous_xCoor = next_xCoor - BUTTON_WIDTH*2;
    
    
    if (current_xCoor > next_xCoor) {
        current_xCoor = next_xCoor;
    }
    
    if (current_xCoor < previous_xCoor) {
        current_xCoor = previous_xCoor;
    }
    
    navigationView.contentOffset = CGPointMake(current_xCoor, 0);
    
}


//%%% the delegate functions for UIPageViewController.
//Pretty standard, but generally, don't touch this.
#pragma mark UIPageViewController Delegate Functions

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [viewControllerArray indexOfObject:viewController];

    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [viewControllerArray indexOfObject:viewController];

    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [viewControllerArray count]) {
        return nil;
    }
    return [viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currentPageIndex = [viewControllerArray indexOfObject:[pageViewController.viewControllers lastObject]];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = YES;
    
    selectionBar.alpha = 0.6;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isPageScrollingFlag = NO;
    
    [self updateSelectedButton:self.currentPageIndex];
    
    selectionBar.alpha = 1.0;
}


#pragma mark - Custom
- (void)changeNavigationViewBackgroundColor:(UIColor *)color withAnimation:(BOOL)animation
{
    self.navigationViewBackgroundColor = color;
    
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^(void){
            self.navigationView.backgroundColor = self.navigationViewBackgroundColor;
        }];
        
    }else{
        self.navigationView.backgroundColor = self.navigationViewBackgroundColor;
    }
}

- (void)changeNavigationBarColor:(UIColor *)color withTranslucent:(BOOL)translucent
{
    if (color == [UIColor clearColor]){
        [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[[UIImage alloc]init]];
    }else{
        self.navigationBarColor = color;
        self.navigationBar.barTintColor = self.navigationBarColor;
    }
    
    self.navigationBar.translucent = translucent;
    self.navigationBarBackgroundView.backgroundColor = self.navigationBarColor;
    
}
- (void)changeNavigationBarColor:(UIColor *)color viewAlpha:(CGFloat)alpha
{
    self.navigationBarBackgroundView.backgroundColor = color;
    self.navigationBarBackgroundView.alpha = alpha;
}
- (void)changeNavigationBarBackgroundViewAlpha:(CGFloat)alpha
{
    if (self.navigationBarBackgroundView) {
        self.navigationBarBackgroundView.alpha = alpha;
    }
}

@end
