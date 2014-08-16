//
//  PublicClassMethod.m
//  ABDemo
//
//  Created by Tony on 14-8-14.
//  Copyright (c) 2014年 zwy. All rights reserved.
//

#import "PublicClassMethod.h"

@implementation PublicClassMethod


+ (BOOL)checkNotNull:(id)object
{
    return (object && [object isKindOfClass:[NSNull class]]==NO);
}

+ (id)changeObject:(id)object
{
    if ([PublicClassMethod checkNotNull:object]) {
        return object;
    }
    return nil;
}

@end
