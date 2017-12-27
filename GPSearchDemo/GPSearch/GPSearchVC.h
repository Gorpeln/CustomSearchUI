//
//  GPSearchVC.h
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPSearchConst.h"

@class GPSearchVC, GPSearchAdviceVC;

typedef void(^GPDidSearchBlock)(GPSearchVC *searchViewController, UISearchBar *searchBar, NSString *searchText);

/**
 style of popular search
 */
typedef NS_ENUM(NSInteger, GPHotSearchStyle)  {
    GPHotSearchStyleNormalTag,      // normal tag without border
    GPHotSearchStyleColorfulTag,    // colorful tag without border, color of background is randrom and can be custom by `colorPol`
    GPHotSearchStyleBorderTag,      // border tag, color of background is `clearColor`
    GPHotSearchStyleARCBorderTag,   // broder tag with ARC, color of background is `clearColor`
    GPHotSearchStyleRankTag,        // rank tag, color of background can be custom by `rankTagBackgroundColorHexStrings`
    GPHotSearchStyleRectangleTag,   // rectangle tag, color of background is `clearColor`
    GPHotSearchStyleDefault = GPHotSearchStyleNormalTag // default is `GPHotSearchStyleNormalTag`
};

/**
 style of search history
 */
typedef NS_ENUM(NSInteger, GPSearchHistoryStyle) {
    GPSearchHistoryStyleCell,           // style of UITableViewCell
    GPSearchHistoryStyleNormalTag,      // style of GPHotSearchStyleNormalTag
    GPSearchHistoryStyleColorfulTag,    // style of GPHotSearchStyleColorfulTag
    GPSearchHistoryStyleBorderTag,      // style of GPHotSearchStyleBorderTag
    GPSearchHistoryStyleARCBorderTag,   // style of GPHotSearchStyleARCBorderTag
    GPSearchHistoryStyleDefault = GPSearchHistoryStyleCell // default is `GPSearchHistoryStyleCell`
};

/**
 mode of search result view controller display
 */
typedef NS_ENUM(NSInteger, GPSearchResultShowMode) {
    GPSearchResultShowModeCustom,   // custom, can be push or pop and so on.
    GPSearchResultShowModePush,     // push, dispaly the view of search result by push
    GPSearchResultShowModeEmbed,    // embed, dispaly the view of search result by embed
    GPSearchResultShowModeDefault = GPSearchResultShowModeCustom // defualt is `GPSearchResultShowModeCustom`
};

/**
 The protocol of data source, you can custom the Advice view by implement these methods the data scource.
 */
@protocol GPSearchViewControllerDataSource <NSObject>

@optional

/**
 Return a `UITableViewCell` object.

 @param searchAdviceView    view which display search Advices
 @param indexPath               indexPath of row
 @return a `UITableViewCell` object
 */
- (UITableViewCell *)searchAdviceView:(UITableView *)searchAdviceView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Return number of rows in section.

 @param searchAdviceView    view which display search Advices
 @param section                 index of section
 @return number of rows in section
 */
- (NSInteger)searchAdviceView:(UITableView *)searchAdviceView numberOfRowsInSection:(NSInteger)section;

/**
 Return number of sections in search Advice view.

 @param searchAdviceView    view which display search Advices
 @return number of sections
 */
- (NSInteger)numberOfSectionsInSearchAdviceView:(UITableView *)searchAdviceView;

/**
 Return height for row.

 @param searchAdviceView    view which display search Advices
 @param indexPath               indexPath of row
 @return height of row
 */
- (CGFloat)searchAdviceView:(UITableView *)searchAdviceView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


/**
 The protocol of delegate
 */
@protocol GPSearchVCDelegate <NSObject, UITableViewDelegate>

@optional

/**
 Called when search begain.

 @param searchViewController    search view controller
 @param searchBar               search bar
 @param searchText              text for search
 */
- (void)searchViewController:(GPSearchVC *)searchViewController
      didSearchWithSearchBar:(UISearchBar *)searchBar
                  searchText:(NSString *)searchText;

/**
 Called when popular search is selected.

 @param searchViewController    search view controller
 @param index                   index of tag
 @param searchText              text for search
 
 Note: `searchViewController:didSearchWithSearchBar:searchText:` will not be called when this method is implemented.
 */
- (void)searchViewController:(GPSearchVC *)searchViewController
   didSelectHotSearchAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText;

/**
 Called when search history is selected.

 @param searchViewController    search view controller
 @param index                   index of tag or row
 @param searchText              text for search
 
 Note: `searchViewController:didSearchWithSearchBar:searchText:` will not be called when this method is implemented.
 */
- (void)searchViewController:(GPSearchVC *)searchViewController
didSelectSearchHistoryAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText;

/**
 Called when search Advice is selected.

 @param searchViewController    search view controller
 @param index                   index of row
 @param searchText              text for search

 Note: `searchViewController:didSearchWithSearchBar:searchText:` will not be called when this method is implemented.
 */
- (void)searchViewController:(GPSearchVC *)searchViewController
didSelectSearchAdviceAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText GPSEARCH_DEPRECATED("Use searchViewController:didSelectSearchAdviceAtIndexPath:searchText:");

/**
 Called when search Advice is selected, the method support more custom of search Advice view.

 @param searchViewController    search view controller
 @param indexPath               indexPath of row
 @param searchBar               search bar
 
 Note: `searchViewController:didSearchWithSearchBar:searchText:` and `searchViewController:didSelectSearchAdviceAtIndex:searchText:` will not be called when this method is implemented.
 Advice: To ensure that can cache selected custom search Advice records, you need to set `searchBar.text` = "custom search text".
 */
- (void)searchViewController:(GPSearchVC *)searchViewController didSelectSearchAdviceAtIndexPath:(NSIndexPath *)indexPath
                   searchBar:(UISearchBar *)searchBar;

/**
 Called when search text did change, you can reload data of Advice view thought this method.

 @param searchViewController    search view controller
 @param searchBar               search bar
 @param searchText              text for search
 */
- (void)searchViewController:(GPSearchVC *)searchViewController
         searchTextDidChange:(UISearchBar *)searchBar
                  searchText:(NSString *)searchText;

/**
 Called when cancel item did press, default execute `[self dismissViewControllerAnimated:YES completion:nil]`.

 @param searchViewController search view controller
 */
- (void)didClickCancel:(GPSearchVC *)searchViewController;

@end

@interface GPSearchVC : UIViewController

/**
 The delegate
 */
@property (nonatomic, weak) id<GPSearchVCDelegate> delegate;

/**
 The data source
 */
@property (nonatomic, weak) id<GPSearchViewControllerDataSource> dataSource;

/**
 Ranking the background color of the corresponding hexadecimal string (eg: @"#ffcc99") array (just four colors) when `hotSearchStyle` is `GPHotSearchStyleRankTag`.
 */
@property (nonatomic, strong) NSArray<NSString *> *rankTagBackgroundColorHexStrings;

/**
 The pool of color which are use in colorful tag when `hotSearchStyle` is `GPHotSearchStyleColorfulTag`.
 */
@property (nonatomic, strong) NSMutableArray<UIColor *> *colorPol;

/**
 Whether swap the popular search and search history location, default is NO.
 
 Note: It is‘t effective when `searchHistoryStyle` is `GPSearchHistoryStyleCell`.
 */
@property (nonatomic, assign) BOOL swapHotSeachWithSearchHistory;

/**
 The element of popular search
 */
@property (nonatomic, copy) NSArray<NSString *> *hotSearches;

/**
 The tags of popular search
 */
@property (nonatomic, copy) NSArray<UILabel *> *hotSearchTags;

/**
 The label of popular search header
 */
@property (nonatomic, weak) UILabel *hotSearchHeader;

/**
 Whether show popular search, default is YES.
 */
@property (nonatomic, assign) BOOL showHotSearch;

/**
 The title of popular search
 */
@property (nonatomic, copy) NSString *hotSearchTitle;

/**
 The tags of search history
 */
@property (nonatomic, copy) NSArray<UILabel *> *searchHistoryTags;

/**
 The label of search history header
 */
@property (nonatomic, weak) UILabel *searchHistoryHeader;

/**
 The title of search history
 */
@property (nonatomic, copy) NSString *searchHistoryTitle;

/**
 Whether show search history, default is YES.
 
 Note: search record is not cache when it is NO.
 */
@property (nonatomic, assign) BOOL showSearchHistory;

/**
 The path of cache search record, default is `GPSEARCH_SEARCH_HISTORY_CACHE_PATH`.
 */
@property (nonatomic, copy) NSString *searchHistoriesCachePath;

/**
 The number of cache search record, default is 20.
 */
@property (nonatomic, assign) NSUInteger searchHistoriesCount;

/**
 Whether remove the space of search string, default is YES.
 */
@property (nonatomic, assign) BOOL removeSpaceOnSearchString;

/**
 The button of empty search record when `searchHistoryStyle` is’t `GPSearchHistoryStyleCell`.
 */
@property (nonatomic, weak) UIButton *emptyButton;

/**
 The label od empty search record when `searchHistoryStyle` is `GPSearchHistoryStyleCell`.
 */
@property (nonatomic, weak) UILabel *emptySearchHistoryLabel;

/**
 The style of popular search, default is `GPHotSearchStyleNormalTag`.
 */
@property (nonatomic, assign) GPHotSearchStyle hotSearchStyle;

/**
 The style of search histrory, default is `GPSearchHistoryStyleCell`.
 */
@property (nonatomic, assign) GPSearchHistoryStyle searchHistoryStyle;

/**
 The mode of display search result view controller, default is `GPSearchResultShowModeCustom`.
 */
@property (nonatomic, assign) GPSearchResultShowMode searchResultShowMode;

/**
 The search bar
 */
@property (nonatomic, weak) UISearchBar *searchBar;

/**
 The text field of search bar
 */
@property (nonatomic, weak) UITextField *searchTextField;

/**
 The background color of search bar.
 */
@property (nonatomic, strong) UIColor *searchBarBackgroundColor;

/**
 The barButtonItem of cancel
 */
@property (nonatomic, weak) UIBarButtonItem *cancelButton;

/**
 The search Advice view
 */
@property (nonatomic, weak, readonly) UITableView *searchAdviceView;

/**
 The block which invoked when search begain.
 */
@property (nonatomic, copy) GPDidSearchBlock didSearchBlock;

/**
 The element of search Advices
 
 Note: it is't effective when `searchAdviceHidden` is NO or cell of Advice view is custom.
 */
@property (nonatomic, copy) NSArray<NSString *> *searchAdvice;

/**
 Whether hidden search suggstion view, default is NO.
 */
@property (nonatomic, assign) BOOL searchAdviceHidden;

/**
 The view controller of search result.
 */
@property (nonatomic, strong) UIViewController *searchResultController;

/**
 Whether show search result view when search text did change, default is NO.
 
 Note: it is effective only when `searchResultShowMode` is `GPSearchResultShowModeEmbed`.
 */
@property (nonatomic, assign) BOOL showSearchResultWhenSearchTextChanged;

/**
 Whether show search result view when search bar become first responder again.
 
 Note: it is effective only when `searchResultShowMode` is `GPSearchResultShowModeEmbed`.
 */
@property (nonatomic, assign) BOOL showSearchResultWhenSearchBarRefocused;

/**
 Creates an instance of searchViewContoller with popular searches and search bar's placeholder.

 @param hotSearches     popular searchs
 @param placeholder     placeholder of search bar
 @return new instance of `GPSearchViewController` class
 */
+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches
                               searchBarPlaceholder:(NSString *)placeholder;

/**
 Creates an instance of searchViewContoller with popular searches, search bar's placeholder and the block which invoked when search begain.

 @param hotSearches     popular searchs
 @param placeholder     placeholder of search bar
 @param block           block which invoked when search begain
 @return new instance of `GPSearchViewController` class
 
 Note: The `delegate` has a priority greater than the `block`, `block` is't effective when `searchViewController:didSearchWithSearchBar:searchText:` is implemented.
 */
+ (instancetype)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches
                               searchBarPlaceholder:(NSString *)placeholder
                                     didSearchBlock:(GPDidSearchBlock)block;

@end
