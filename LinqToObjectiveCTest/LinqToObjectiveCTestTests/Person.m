//
//  TestObject.m
//  ShinobiControls_Source
//
//  Created by Colin Eberhardt on 07/01/2013.
//
//

#import "Person.h"

@implementation Person

@synthesize name = _name;
@synthesize age = _age;

+ (Person*) personWithName:(NSString *)name age:(NSNumber *)age
{
    Person* obj = [[Person alloc] init];
    obj.name = name;
    obj.age = age;
    obj.intAge = [age integerValue];
    return obj;
}


@end
