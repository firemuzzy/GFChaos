//
//  GFChaos.h
//  GFChaos
//
//  Created by Michael Charkin on 2/26/14.
//  Copyright (c) 2014 GitFlub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface GFChaos : NSObject

+ (void)enableCode:(NSUInteger)code withDescription:(NSString *)desc propabilityOfFailure:(double)probability;
+ (RACSignal *)chaosWithDelay:(NSTimeInterval)interval andCode:(NSUInteger)code;

@end
