//
//  GPSearchViewController.m
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import "GPSearchViewController.h"
#import "GPSearchConst.h"
#import "GPSearchSuggestionViewController.h"

#define GPRectangleTagMaxCol 3
#define GPTextColor GPSEARCH_COLOR(113, 113, 113)
#define GPSEARCH_COLORPolRandomColor self.colorPol[arc4random_uniform((uint32_t)self.colorPol.count)]

@interface GPSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, GPSearchSuggestionViewDataSource,UIGestureRecognizerDelegate>

/**
 The header view of search view
 */
@property (nonatomic, weak) UIView *headerView;

/**
 The view of popular search
 */
@property (nonatomic, weak) UIView *hotSearchView;

/**
 The view of search history
 */
@property (nonatomic, weak) UIView *searchHistoryView;

/**
 The records of search
 */
@property (nonatomic, strong) NSMutableArray *searchHistories;

/**
 Whether keyboard is showing.
 */
@property (nonatomic, assign) BOOL keyboardShowing;

/**
 The height of keyborad
 */
@property (nonatomic, assign) CGFloat keyboardHeight;

/**
 The search suggestion view contoller
 */
@property (nonatomic, weak) GPSearchSuggestionViewController *searchSuggestionVC;

/**
 The content view of popular search tags
 */
@property (nonatomic, weak) UIView *hotSearchTagsContentView;

/**
 The tags of rank
 */
@property (nonatomic, copy) NSArray<UILabel *> *rankTags;

/**
 The text labels of rank
 */
@property (nonatomic, copy) NSArray<UILabel *> *rankTextLabels;

/**
 The view of rank which contain tag and text label.
 */
@property (nonatomic, copy) NSArray<UIView *> *rankViews;

/**
 The content view of search history tags.
 */
@property (nonatomic, weak) UIView *searchHistoryTagsContentView;

/**
 The base table view  of search view controller
 */
@property (nonatomic, strong) UITableView *baseSearchTableView;

/**
 Whether did press suggestion cell
 */
@property (nonatomic, assign) BOOL didClickSuggestionCell;

/**
 The current orientation of device
 */
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;

@end

@implementation GPSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSlideRightToBack];

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (self.currentOrientation != [[UIDevice currentDevice] orientation]) { // orientation changed, reload layout
        self.hotSearches = self.hotSearches;
        self.searchHistories = self.searchHistories;
        self.currentOrientation = [[UIDevice currentDevice] orientation];
    }
    
    UIButton *cancelButton = self.navigationItem.rightBarButtonItem.customView;
    [cancelButton sizeToFit];
    cancelButton.gp_width += 5;
    // Adapt the search bar layout problem in the navigation bar on iOS 11
    // More details : https://github.com/iphone5solo/GPSearch/issues/108
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) { // iOS 11
        _searchBar.gp_width = self.view.gp_width - cancelButton.gp_width - GPSEARCH_MARGIN * 3 - 8;
        _searchBar.gp_height = self.view.gp_width > self.view.gp_height ? 24 : 30;
        _searchTextField.frame = _searchBar.bounds;
    } else {
        UIView *titleView = self.navigationItem.titleView;
        titleView.gp_x = GPSEARCH_MARGIN * 1.5;
        titleView.gp_y = self.view.gp_width > self.view.gp_height ? 3 : 7;
        titleView.gp_width = self.view.gp_width - cancelButton.gp_width - titleView.gp_x * 2 - 3;
        titleView.gp_height = self.view.gp_width > self.view.gp_height ? 24 : 30;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Adjust the view according to the `navigationBar.translucent`
    if (NO == self.navigationController.navigationBar.translucent) {
        self.baseSearchTableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.gp_y, 0);
        self.searchSuggestionVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) - self.view.gp_y, self.view.gp_width, self.view.gp_height + self.view.gp_y);
        if (!self.navigationController.navigationBar.barTintColor) {
            self.navigationController.navigationBar.barTintColor = GPSEARCH_COLOR(249, 249, 249);
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchBar resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder
{
    GPSearchViewController *searchVC = [[GPSearchViewController alloc] init];
    searchVC.hotSearches = hotSearches;
    searchVC.searchBar.placeholder = placeholder;
    return searchVC;
}

+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder didSearchBlock:(GPDidSearchBlock)block
{
    GPSearchViewController *searchVC = [self searchViewControllerWithHotSearches:hotSearches searchBarPlaceholder:placeholder];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}

#pragma mark - Lazy
- (UITableView *)baseSearchTableView
{
    if (!_baseSearchTableView) {
        UITableView *baseSearchTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        baseSearchTableView.backgroundColor = [UIColor clearColor];
        baseSearchTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([baseSearchTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) { // For the adapter iPad
            baseSearchTableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        baseSearchTableView.delegate = self;
        baseSearchTableView.dataSource = self;
        [self.view addSubview:baseSearchTableView];
        _baseSearchTableView = baseSearchTableView;
    }
    return _baseSearchTableView;
}

- (GPSearchSuggestionViewController *)searchSuggestionVC
{
    if (!_searchSuggestionVC) {
        GPSearchSuggestionViewController *searchSuggestionVC = [[GPSearchSuggestionViewController alloc] initWithStyle:UITableViewStyleGrouped];
        __weak typeof(self) _weakSelf = self;
        searchSuggestionVC.didSelectCellBlock = ^(UITableViewCell *didSelectCell) {
            __strong typeof(_weakSelf) _swSelf = _weakSelf;
            _swSelf.searchBar.text = didSelectCell.textLabel.text;
            NSIndexPath *indexPath = [_swSelf.searchSuggestionVC.tableView indexPathForCell:didSelectCell];
            
            if ([_swSelf.delegate respondsToSelector:@selector(searchViewController:didSelectSearchSuggestionAtIndexPath:searchBar:)]) {
                [_swSelf.delegate searchViewController:_swSelf didSelectSearchSuggestionAtIndexPath:indexPath searchBar:_swSelf.searchBar];
                [_swSelf saveSearchCacheAndRefreshView];
            } else if ([_swSelf.delegate respondsToSelector:@selector(searchViewController:didSelectSearchSuggestionAtIndex:searchText:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [_swSelf.delegate searchViewController:_swSelf didSelectSearchSuggestionAtIndex:indexPath.row searchText:_swSelf.searchBar.text];
#pragma clang diagnostic pop
                [_swSelf saveSearchCacheAndRefreshView];
            } else {
                [_swSelf searchBarSearchButtonClicked:_swSelf.searchBar];
            }
        };
        searchSuggestionVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), GPScreenW, GPScreenH);
        searchSuggestionVC.view.backgroundColor = self.baseSearchTableView.backgroundColor;
        searchSuggestionVC.view.hidden = YES;
        _searchSuggestionView = (UITableView *)searchSuggestionVC.view;
        searchSuggestionVC.dataSource = self;
        [self.view addSubview:searchSuggestionVC.view];
        [self addChildViewController:searchSuggestionVC];
        _searchSuggestionVC = searchSuggestionVC;
    }
    return _searchSuggestionVC;
}

- (UIButton *)emptyButton
{
    if (!_emptyButton) {
        UIButton *emptyButton = [[UIButton alloc] init];
        emptyButton.titleLabel.font = self.searchHistoryHeader.font;
        [emptyButton setTitleColor:GPTextColor forState:UIControlStateNormal];
        [emptyButton setTitle:GPSearchEmptyButtonText forState:UIControlStateNormal];
        [emptyButton setImage:[UIImage imageNamed:@"empty"] forState:UIControlStateNormal];
        [emptyButton addTarget:self action:@selector(emptySearchHistoryDidClick) forControlEvents:UIControlEventTouchUpInside];
        [emptyButton sizeToFit];
        emptyButton.gp_width += GPSEARCH_MARGIN;
        emptyButton.gp_height += GPSEARCH_MARGIN;
        emptyButton.gp_centerY = self.searchHistoryHeader.gp_centerY;
        emptyButton.gp_x = self.searchHistoryView.gp_width - emptyButton.gp_width;
        emptyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.searchHistoryView addSubview:emptyButton];
        _emptyButton = emptyButton;
    }
    return _emptyButton;
}

- (UIView *)searchHistoryTagsContentView
{
    if (!_searchHistoryTagsContentView) {
        UIView *searchHistoryTagsContentView = [[UIView alloc] init];
        searchHistoryTagsContentView.gp_width = self.searchHistoryView.gp_width;
        searchHistoryTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        searchHistoryTagsContentView.gp_y = CGRectGetMaxY(self.hotSearchTagsContentView.frame) + GPSEARCH_MARGIN;
        [self.searchHistoryView addSubview:searchHistoryTagsContentView];
        _searchHistoryTagsContentView = searchHistoryTagsContentView;
    }
    return _searchHistoryTagsContentView;
}

- (UILabel *)searchHistoryHeader
{
    if (!_searchHistoryHeader) {
        UILabel *HistoryTitleLabel = [self setupTitleLabel:GPSearchSearchHistoryText];
        _searchHistoryHeader = HistoryTitleLabel;
        [self.searchHistoryView addSubview:HistoryTitleLabel];

    }
    return _searchHistoryHeader;
}

- (UIView *)searchHistoryView
{
    if (!_searchHistoryView) {
        UIView *searchHistoryView = [[UIView alloc] init];
        searchHistoryView.gp_x = self.hotSearchView.gp_x;
        searchHistoryView.gp_y = self.hotSearchView.gp_y;
        searchHistoryView.gp_width = self.headerView.gp_width - searchHistoryView.gp_x * 2;
        searchHistoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.headerView addSubview:searchHistoryView];
        _searchHistoryView = searchHistoryView;
    }
    return _searchHistoryView;
}

- (NSMutableArray *)searchHistories
{
    if (!_searchHistories) {
        _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
    }
    return _searchHistories;
}

- (NSMutableArray *)colorPol
{
    if (!_colorPol) {
        NSArray *colorStrPol = @[@"009999", @"0099cc", @"0099ff", @"00cc99", @"00cccc", @"336699", @"3366cc", @"3366ff", @"339966", @"666666", @"666699", @"6666cc", @"6666ff", @"996666", @"996699", @"999900", @"999933", @"99cc00", @"99cc33", @"660066", @"669933", @"990066", @"cc9900", @"cc6600" , @"cc3300", @"cc3366", @"cc6666", @"cc6699", @"cc0066", @"cc0033", @"ffcc00", @"ffcc33", @"ff9900", @"ff9933", @"ff6600", @"ff6633", @"ff6666", @"ff6699", @"ff3366", @"ff3333"];
        NSMutableArray *colorPolM = [NSMutableArray array];
        for (NSString *colorStr in colorStrPol) {
            UIColor *color = [UIColor gp_colorWithHexString:colorStr];
            [colorPolM addObject:color];
        }
        _colorPol = colorPolM;
    }
    return _colorPol;
}

- (UIBarButtonItem *)cancelButton
{
    return self.navigationItem.rightBarButtonItem;
}


- (void)setup
{

 
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseSearchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.backIndicatorImage = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0];
    [cancleButton setTitle:GPSearchCancelButtonText forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancelDidClick)  forControlEvents:UIControlEventTouchUpInside];
    [cancleButton sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancleButton];
    /**
     * Initialize settings
     */
    self.hotSearchStyle = GPHotSearchStyleDefault;
    self.searchHistoryStyle = GPHotSearchStyleDefault;
    self.searchResultShowMode = GPSearchResultShowModeDefault;
    self.searchSuggestionHidden = NO;
    self.searchHistoriesCachePath = GPSEARCH_SEARCH_HISTORY_CACHE_PATH;
    self.searchHistoriesCount = 20;
    self.showSearchHistory = YES;
    self.showHotSearch = YES;
    self.showSearchResultWhenSearchTextChanged = NO;
    self.showSearchResultWhenSearchBarRefocused = NO;
    self.removeSpaceOnSearchString = YES;
    
    UIView *titleView = [[UIView alloc] init];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:titleView.bounds];
    [titleView addSubview:searchBar];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) { // iOS 11
        [NSLayoutConstraint activateConstraints:@[
                                                  [searchBar.topAnchor constraintEqualToAnchor:titleView.topAnchor],
                                                  [searchBar.leftAnchor constraintEqualToAnchor:titleView.leftAnchor],
                                                  [searchBar.rightAnchor constraintEqualToAnchor:titleView.rightAnchor constant:-GPSEARCH_MARGIN],
                                                  [searchBar.bottomAnchor constraintEqualToAnchor:titleView.bottomAnchor]
                                                  ]];
    } else {
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.navigationItem.titleView = titleView;
    searchBar.placeholder = @"搜索商品";
    searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    searchBar.layer.borderWidth = 0.5;
    searchBar.backgroundImage = [UIImage imageNamed:@"clearImage"];
    searchBar.delegate = self;
    for (UIView *subView in [[searchBar.subviews lastObject] subviews]) {
        if ([[subView class] isSubclassOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subView;
            textField.font = [UIFont systemFontOfSize:16];
            _searchTextField = textField;
            break;
        }
    }
    self.searchBar = searchBar;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.gp_width = GPScreenW;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *hotSearchView = [[UIView alloc] init];
    hotSearchView.gp_x = GPSEARCH_MARGIN * 1.5;
    hotSearchView.gp_width = headerView.gp_width - hotSearchView.gp_x * 2;
    hotSearchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *titleLabel = [self setupTitleLabel:GPSearchHotSearchText];
    self.hotSearchHeader = titleLabel;
    self.hotSearchHeader.gp_y = -GPSEARCH_MARGIN * 1.5;
    [hotSearchView addSubview:titleLabel];
    UIView *hotSearchTagsContentView = [[UIView alloc] init];
    hotSearchTagsContentView.gp_width = hotSearchView.gp_width;
    hotSearchTagsContentView.gp_y = CGRectGetMaxY(titleLabel.frame) + GPSEARCH_MARGIN;
    hotSearchTagsContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [hotSearchView addSubview:hotSearchTagsContentView];
    [headerView addSubview:hotSearchView];
    self.hotSearchTagsContentView = hotSearchTagsContentView;
    self.hotSearchView = hotSearchView;
    self.headerView = headerView;
    self.baseSearchTableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.gp_width = GPScreenW;
    UILabel *emptySearchHistoryLabel = [[UILabel alloc] init];
    emptySearchHistoryLabel.textColor = [UIColor darkGrayColor];
    emptySearchHistoryLabel.font = [UIFont systemFontOfSize:13];
    emptySearchHistoryLabel.userInteractionEnabled = YES;
    emptySearchHistoryLabel.text = GPSearchEmptySearchHistoryText;
    emptySearchHistoryLabel.textAlignment = NSTextAlignmentCenter;
    emptySearchHistoryLabel.gp_height = 49;
    [emptySearchHistoryLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptySearchHistoryDidClick)]];
    emptySearchHistoryLabel.gp_width = footerView.gp_width;
    emptySearchHistoryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.emptySearchHistoryLabel = emptySearchHistoryLabel;
    [footerView addSubview:emptySearchHistoryLabel];
    footerView.gp_height = emptySearchHistoryLabel.gp_height;
    self.baseSearchTableView.tableFooterView = footerView;
    
    self.hotSearches = nil;
}

- (UILabel *)setupTitleLabel:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15, 0, GPSEARCH_REALY_SCREEN_WIDTH - 30, 30)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13.0];
    titleLabel.tag = 1;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.gp_x = 0;
    titleLabel.gp_y = 0;
    return titleLabel;
}

- (void)setupHotSearchRectangleTags
{
    UIView *contentView = self.hotSearchTagsContentView;
    contentView.gp_width = GPSEARCH_REALY_SCREEN_WIDTH;
    contentView.gp_x = -GPSEARCH_MARGIN * 1.5;
    contentView.gp_y += 2;
    contentView.backgroundColor = [UIColor whiteColor];
    self.baseSearchTableView.backgroundColor = [UIColor gp_colorWithHexString:@"#efefef"];
    // remove all subviews in hotSearchTagsContentView
    [self.hotSearchTagsContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
    CGFloat rectangleTagH = 40;
    for (int i = 0; i < self.hotSearches.count; i++) {
        UILabel *rectangleTagLabel = [[UILabel alloc] init];
        rectangleTagLabel.userInteractionEnabled = YES;
        rectangleTagLabel.font = [UIFont systemFontOfSize:14];
        rectangleTagLabel.textColor = GPTextColor;
        rectangleTagLabel.backgroundColor = [UIColor clearColor];
        rectangleTagLabel.text = self.hotSearches[i];
        rectangleTagLabel.gp_width = contentView.gp_width / GPRectangleTagMaxCol;
        rectangleTagLabel.gp_height = rectangleTagH;
        rectangleTagLabel.textAlignment = NSTextAlignmentCenter;
        [rectangleTagLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        rectangleTagLabel.gp_x = rectangleTagLabel.gp_width * (i % GPRectangleTagMaxCol);
        rectangleTagLabel.gp_y = rectangleTagLabel.gp_height * (i / GPRectangleTagMaxCol);
        [contentView addSubview:rectangleTagLabel];
    }
    contentView.gp_height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    
    self.hotSearchView.gp_height = CGRectGetMaxY(contentView.frame) + GPSEARCH_MARGIN * 2;
    self.baseSearchTableView.tableHeaderView.gp_height = self.headerView.gp_height = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.searchHistoryView.frame));
    
    for (int i = 0; i < GPRectangleTagMaxCol - 1; i++) {
        UIImageView *verticalLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-content-line-vertical"]];
        verticalLine.gp_height = contentView.gp_height;
        verticalLine.alpha = 0.7;
        verticalLine.gp_x = contentView.gp_width / GPRectangleTagMaxCol * (i + 1);
        verticalLine.gp_width = 0.5;
        [contentView addSubview:verticalLine];
    }
    
    for (int i = 0; i < ceil(((double)self.hotSearches.count / GPRectangleTagMaxCol)) - 1; i++) {
        UIImageView *verticalLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-content-line"]];
        verticalLine.gp_height = 0.5;
        verticalLine.alpha = 0.7;
        verticalLine.gp_y = rectangleTagH * (i + 1);
        verticalLine.gp_width = contentView.gp_width;
        [contentView addSubview:verticalLine];
    }
    [self layoutForDemand];
    // Note：When the operating system for the iOS 9.x series tableHeaderView height settings are invalid, you need to reset the tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
}

- (void)setupHotSearchRankTags
{
    UIView *contentView = self.hotSearchTagsContentView;
    [self.hotSearchTagsContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *rankTextLabelsM = [NSMutableArray array];
    NSMutableArray *rankTagM = [NSMutableArray array];
    NSMutableArray *rankViewM = [NSMutableArray array];
    for (int i = 0; i < self.hotSearches.count; i++) {
        UIView *rankView = [[UIView alloc] init];
        rankView.gp_height = 40;
        rankView.gp_width = (self.baseSearchTableView.gp_width - GPSEARCH_MARGIN * 3) * 0.5;
        rankView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [contentView addSubview:rankView];
        // rank tag
        UILabel *rankTag = [[UILabel alloc] init];
        rankTag.textAlignment = NSTextAlignmentCenter;
        rankTag.font = [UIFont systemFontOfSize:10];
        rankTag.layer.cornerRadius = 3;
        rankTag.clipsToBounds = YES;
        rankTag.text = [NSString stringWithFormat:@"%d", i + 1];
        [rankTag sizeToFit];
        rankTag.gp_width = rankTag.gp_height += GPSEARCH_MARGIN * 0.5;
        rankTag.gp_y = (rankView.gp_height - rankTag.gp_height) * 0.5;
        [rankView addSubview:rankTag];
        [rankTagM addObject:rankTag];
        // rank text
        UILabel *rankTextLabel = [[UILabel alloc] init];
        rankTextLabel.text = self.hotSearches[i];
        rankTextLabel.userInteractionEnabled = YES;
        [rankTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        rankTextLabel.textAlignment = NSTextAlignmentLeft;
        rankTextLabel.backgroundColor = [UIColor clearColor];
        rankTextLabel.textColor = GPTextColor;
        rankTextLabel.font = [UIFont systemFontOfSize:14];
        rankTextLabel.gp_x = CGRectGetMaxX(rankTag.frame) + GPSEARCH_MARGIN;
        rankTextLabel.gp_width = (self.baseSearchTableView.gp_width - GPSEARCH_MARGIN * 3) * 0.5 - rankTextLabel.gp_x;
        rankTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        rankTextLabel.gp_height = rankView.gp_height;
        [rankTextLabelsM addObject:rankTextLabel];
        [rankView addSubview:rankTextLabel];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-content-line"]];
        line.gp_height = 0.5;
        line.alpha = 0.7;
        line.gp_x = -GPScreenW * 0.5;
        line.gp_y = rankView.gp_height - 1;
        line.gp_width = self.baseSearchTableView.gp_width;
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [rankView addSubview:line];
        [rankViewM addObject:rankView];
        
        // set tag's background color and text color
        switch (i) {
            case 0: // NO.1
                rankTag.backgroundColor = [UIColor gp_colorWithHexString:self.rankTagBackgroundColorHexStrings[0]];
                rankTag.textColor = [UIColor whiteColor];
                break;
            case 1: // NO.2
                rankTag.backgroundColor = [UIColor gp_colorWithHexString:self.rankTagBackgroundColorHexStrings[1]];
                rankTag.textColor = [UIColor whiteColor];
                break;
            case 2: // NO.3
                rankTag.backgroundColor = [UIColor gp_colorWithHexString:self.rankTagBackgroundColorHexStrings[2]];
                rankTag.textColor = [UIColor whiteColor];
                break;
            default: // Other
                rankTag.backgroundColor = [UIColor gp_colorWithHexString:self.rankTagBackgroundColorHexStrings[3]];
                rankTag.textColor = GPTextColor;
                break;
        }
    }
    self.rankTextLabels = rankTextLabelsM;
    self.rankTags = rankTagM;
    self.rankViews = rankViewM;
    
    for (int i = 0; i < self.rankViews.count; i++) { // default is two column
        UIView *rankView = self.rankViews[i];
        rankView.gp_x = (GPSEARCH_MARGIN + rankView.gp_width) * (i % 2);
        rankView.gp_y = rankView.gp_height * (i / 2);
    }
    
    contentView.gp_height = CGRectGetMaxY(self.rankViews.lastObject.frame);
    self.hotSearchView.gp_height = CGRectGetMaxY(contentView.frame) + GPSEARCH_MARGIN * 2;
    self.baseSearchTableView.tableHeaderView.gp_height = self.headerView.gp_height = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.searchHistoryView.frame));
    [self layoutForDemand];
    
    // Note：When the operating system for the iOS 9.x series tableHeaderView height settings are invalid, you need to reset the tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
}

- (void)setupHotSearchNormalTags
{
    self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotSearchTagsContentView tagTexts:self.hotSearches];
    [self setHotSearchStyle:self.hotSearchStyle];
}

- (void)setupSearchHistoryTags
{
    self.baseSearchTableView.tableFooterView = nil;
    self.searchHistoryTagsContentView.gp_y = GPSEARCH_MARGIN;
    self.emptyButton.gp_y = self.searchHistoryHeader.gp_y - GPSEARCH_MARGIN * 0.5;
    self.searchHistoryTagsContentView.gp_y = CGRectGetMaxY(self.emptyButton.frame) + GPSEARCH_MARGIN;
    self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:[self.searchHistories copy]];
}

- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<NSString *> *)tagTexts;
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UILabel *label = [self labelWithTitle:tagTexts[i]];
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        [contentView addSubview:label];
        [tagsM addObject:label];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    for (int i = 0; i < contentView.subviews.count; i++) {
        UILabel *subView = contentView.subviews[i];
        // When the number of search words is too large, the width is width of the contentView
        if (subView.gp_width > contentView.gp_width) subView.gp_width = contentView.gp_width;
        if (currentX + subView.gp_width + GPSEARCH_MARGIN * countRow > contentView.gp_width) {
            subView.gp_x = 0;
            subView.gp_y = (currentY += subView.gp_height) + GPSEARCH_MARGIN * ++countCol;
            currentX = subView.gp_width;
            countRow = 1;
        } else {
            subView.gp_x = (currentX += subView.gp_width) - subView.gp_width + GPSEARCH_MARGIN * countRow;
            subView.gp_y = currentY + GPSEARCH_MARGIN * countCol;
            countRow ++;
        }
    }
    
    contentView.gp_height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    if (self.hotSearchTagsContentView == contentView) { // popular search tag
        self.hotSearchView.gp_height = CGRectGetMaxY(contentView.frame) + GPSEARCH_MARGIN * 2;
    } else if (self.searchHistoryTagsContentView == contentView) { // search history tag
        self.searchHistoryView.gp_height = CGRectGetMaxY(contentView.frame) + GPSEARCH_MARGIN * 2;
    }
    
    [self layoutForDemand];
    self.baseSearchTableView.tableHeaderView.gp_height = self.headerView.gp_height = MAX(CGRectGetMaxY(self.hotSearchView.frame), CGRectGetMaxY(self.searchHistoryView.frame));
    self.baseSearchTableView.tableHeaderView.hidden = NO;
    
    // Note：When the operating system for the iOS 9.x series tableHeaderView height settings are invalid, you need to reset the tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
    return [tagsM copy];
}

- (void)layoutForDemand {
    if (NO == self.swapHotSeachWithSearchHistory) {
        self.hotSearchView.gp_y = GPSEARCH_MARGIN * 2;
        self.searchHistoryView.gp_y = self.hotSearches.count > 0 && self.showHotSearch ? CGRectGetMaxY(self.hotSearchView.frame) : GPSEARCH_MARGIN * 1.5;
    } else { // swap popular search whith search history
        self.searchHistoryView.gp_y = GPSEARCH_MARGIN * 1.5;
        self.hotSearchView.gp_y = self.searchHistories.count > 0 && self.showSearchHistory ? CGRectGetMaxY(self.searchHistoryView.frame) : GPSEARCH_MARGIN * 2;
    }
}

#pragma mark - setter
- (void)setSwapHotSeachWithSearchHistory:(BOOL)swapHotSeachWithSearchHistory
{
    _swapHotSeachWithSearchHistory = swapHotSeachWithSearchHistory;
    
    self.hotSearches = self.hotSearches;
    self.searchHistories = self.searchHistories;
}

- (void)setHotSearchTitle:(NSString *)hotSearchTitle
{
    _hotSearchTitle = [hotSearchTitle copy];
    
    self.hotSearchHeader.text = _hotSearchTitle;
}

- (void)setSearchHistoryTitle:(NSString *)searchHistoryTitle
{
    _searchHistoryTitle = [searchHistoryTitle copy];
    
    if (GPSearchHistoryStyleCell == self.searchHistoryStyle) {
        [self.baseSearchTableView reloadData];
    } else {
        self.searchHistoryHeader.text = _searchHistoryTitle;
    }
}

- (void)setShowSearchResultWhenSearchTextChanged:(BOOL)showSearchResultWhenSearchTextChanged
{
    _showSearchResultWhenSearchTextChanged = showSearchResultWhenSearchTextChanged;
    
    if (YES == _showSearchResultWhenSearchTextChanged) {
        self.searchSuggestionHidden = YES;
    }
}

- (void)setShowHotSearch:(BOOL)showHotSearch
{
    _showHotSearch = showHotSearch;
    
    [self setHotSearches:self.hotSearches];
    [self setSearchHistoryStyle:self.searchHistoryStyle];
}

- (void)setShowSearchHistory:(BOOL)showSearchHistory
{
    _showSearchHistory = showSearchHistory;
    
    [self setHotSearches:self.hotSearches];
    [self setSearchHistoryStyle:self.searchHistoryStyle];
}

- (void)setCancelButton:(UIBarButtonItem *)cancelButton
{
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)setSearchHistoriesCachePath:(NSString *)searchHistoriesCachePath
{
    _searchHistoriesCachePath = [searchHistoriesCachePath copy];
    
    self.searchHistories = nil;
    if (GPSearchHistoryStyleCell == self.searchHistoryStyle) {
        [self.baseSearchTableView reloadData];
    } else {
        [self setSearchHistoryStyle:self.searchHistoryStyle];
    }
}

- (void)setHotSearchTags:(NSArray<UILabel *> *)hotSearchTags
{
    // popular search tagLabel's tag is 1, search history tagLabel's tag is 0.
    for (UILabel *tagLabel in hotSearchTags) {
        tagLabel.tag = 1;
    }
    _hotSearchTags = hotSearchTags;
}

- (void)setSearchBarBackgroundColor:(UIColor *)searchBarBackgroundColor
{
    _searchBarBackgroundColor = searchBarBackgroundColor;
    _searchTextField.backgroundColor = searchBarBackgroundColor;
}

- (void)setSearchSuggestions:(NSArray<NSString *> *)searchSuggestions
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:cellForRowAtIndexPath:)]) {
        // set searchSuggestion is nil when cell of suggestion view is custom.
        _searchSuggestions = nil;
        return;
    }
    
    _searchSuggestions = [searchSuggestions copy];
    self.searchSuggestionVC.searchSuggestions = [searchSuggestions copy];
    
    self.baseSearchTableView.hidden = !self.searchSuggestionHidden && [self.searchSuggestionVC.tableView numberOfRowsInSection:0];
    self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || ![self.searchSuggestionVC.tableView numberOfRowsInSection:0];
}

- (void)setRankTagBackgroundColorHexStrings:(NSArray<NSString *> *)rankTagBackgroundColorHexStrings
{
    if (rankTagBackgroundColorHexStrings.count < 4) {
        NSArray *colorStrings = @[@"#f14230", @"#ff8000", @"#ffcc01", @"#ebebeb"];
        _rankTagBackgroundColorHexStrings = colorStrings;
    } else {
        _rankTagBackgroundColorHexStrings = @[rankTagBackgroundColorHexStrings[0], rankTagBackgroundColorHexStrings[1], rankTagBackgroundColorHexStrings[2], rankTagBackgroundColorHexStrings[3]];
    }
    
    self.hotSearches = self.hotSearches;
}

- (void)setHotSearches:(NSArray *)hotSearches
{
    _hotSearches = hotSearches;
    if (0 == hotSearches.count || !self.showHotSearch) {
        self.hotSearchHeader.hidden = YES;
        self.hotSearchTagsContentView.hidden = YES;
        if (GPSearchHistoryStyleCell == self.searchHistoryStyle) {
            UIView *tableHeaderView = self.baseSearchTableView.tableHeaderView;
            tableHeaderView.gp_height = GPSEARCH_MARGIN * 1.5;
            [self.baseSearchTableView setTableHeaderView:tableHeaderView];
        }
        return;
    };
    
    self.baseSearchTableView.tableHeaderView.hidden = NO;
    self.hotSearchHeader.hidden = NO;
    self.hotSearchTagsContentView.hidden = NO;
    if (GPHotSearchStyleDefault == self.hotSearchStyle
        || GPHotSearchStyleColorfulTag == self.hotSearchStyle
        || GPHotSearchStyleBorderTag == self.hotSearchStyle
        || GPHotSearchStyleARCBorderTag == self.hotSearchStyle) {
        [self setupHotSearchNormalTags];
    } else if (GPHotSearchStyleRankTag == self.hotSearchStyle) {
        [self setupHotSearchRankTags];
    } else if (GPHotSearchStyleRectangleTag == self.hotSearchStyle) {
        [self setupHotSearchRectangleTags];
    }
    [self setSearchHistoryStyle:self.searchHistoryStyle];
}

- (void)setSearchHistoryStyle:(GPSearchHistoryStyle)searchHistoryStyle
{
    _searchHistoryStyle = searchHistoryStyle;
    
    if (!self.searchHistories.count || !self.showSearchHistory || UISearchBarStyleDefault == searchHistoryStyle) {
        self.searchHistoryHeader.hidden = YES;
        self.searchHistoryTagsContentView.hidden = YES;
        self.searchHistoryView.hidden = YES;
        self.emptyButton.hidden = YES;
        return;
    };
    
    self.searchHistoryHeader.hidden = NO;
    self.searchHistoryTagsContentView.hidden = NO;
    self.searchHistoryView.hidden = NO;
    self.emptyButton.hidden = NO;
    [self setupSearchHistoryTags];
    
    switch (searchHistoryStyle) {
        case GPSearchHistoryStyleColorfulTag:
            for (UILabel *tag in self.searchHistoryTags) {
                tag.textColor = [UIColor whiteColor];
                tag.layer.borderColor = nil;
                tag.layer.borderWidth = 0.0;
                tag.backgroundColor = GPSEARCH_COLORPolRandomColor;
            }
            break;
        case GPSearchHistoryStyleBorderTag:
            for (UILabel *tag in self.searchHistoryTags) {
                tag.backgroundColor = [UIColor clearColor];
                tag.layer.borderColor = GPSEARCH_COLOR(223, 223, 223).CGColor;
                tag.layer.borderWidth = 0.5;
            }
            break;
        case GPSearchHistoryStyleARCBorderTag:
            for (UILabel *tag in self.searchHistoryTags) {
                tag.backgroundColor = [UIColor clearColor];
                tag.layer.borderColor = GPSEARCH_COLOR(223, 223, 223).CGColor;
                tag.layer.borderWidth = 0.5;
                tag.layer.cornerRadius = tag.gp_height * 0.5;
            }
            break;
        default:
            break;
    }
}

- (void)setHotSearchStyle:(GPHotSearchStyle)hotSearchStyle
{
    _hotSearchStyle = hotSearchStyle;
    
    switch (hotSearchStyle) {
        case GPHotSearchStyleColorfulTag:
            for (UILabel *tag in self.hotSearchTags) {
                tag.textColor = [UIColor whiteColor];
                tag.layer.borderColor = nil;
                tag.layer.borderWidth = 0.0;
                tag.backgroundColor = GPSEARCH_COLORPolRandomColor;
            }
            break;
        case GPHotSearchStyleBorderTag:
            for (UILabel *tag in self.hotSearchTags) {
                tag.backgroundColor = [UIColor clearColor];
                tag.layer.borderColor = GPSEARCH_COLOR(223, 223, 223).CGColor;
                tag.layer.borderWidth = 0.5;
            }
            break;
        case GPHotSearchStyleARCBorderTag:
            for (UILabel *tag in self.hotSearchTags) {
                tag.backgroundColor = [UIColor clearColor];
                tag.layer.borderColor = GPSEARCH_COLOR(223, 223, 223).CGColor;
                tag.layer.borderWidth = 0.5;
                tag.layer.cornerRadius = tag.gp_height * 0.5;
            }
            break;
        case GPHotSearchStyleRectangleTag:
            self.hotSearches = self.hotSearches;
            break;
        case GPHotSearchStyleRankTag:
            self.rankTagBackgroundColorHexStrings = nil;
            break;
            
        default:
            break;
    }
}

- (void)cancelDidClick
{
    [self.searchBar resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(didClickCancel:)]) {
        [self.delegate didClickCancel:self];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyboardDidShow:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    self.keyboardHeight = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.keyboardShowing = YES;
    // Adjust the content inset of suggestion view
    self.searchSuggestionVC.tableView.contentInset = UIEdgeInsetsMake(-30, 0, self.keyboardHeight + 30, 0);
}


- (void)emptySearchHistoryDidClick
{
    [self.searchHistories removeAllObjects];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    if (GPSearchHistoryStyleCell == self.searchHistoryStyle) {
        [self.baseSearchTableView reloadData];
    } else {
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
    if (YES == self.swapHotSeachWithSearchHistory) {
        self.hotSearches = self.hotSearches;
    }
    GPSEARCH_LOG(@"%@", GPSearchEmptySearchHistoryLogText);
}

- (void)tagDidCLick:(UITapGestureRecognizer *)gr
{
    UILabel *label = (UILabel *)gr.view;
    self.searchBar.text = label.text;
    // popular search tagLabel's tag is 1, search history tagLabel's tag is 0.
    if (1 == label.tag) {
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectHotSearchAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectHotSearchAtIndex:[self.hotSearchTags indexOfObject:label] searchText:label.text];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:[self.searchHistoryTags indexOfObject:label] searchText:label.text];
            [self saveSearchCacheAndRefreshView];
        } else {
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
    GPSEARCH_LOG(@"Search %@", label.text);
}

- (UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor gp_colorWithHexString:@"#fafafa"];
    label.layer.cornerRadius = 3;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.gp_width += 20;
    label.gp_height += 14;
    return label;
}

- (void)saveSearchCacheAndRefreshView
{
    UISearchBar *searchBar = self.searchBar;
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;
    if (self.removeSpaceOnSearchString) { // remove sapce on search string
       searchText = [searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (self.showSearchHistory && searchText.length > 0) {
        [self.searchHistories removeObject:searchText];
        [self.searchHistories insertObject:searchText atIndex:0];
        
        if (self.searchHistories.count > self.searchHistoriesCount) {
            [self.searchHistories removeLastObject];
        }
        [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
        
        if (GPSearchHistoryStyleCell == self.searchHistoryStyle) {
            [self.baseSearchTableView reloadData];
        } else {
            self.searchHistoryStyle = self.searchHistoryStyle;
        }
    }
    
    [self handleSearchResultShow];
}

- (void)handleSearchResultShow
{
    switch (self.searchResultShowMode) {
        case GPSearchResultShowModePush:
            self.searchResultController.view.hidden = NO;
            [self.navigationController pushViewController:self.searchResultController animated:YES];
            break;
        case GPSearchResultShowModeEmbed:
            if (self.searchResultController) {
                [self.view addSubview:self.searchResultController.view];
                [self addChildViewController:self.searchResultController];
                self.searchResultController.view.hidden = NO;
                self.searchResultController.view.gp_y = NO == self.navigationController.navigationBar.translucent ? 0 : CGRectGetMaxY(self.navigationController.navigationBar.frame);
                self.searchResultController.view.gp_height = self.view.gp_height - self.searchResultController.view.gp_y;
                self.searchSuggestionVC.view.hidden = YES;
            } else {
                GPSEARCH_LOG(@"GPSearchDebug： searchResultController cannot be nil when searchResultShowMode is GPSearchResultShowModeEmbed.");
            }
            break;
        case GPSearchResultShowModeCustom:
            
            break;
        default:
            break;
    }
}

#pragma mark - GPSearchSuggestionViewDataSource
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView
{
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInSearchSuggestionView:)]) {
        return [self.dataSource numberOfSectionsInSearchSuggestionView:searchSuggestionView];
    }
    return 1;
}

- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:numberOfRowsInSection:)]) {
        NSInteger numberOfRow = [self.dataSource searchSuggestionView:searchSuggestionView numberOfRowsInSection:section];
        searchSuggestionView.hidden = self.searchSuggestionHidden || !self.searchBar.text.length || 0 == numberOfRow;
        self.baseSearchTableView.hidden = !searchSuggestionView.hidden;
        return numberOfRow;
    }
    return self.searchSuggestions.count;
}

- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:cellForRowAtIndexPath:)]) {
        return [self.dataSource searchSuggestionView:searchSuggestionView cellForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:heightForRowAtIndexPath:)]) {
        return [self.dataSource searchSuggestionView:searchSuggestionView heightForRowAtIndexPath:indexPath];
    }
    return 44.0;
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchViewController:didSearchWithSearchBar:searchText:)]) {
        [self.delegate searchViewController:self didSearchWithSearchBar:searchBar searchText:searchBar.text];
        [self saveSearchCacheAndRefreshView];
        return;
    }
    if (self.didSearchBlock) self.didSearchBlock(self, searchBar, searchBar.text);
    [self saveSearchCacheAndRefreshView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (GPSearchResultShowModeEmbed == self.searchResultShowMode && self.showSearchResultWhenSearchTextChanged) {
        [self handleSearchResultShow];
        self.searchResultController.view.hidden = 0 == searchText.length;
    } else if (self.searchResultController) {
        self.searchResultController.view.hidden = YES;
    }
    self.baseSearchTableView.hidden = searchText.length && !self.searchSuggestionHidden && [self.searchSuggestionVC.tableView numberOfRowsInSection:0];
    self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || !searchText.length || ![self.searchSuggestionVC.tableView numberOfRowsInSection:0];
    if (self.searchSuggestionVC.view.hidden) {
        self.searchSuggestions = nil;
    }
    [self.view bringSubviewToFront:self.searchSuggestionVC.view];
    if ([self.delegate respondsToSelector:@selector(searchViewController:searchTextDidChange:searchText:)]) {
        [self.delegate searchViewController:self searchTextDidChange:searchBar searchText:searchText];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (GPSearchResultShowModeEmbed == self.searchResultShowMode) {
        self.searchResultController.view.hidden = 0 == searchBar.text.length || !self.showSearchResultWhenSearchBarRefocused;
        self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || !searchBar.text.length || ![self.searchSuggestionVC.tableView numberOfRowsInSection:0];
        if (self.searchSuggestionVC.view.hidden) {
            self.searchSuggestions = nil;
        }
        self.baseSearchTableView.hidden = searchBar.text.length && !self.searchSuggestionHidden && ![self.searchSuggestionVC.tableView numberOfRowsInSection:0];
    }
    [self setSearchSuggestions:self.searchSuggestions];
    return YES;
}

- (void)closeDidClick:(UIButton *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    [self.searchHistories removeObject:cell.textLabel.text];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    [self.baseSearchTableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.baseSearchTableView.tableFooterView.hidden = 0 == self.searchHistories.count || !self.showSearchHistory;
    return self.showSearchHistory && GPSearchHistoryStyleCell == self.searchHistoryStyle ? self.searchHistories.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"GPSearchHistoryCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.textColor = GPTextColor;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        
        UIButton *closetButton = [[UIButton alloc] init];
        closetButton.gp_size = CGSizeMake(cell.gp_height, cell.gp_height);
        [closetButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        UIImageView *closeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close"]];
        [closetButton addTarget:self action:@selector(closeDidClick:) forControlEvents:UIControlEventTouchUpInside];
        closeView.contentMode = UIViewContentModeCenter;
        cell.accessoryView = closetButton;
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-content-line"]];
        line.gp_height = 0.5;
        line.alpha = 0.7;
        line.gp_x = GPSEARCH_MARGIN;
        line.gp_y = 43;
        line.gp_width = tableView.gp_width;
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:line];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"search_history"];
    cell.textLabel.text = self.searchHistories[indexPath.row];
    
    return cell;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *vHeader = [UIView new];
    vHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GPSEARCH_REALY_SCREEN_WIDTH, 30)];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15,0,vHeader.gp_width -30,vHeader.gp_height)];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.font = [UIFont systemFontOfSize:13.0];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.text = self.showSearchHistory && self.searchHistories.count && GPSearchHistoryStyleCell == self.searchHistoryStyle ? (self.searchHistoryTitle.length ? self.searchHistoryTitle : GPSearchSearchHistoryText) : nil;
    [vHeader addSubview:labelTitle];
    return vHeader;

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.searchHistories.count && self.showSearchHistory && GPSearchHistoryStyleCell == self.searchHistoryStyle ? 25 : 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchBar.text = cell.textLabel.text;
        
    if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
        [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:indexPath.row searchText:cell.textLabel.text];
        [self saveSearchCacheAndRefreshView];
    } else {
        [self searchBarSearchButtonClicked:self.searchBar];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.keyboardShowing) {
        // Adjust the content inset of suggestion view
        self.searchSuggestionVC.tableView.contentInset = UIEdgeInsetsMake(-30, 0, 30, 0);
        [self.searchBar resignFirstResponder];
    }
}


@end
