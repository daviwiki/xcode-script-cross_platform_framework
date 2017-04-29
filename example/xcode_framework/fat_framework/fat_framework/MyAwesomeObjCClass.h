//
//  MyAwesomeObjCClass.h
//  fat_framework
//
//  Created by David Martinez on 29/04/2017.
//
//

#import <Foundation/Foundation.h>

@protocol MyAwesomeObjCInterface <NSObject>

- (NSString * _Nullable) publicFuncB:(NSString * _Nonnull) parameter;

@end

@interface MyAwesomeObjCClass : NSObject<MyAwesomeObjCInterface>

- (BOOL) publicFuncA;
    
@end
