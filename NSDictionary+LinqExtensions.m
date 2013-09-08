//
//  NSDictionary+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSDictionary+LinqExtensions.h"

@implementation NSDictionary (MSLINQ)

- (NSDictionary *)where:(MSLINQKeyValueCondition)predicate
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (predicate(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];
    return result;
}

- (NSDictionary *)select:(MSLINQKeyValueSelector)selector
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

- (NSArray *)toArray:(MSLINQKeyValueSelector)selector
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

- (BOOL)all:(MSLINQKeyValueCondition)condition
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

- (BOOL)any:(MSLINQKeyValueCondition)condition
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

- (NSUInteger)count:(MSLINQKeyValueCondition)condition
{
    return [self where:condition].count;
}

- (NSDictionary *)merge:(NSDictionary *)dictionary
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
