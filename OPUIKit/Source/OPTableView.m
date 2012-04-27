//
//  OPTableView.m
//  Kickstarter
//
//  Created by Brandon Williams on 4/27/12.
//  Copyright (c) 2012 Kickstarter. All rights reserved.
//

#import "OPTableView.h"
#import <objc/runtime.h>

@interface OPTableView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) NSObject<UITableViewDataSource> *theDataSource;
@property (nonatomic, weak) NSObject<UITableViewDelegate> *theDelegate;
@property (nonatomic, assign) BOOL dataSourceIsSelf;
@property (nonatomic, assign) BOOL delegateIsSelf;

@property (nonatomic, strong) NSIndexPath *beginDraggingIndexPath;
@property (nonatomic, assign) CGPoint contentOffsetDelta;
@end

@implementation OPTableView

@synthesize horizontal = _horizontal;
@synthesize snapToRows = _snapToRows;
@synthesize theDataSource = _theDataSource;
@synthesize theDelegate = _theDelegate;
@synthesize dataSourceIsSelf = _dataSourceIsSelf;
@synthesize delegateIsSelf = _delegateIsSelf;
@synthesize beginDraggingIndexPath = _beginDraggingIndexPath;
@synthesize contentOffsetDelta = _contentOffsetDelta;

-(id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (! (self = [super initWithFrame:frame style:style]))
        return nil;
    
    self.beginDraggingIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return self;
}

-(void) setHorizontal:(BOOL)horizontal {
    _horizontal = horizontal;
    
    if (horizontal)
    {
        CGRect frame = self.frame;
        self.transform = CGAffineTransformMakeRotation(-M_PI / 2.0f);
        self.frame = frame;
    }
    else
    {
        CGRect frame = self.frame;
        self.transform = CGAffineTransformIdentity;
        self.frame = frame;
    }
}

#pragma mark -
#pragma mark UITableView methods
#pragma mark -

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.theDataSource tableView:tableView numberOfRowsInSection:section];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.theDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell && self.horizontal)
        cell.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
    return cell;
}

#pragma mark -
#pragma mark UIScrollView methods
#pragma mark -

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    static CGPoint previousOffset;
    self.contentOffsetDelta = CGPointMake(self.contentOffset.x - previousOffset.x, self.contentOffset.y - previousOffset.y);
    previousOffset = self.contentOffset;
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.snapToRows)
    {
        dispatch_async(dispatch_get_current_queue(), ^{
            
            if (self.contentOffset.y < 0.0f)
                return ;
            else if (self.contentOffset.y > self.contentSize.height - self.frame.size.height)
                return ;
            
            UITableViewCell *firstCell = [[self visibleCells] objectAtIndex:0];
            UITableViewCell *secondCell = [[self visibleCells] objectAtIndex:0];
            CGFloat top = firstCell.frame.origin.y - self.contentOffset.y;
            CGFloat bottom = top + firstCell.frame.size.height;
            
            if (self.contentOffsetDelta.y > 0 && top < -firstCell.frame.size.height/4.0f)
                self.beginDraggingIndexPath = [[self indexPathsForVisibleRows] objectAtIndex:1];
            else if (self.contentOffsetDelta.y < 0 && bottom > secondCell.frame.size.height/4.0f)
                self.beginDraggingIndexPath = [[self indexPathsForVisibleRows] objectAtIndex:0];
            
            [self scrollToRowAtIndexPath:self.beginDraggingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        });
    }
}

-(void) scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    self.beginDraggingIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark -
#pragma mark NSObject overridden methods
#pragma mark -

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector])
        return [super respondsToSelector:aSelector];
    
    struct objc_method_description dataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), aSelector, NO, YES);
    if (! _dataSourceIsSelf && dataSourceMethod.name != nil && [_theDataSource respondsToSelector:aSelector])
        return YES;
    
    struct objc_method_description delegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), aSelector, NO, YES);
    if (! _delegateIsSelf && delegateMethod.name != nil && [_theDelegate respondsToSelector:aSelector])
        return YES;
    
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([super methodSignatureForSelector:aSelector])
        return [super methodSignatureForSelector:aSelector];
    
    struct objc_method_description dataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), aSelector, NO, YES);
    if (dataSourceMethod.name != nil && [_theDataSource methodSignatureForSelector:aSelector])
        return [_theDataSource methodSignatureForSelector:aSelector];
    
    struct objc_method_description delegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), aSelector, NO, YES);
    if (delegateMethod.name != nil && [_theDelegate methodSignatureForSelector:aSelector])
        return [_theDelegate methodSignatureForSelector:aSelector];
    
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    struct objc_method_description dataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), selector, NO, YES);
    struct objc_method_description delegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), selector, NO, YES);
    
    if (dataSourceMethod.name != nil && [self.theDataSource respondsToSelector:selector])
        [anInvocation invokeWithTarget:self.theDataSource];
    else if (delegateMethod.name != nil && [self.theDelegate respondsToSelector:selector])
        [anInvocation invokeWithTarget:self.theDelegate];
    else
        [super forwardInvocation:anInvocation];
}

#pragma mark -
#pragma mark Delegate / data source methods
#pragma mark -

-(void) setDelegate:(id<UITableViewDelegate>)delegate {
    self.theDelegate = delegate;
    self.delegateIsSelf = delegate == self;
    [super setDelegate:self];
}

-(void) setDataSource:(id<UITableViewDataSource>)dataSource {
    self.theDataSource = dataSource;
    self.dataSourceIsSelf = dataSource == self;
    [super setDataSource:self];
}

@end
