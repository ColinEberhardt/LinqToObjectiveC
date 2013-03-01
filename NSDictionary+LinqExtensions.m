//
//  NSDictionary+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSDictionary+LinqExtensions.h"

@implementation NSDictionary (LinqExtensions)

- (NSDictionary *)where:(KeyValueCondition)predicate
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (predicate(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];
    return result;
}

- (NSDictionary *)select:(KeyValueSelector)selector
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result setObject:selector(key, obj) forKey:key];
    }];
    return result;
}

- (NSArray *)toArray:(KeyValueSelector)selector
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result addObject:selector(key, obj)];
    }];
    return result;
}

- (BOOL)all:(KeyValueCondition)condition
{
    __block BOOL all = TRUE;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!condition(key, obj)){
            all = FALSE;
            *stop = TRUE;
        }
    }];
    return all;
}

- (BOOL)any:(KeyValueCondition)condition
{
    __block BOOL any = FALSE;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (condition(key, obj)){
            any = TRUE;
            *stop = TRUE;
        }
    }];
    return any;
}

@end
