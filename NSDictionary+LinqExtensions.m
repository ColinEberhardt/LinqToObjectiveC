//
//  NSDictionary+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSDictionary+LinqExtensions.h"

@implementation NSDictionary (LinqExtensions)

- (NSDictionary *)where:(KeyValuePredicate)predicate
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

@end
