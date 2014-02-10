//
//  __OPCollectionViewController.h
//  Kickstarter
//
//  Created by Brandon Williams on 1/14/14.
//  Copyright (c) 2014 Kickstarter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface __OPCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSFetchedResultsController *collectionResults;
@property (nonatomic, strong) NSMutableArray *collectionData;

/**
 A convenience method that simply removes all objects
 from subsets.
 */
-(void) clearCollectionData;

/**
 Returns the class of the UIView that represents the cell
 at the specified index path.
 */
-(Class) collectionView:(UICollectionView*)collectionView classForCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 */
-(UIEdgeInsets) collectionView:(UICollectionView*)collectionView insetsForCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 */
-(CGFloat) collectionView:(UICollectionView*)collectionView widthForCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 Returns the object that represents the cell at the
 specified index path.
 */
-(id) collectionView:(UICollectionView*)collectionView objectForCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 Any cell customization that needs to be done in the controller
 should be implemented here and not in cellForItemAtIndexPath.
 Implementations must call the super method.
 */
-(void) collectionView:(UICollectionView*)collectionView configureCellView:(UIView*)cellView atIndexPath:(NSIndexPath*)indexPath;

@end