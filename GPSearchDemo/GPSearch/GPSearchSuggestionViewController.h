//
//  GPSearchSuggestionViewController.h
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void(^GPSearchSuggestionDidSelectCellBlock)(UITableViewCell *selectedCell);

@protocol GPSearchSuggestionViewDataSource <NSObject, UITableViewDataSource>

@required
- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section;
@optional
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView;
- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GPSearchSuggestionViewController : UITableViewController

@property (nonatomic, weak) id<GPSearchSuggestionViewDataSource> dataSource;
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;
@property (nonatomic, copy) GPSearchSuggestionDidSelectCellBlock didSelectCellBlock;

+ (instancetype)searchSuggestionViewControllerWithDidSelectCellBlock:(GPSearchSuggestionDidSelectCellBlock)didSelectCellBlock;

@end
