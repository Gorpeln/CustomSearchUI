//
//  SuperViewController.m
//  TakeAway
//
//  Created by chen on 2017/3/6.
//  Copyright © 2017年 Gorpeln. All rights reserved.
//

#import "SuperViewController.h"

@interface SuperViewController ()<UIGestureRecognizerDelegate>

@end

@implementation SuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initNavigationBar];
    [self addSlideRightToBack];
    

}

- (void)initTitle:(NSString *)title{
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = FONTOFHEITISC(18.0);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

- (void)initNavigationBar{
    
    //分层，只需要image一层
    CGRect rect = CGRectMake(0, 0, BOUNDS_WIDTH, 64);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    //设置返回按钮颜色和文字
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self initLeftBarButtonItem];
    
}

- (void)initLeftBarButtonItem{
    
    UIButton* lBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lBarBtn.frame = CGRectMake(0, 0, 30, 30);
    lBarBtn.backgroundColor = [UIColor clearColor];
    lBarBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [lBarBtn setImage:[UIImage imageNamed:@"m_backArrow.png"]
             forState:UIControlStateNormal];
    [lBarBtn addTarget:self action:@selector(lBarBtnPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* lBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:lBarBtn];
    self.navigationItem.leftBarButtonItem = lBarBtnItem;
    
}


-(void)lBarBtnPressed:(id)sender{
    
    if (self.presentingViewController) {
        [self dismissToRootViewController];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
 
}

-(void)dismissToRootViewController
{
    UIViewController *vc = self;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)initRightBarButtonItemWithTitle:(NSString *)string{
    
    UIButton* rBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rBarBtn.frame = CGRectMake(0, 0, 50, 30);
    rBarBtn.titleLabel.font = FONTOFHEITISC(15.0);
    [rBarBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rBarBtn setTitle:string forState:UIControlStateNormal];
    [rBarBtn addTarget:self action:@selector(rBarBtnPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rBarBtn];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    [self.navigationController.navigationBar
     setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rBarBtnItem, nil];
}

- (void)initRightBarButtonItemWithImg:(UIImage *)img{
    
    UIButton* rBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rBarBtn.frame = CGRectMake(0, 0, 50, 30);
    rBarBtn.titleLabel.font = FONTOFHEITISC(15.0);
    [rBarBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rBarBtn setTitle:@"右侧" forState:UIControlStateNormal];
    [rBarBtn addTarget:self action:@selector(rBarBtnPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rBarBtn];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    [self.navigationController.navigationBar
     setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rBarBtnItem, nil];
}

-(void)rBarBtnPressed:(id)sender{
    
}

- (UIWindow *)keyWindow{
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    return keyWindow;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

#pragma mark - slideRightToBack
-(void)addSlideRightToBack{

    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

}

-(void)handleNavigationTransition:(UIPanGestureRecognizer *)gestureRecognizer{
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if (self && [[self.view gestureRecognizers] containsObject:gestureRecognizer]) {
            CGPoint tPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
            if (tPoint.x >= 0) {
                CGFloat y = fabs(tPoint.y);
                CGFloat x = fabs(tPoint.x);
                CGFloat af = 30.0f/180.0f * M_PI;
                
                CGFloat tf = tanf(af);
                if ((y/x) <= tf) {
                    return YES;
                }
                return NO;
            }else{
                return NO;
            }
        }
        
    }
    
    return YES;
}


@end
