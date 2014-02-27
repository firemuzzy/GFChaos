//
//  GFChaos.m
//  GFChaos
//
//  Created by Michael Charkin on 2/26/14.
//  Copyright (c) 2014 GitFlub. All rights reserved.
//

#import "GFChaos.h"

NSString * const GFChaosErrorDomain = @"GFChaosErrorDomain";
const NSInteger GFChaosError = 101;

@interface GFChaos ()

@property (nonatomic, strong) NSMutableDictionary *codeDescriptions;
@property (nonatomic, strong) NSMutableDictionary *failureProbabilities;


@end

@implementation GFChaos

static GFChaos *sharedInstance = nil;
+ (GFChaos *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[GFChaos alloc] init];
    });
    
    return sharedInstance;
}

+ (void) enableCode:(NSUInteger)code withDescription:(NSString *)desc propabilityOfFailure:(double)probability {
    NSParameterAssert(desc != nil);
    NSParameterAssert(probability >= 0 && probability <= 1);
    
    if([GFChaos sharedInstance].codeDescriptions == nil) {
        [GFChaos sharedInstance].codeDescriptions = [[NSMutableDictionary alloc] init];
        [GFChaos sharedInstance].failureProbabilities = [[NSMutableDictionary alloc] init];
    }
    
    NSNumber *codeNum = [NSNumber numberWithUnsignedInteger:code];
    [[GFChaos sharedInstance].codeDescriptions setObject:desc forKey:codeNum];
    
    NSNumber *probabilityNum = [NSNumber numberWithUnsignedInteger:probability];
    [[GFChaos sharedInstance].failureProbabilities setObject:probabilityNum forKey:codeNum];
}

+ (RACSignal *)chaosWithDelay:(NSTimeInterval)interval andCode:(NSUInteger)code {
    NSNumber *key = [NSNumber numberWithUnsignedInteger:code];
    
    NSString *desc = [[GFChaos sharedInstance].codeDescriptions objectForKey:key];
    BOOL enabled = desc != nil;
    
    if(!enabled) return [RACSignal return:nil];
    else {
        double probabilityOfFailure = [[[GFChaos sharedInstance].failureProbabilities objectForKey:key] doubleValue];
        double random = drand48();
        
        if(random > probabilityOfFailure) return[RACSignal return:nil];
        else {
            // failure happens
            NSLog(@"%@", desc);
            NSError *error = [GFChaos chaosErrorForCode:code andDesc:desc];
            
            return [[[RACSignal return:nil] delay:interval] flattenMap:^RACStream *(id value) {
                return [RACSignal error:error];
            }];
        }
    }
    
    return nil;
}

+ (NSError *)chaosErrorForCode:(NSInteger)code  andDesc:(NSString *)desc {
	NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: desc,
                               NSLocalizedFailureReasonErrorKey: desc,
                               };
	return [NSError errorWithDomain:GFChaosErrorDomain code:code userInfo:userInfo];
}

@end
