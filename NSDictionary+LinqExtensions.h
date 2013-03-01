//
//  NSDictionary+LinqExtensions.h
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^KeyValueSelector)(id key, id value);

typedef BOOL (^KeyValuePredicate)(id key, id value);

typedef BOOL (^KeyValueCondition)(id key, id value);

/**
 Various NSDictionary extensions that provide a Linq-style query API
 */
@interface NSDictionary (LinqExtensions)

/** Filters a dictionary based on a predicate.
 
 @param predicate The function to test each source key-value pair for a condition.
 @return A dictionary that contains key-value pairs from the input dictionary that satisfy the condition.
 */
- (NSDictionary*) where:(KeyValuePredicate)predicate;

/** Projects each element of the dictionary into a new form.
 
 @param selector A transform function to apply to each element.
 @return A dicionary whose elements are the result of invoking the transform function on each key-value pair of source.
 */
- (NSDictionary*) select:(KeyValueSelector)selector;

/** Projects each element of the dictionary to a new form, which is used to populate the returned array.
 
 @param selector A transform function to apply to each element.
 @return An array whose elements are the result of invoking the transform function on each key-value pair of source.
 */
- (NSArray*) toArray:(KeyValueSelector)selector;

/** Determines whether all of the key-value pairs of the dictionary satisfies a condition.
 
 @param condition The condition to test key-value pairs against.
 @return Whether any of the element of the dictionary satisfies a condition.
 */
- (BOOL) all:(KeyValueCondition)condition;

/** Determines whether any of the key-value pairs of the dictionary satisfies a condition.
 
 @param condition The condition to test key-value pairs against.
 @return Whether any of the element of the dictionary satisfies a condition.
 */
- (BOOL) any:(KeyValueCondition)condition;

@end
