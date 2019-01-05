//
//  PageScroller.m
//  ScrollViewPaging
//
//  Created by Pulkit Rohilla on 09/12/16.
//  Copyright © 2016 PulkitRohilla. All rights reserved.
//

#import "PageScroller.h"

@implementation PageScroller{
    
    UIScrollView *pageScrollView;
    
    NSInteger currentPage;
    
    NSInteger _numberOfPages;
    NSMutableArray *viewControllers;

}

@synthesize dataSource;

-(void)prepareForInterfaceBuilder{

    UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
    label.text = @"PageScroller";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self addSubview:label];
    self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.7];
    
    [super prepareForInterfaceBuilder];
}

-(void)awakeFromNib{

    [super awakeFromNib];
    
    [self setupUI];
}

#pragma mark - OtherMethods

-(void)setupUI{
    
    pageScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    
    pageScrollView.pagingEnabled = YES;

    pageScrollView.showsHorizontalScrollIndicator = NO;
    pageScrollView.showsVerticalScrollIndicator = NO;
    pageScrollView.scrollsToTop = NO;
    pageScrollView.delegate = self;
    pageScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    pageScrollView.clipsToBounds = NO;
    
    [self addSubview:pageScrollView];
    [self setNeedsUpdateConstraints];
}

-(void)updateConstraints{
 
    [super updateConstraints];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(pageScrollView);
    
    NSArray *arrayHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[pageScrollView]-30-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    
    NSArray *arrayVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pageScrollView]-0-|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    
    [self addConstraints:arrayHConstraints];
    [self addConstraints:arrayVConstraints];
}

#pragma mark - DataSource

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= _numberOfPages)
        return;
    
    // replace the placeholder if necessary
    CardViewController *controller = [viewControllers objectAtIndex:page];
    
    if ((NSNull *)controller == [NSNull null])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];

        controller = [storyboard instantiateViewControllerWithIdentifier:@"CardViewController"];
        [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = pageScrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
//        [self addChildViewController:controller];
        [pageScrollView addSubview:controller.view];
//        [controller didMoveToParentViewController:self];
        
        UIImage *imageCard = [_arrayContent objectAtIndex:page];
        controller.imageViewCard.image = imageCard;
        
        if (page == currentPage) {
            
            controller.view.alpha = 1.0;
        }
        else{
            
            controller.view.alpha = 0.5;
        }
    }
    else
    {
        if (page == currentPage) {
            
            controller.view.alpha = 1.0;
        }
        else{
            
            controller.view.alpha = 0.5;
        }
    }

}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect bounds = pageScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    
    [pageScrollView scrollRectToVisible:bounds animated:animated];
}


- (void)reloadData{
    
    NSArray *arrayContent;
    
    if ([self.dataSource respondsToSelector:@selector(contentArrayInScrollView:)]) {
        
        arrayContent = [self.dataSource contentArrayInScrollView:self];
    }
    
    NSInteger numPages = arrayContent.count;

    [self setNumberOfPages:numPages];
    
    if (numPages > 0) {
        
        // view controllers are created lazily
        // in the meantime, load the array with placeholders which will be replaced on demand
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < numPages; i++)
        {
            [controllers addObject:[NSNull null]];
        }
        
        viewControllers = controllers;
    }
    
    NSLog(@"Array Count :%li", (long)numPages);

    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}


- (void) setNumberOfPages : (NSInteger) number
{
    _numberOfPages = number;
    
    pageScrollView.contentSize = CGSizeMake(CGRectGetWidth(pageScrollView.frame) * _numberOfPages, CGRectGetHeight(pageScrollView.frame));
    
    [self updateConstraints];
}

- (NSInteger)numberOfPages;
{
    return _numberOfPages;
}

@end
