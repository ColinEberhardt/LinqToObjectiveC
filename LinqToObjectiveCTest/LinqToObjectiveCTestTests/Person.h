//
//  TestObject.h
//  ShinobiControls_Source
//
//  Created by Colin Eberhardt on 07/01/2013.
//
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSNumber* age;
@property (assign) NSUInteger* intAge;

+ (Person*) personWithName:(NSString*)name age:(NSNumber*)age;

@end
