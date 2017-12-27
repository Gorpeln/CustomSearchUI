//
//  GPSearchAdviceVC.h
//  GPSearchDemo
//
//  Created by chen on 16/10/27.
//  Copyright © 2016年 Gorpeln. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void(^GPSearchAdviceDidSelectCellBlock)(UITableViewCell *selectedCell);

@protocol GPSearchAdviceViewDataSource <NSObject, UITableViewDataSource>

@required
- (UITableViewCell *)searchAdviceView:(UITableView *)searchAdviceView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)searchAdviceView:(UITableView *)searchAdviceView numberOfRowsInSection:(NSInteger)section;
@optional
- (NSInteger)numberOfSectionsInSearchAdviceView:(UITableView *)searchAdviceView;
- (CGFloat)searchAdviceView:(UITableView *)searchAdviceView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GPSearchAdviceVC : UITableViewController

@property (nonatomic, weak) id<GPSearchAdviceViewDataSource> dataSource;
@property (nonatomic, copy) NSArray<NSString *> *searchAdvice;
@property (nonatomic, copy) GPSearchAdviceDidSelectCellBlock didSelectCellBlock;

+ (instancetype)searchAdviceViewControllerWithDidSelectCellBlock:(GPSearchAdviceDidSelectCellBlock)didSelectCellBlock;

@end
