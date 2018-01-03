//
//  GPSearchVC.m
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import "GPSearchStyleListVC.h"
#import "GPSearchVC.h"
#import "SearchResultVC.h"

@interface GPSearchStyleListVC () <GPSearchViewControllerDelegate>

@end

@implementation GPSearchStyleListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    // set title
    self.title = @"GPSearch Example";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) { // Adjust for iPad
        if (@available(iOS 9.0, *)) {
            self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? 5 : 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (0 == indexPath.section) {
        cell.textLabel.text = @[@"GPHotSearchStyleDefault", @"GPHotSearchStyleColorfulTag", @"GPHotSearchStyleBorderTag", @"GPHotSearchStyleARCBorderTag", @"GPHotSearchStyleRankTag", @"GPHotSearchStyleRectangleTag"][indexPath.row];
    } else {
        cell.textLabel.text = @[@"GPSearchHistoryStyleDefault", @"GPSearchHistoryStyleNormalTag", @"GPSearchHistoryStyleColorfulTag", @"GPSearchHistoryStyleBorderTag", @"GPSearchHistoryStyleARCBorderTag"][indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. Create an Array of popular search
    NSArray *hotSeaches = @[@"Java", @"GPthon", @"Objective-C", @"Swift", @"C", @"C++", @"PHP", @"C#", @"Perl", @"Go", @"JavaScript", @"R", @"Ruby", @"MATLAB"];
    // 2. Create a search view controller
    GPSearchVC *searchViewController = [GPSearchVC searchViewControllerWithHotSearches:hotSeaches searchBarPlaceholder:NSLocalizedString(@"GPExampleSearchPlaceholderText", @"搜索编程语言") didSearchBlock:^(GPSearchVC *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        // Called when search begain.
        // eg：Push to a temp view controller
        NSLog(@"-----------------------#4444444444---------------%@",searchText);

        [searchViewController.navigationController pushViewController:[[SearchResultVC alloc] init] animated:YES];
    }];
    // 3. Set style for popular search and search history
    if (0 == indexPath.section) {
        searchViewController.hotSearchStyle = (NSInteger)indexPath.row;
        searchViewController.searchHistoryStyle = GPHotSearchStyleDefault;
    } else {
        searchViewController.hotSearchStyle = GPHotSearchStyleDefault;
        searchViewController.searchHistoryStyle = (NSInteger)indexPath.row;
    }
    // 4. Set delegate
    searchViewController.delegate = self;
    // 5. Present a navigation controller
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
//    [self presentViewController:nav animated:YES completion:nil];
    searchViewController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section ? NSLocalizedString(@"GPExampleTableSectionZeroTitle", @"选择搜索历史风格（热门搜索为默认风格)") : NSLocalizedString(@"GPExampleTableSectionZeroTitle", @"选择热门搜索风格（搜索历史为默认风格)");
}

#pragma mark - GPSearchViewControllerDelegate
- (void)searchViewController:(GPSearchVC *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText
{
    if (searchText.length) {
        // Simulate a send request to get a search suggestions
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableArray *searchSuggestionsM = [NSMutableArray array];
            for (int i = 0; i < arc4random_uniform(5) + 10; i++) {
                NSString *searchSuggestion = [NSString stringWithFormat:@"Search Advice %d", i];
                [searchSuggestionsM addObject:searchSuggestion];
            }
            // Refresh and display the search suggustions
            searchViewController.searchSuggestions = searchSuggestionsM;
        });
    }
}

//搜索历史
- (void)searchViewController:(GPSearchVC *)searchViewController
didSelectSearchHistoryAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText{
    
    NSLog(@"-----------------------111111111----------%ld-----%@",index,searchText);
    [searchViewController.navigationController pushViewController:[[SearchResultVC alloc] init] animated:YES];

}
//热门搜索
- (void)searchViewController:(GPSearchVC *)searchViewController
   didSelectHotSearchAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText{
    NSLog(@"-----------------------2222222222----------%ld-----%@",index,searchText);
    [searchViewController.navigationController pushViewController:[[SearchResultVC alloc] init] animated:YES];

}
//搜索框搜索
- (void)searchViewController:(GPSearchVC *)searchViewController
      didSearchWithSearchBar:(UISearchBar *)searchBar
                  searchText:(NSString *)searchText{
    NSLog(@"-----------------------#3333333333---------------%@",searchText);
    [searchViewController.navigationController pushViewController:[[SearchResultVC alloc] init] animated:YES];

    
}

@end



