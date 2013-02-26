//
//  NSDictionary+LinqExtensions.h
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^KeyValueSelector)(id, id);

typedef BOOL (^KeyValuePredicate)(id, id);

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
 @return A dicionary whose elements are the result of invoking the transform function on each element of source.
 */
- (NSDictionary*) select:(KeyValueSelector)selector;


@end
