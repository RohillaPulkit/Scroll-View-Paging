//
//  PageScroller.h
//  ScrollViewPaging
//
//  Created by Pulkit Rohilla on 09/12/16.
//  Copyright © 2016 PulkitRohilla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"

@class PageScroller;

@protocol PageScrollerDataSource <NSObject>

@required
- (NSArray *)contentArrayInScrollView:(PageScroller *)scrollView;

@end


IB_DESIGNABLE
@interface PageScroller : UIView <UIScrollViewDelegate>{

    IBOutlet id <PageScrollerDataSource>  _dataSource;
    
    NSArray				 *_arrayContent;
}

@property(nonatomic,assign)   id <PageScrollerDataSource> dataSource;

- (NSArray *)arrayContent;

// Data
- (void) reloadData;

@end
