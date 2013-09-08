//
//  NSDictionary+LinqExtensions.h
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^MSLINQKeyValueSelector)(id key, id value);

typedef BOOL (^MSLINQKeyValueCondition)(id key, id value);

/**
 Various NSDictionary extensions that provide a Linq-style query API
 */
@interface NSDictionary (MSLINQ)

/** Filters a dictionary based on a predicate.
 
 @param predicate The function to test each source key-value pair for a condition.
 @return A dictionary that contains key-value pairs from the input dictionary that satisfy the condition.
 */
- (NSDictionary*) where:(MSLINQKeyValueCondition)predicate;

/** Projects each element of the dictionary into a new form.
 
 @param selector A transform function to apply to each element.
 @return A dicionary whose elements are the result of invoking the transform function on each key-value pair of source.
 */
- (NSDictionary*) select:(MSLINQKeyValueSelector)selector;

/** Projects each element of the dictionary to a new form, which is used to populate the returned array.
 
 @param selector A transform function to apply to each element.
 @return An array whose elements are the result of invoking the transform function on each key-value pair of source.
 */
- (NSArray*) toArray:(MSLINQKeyValueSelector)selector;

/** Determines whether all of the key-value pairs of the dictionary satisfies a condition.
 
 @param condition The condition to test key-value pairs against.
 @return Whether any of the element of the dictionary satisfies a condition.
 */
- (BOOL) all:(MSLINQKeyValueCondition)condition;

/** Determines whether any of the key-value pairs of the dictionary satisfies a condition.
 
 @param condition The condition to test key-value pairs against.
 @return Whether any of the element of the dictionary satisfies a condition.
 */
- (BOOL) any:(MSLINQKeyValueCondition)condition;

/** Counts the number of key-value pairs that satisfy the given condition.
 
 @param condition The condition to test key-value pairs against.
 @return The number of elements that satisfy the condition.
 */
- (NSUInteger) count:(MSLINQKeyValueCondition)condition;

/** Merges the contents of this dictionary with the given dictionary. For any duplicates, the value from
 the source dictionary will be used.
 
 @param dic The dictionary to merge with.
 @return A dictionary which is the result of merging.
 */
- (NSDictionary*) merge:(NSDictionary*)dic;

@end
