//
//  NSDictionary+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSDictionary+LinqExtensions.h"

@implementation NSDictionary (QueryExtension)

- (NSDictionary *)linq_where:(LINQKeyValueCondition)predicate
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (predicate(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];
    return result;
}

- (NSDictionary *)linq_select:(LINQKeyValueSelector)selector
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id object = selector(key, obj);
        if (!object)
            object = [NSNull null];
        
        [result setObject:object forKey:key];
    }];
    return result;
}

- (NSArray *)linq_toArray:(LINQKeyValueSelector)selector
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id object = selector(key, obj);
        if (!object)
            object = [NSNull null];
        [result addObject:object];
    }];
    return result;
}

- (BOOL)linq_all:(LINQKeyValueCondition)condition
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

- (BOOL)linq_any:(LINQKeyValueCondition)condition
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

- (NSUInteger)linq_count:(LINQKeyValueCondition)condition
{
    return [self linq_where:condition].count;
}

- (NSDictionary *)linq_Merge:(NSDictionary *)dictionary
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithDictionary:self];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![result objectForKey:key]) {
            [result setObject:obj forKey:key];
        }
    }];
    return result;
}

@end
