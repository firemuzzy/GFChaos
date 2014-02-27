//
//  TestChaosAppTests.m
//  TestChaosAppTests
//
//  Created by Michael Charkin on 2/26/14.
//  Copyright (c) 2014 GitFlub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GFChaos.h>
#import <ReactiveCocoa.h>

@interface TestChaosAppTests : XCTestCase

@end

@implementation TestChaosAppTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWith0ProbabilityOfFailure
{
    NSUInteger testCode1 = 1;
    NSUInteger testCode2 = 2;
    NSUInteger testCode3 = 3;
    
    NSString *testCode1ChaosDesc = @"Test code 1 Chaos";
    NSString *testCode2ChaosDesc = @"Test code 2 Chaos";
    NSString *testCode3ChaosDesc = @"Test code 3 Chaos";
    
    [GFChaos enableCode:testCode1 withDescription:testCode1ChaosDesc propabilityOfFailure:0];
    [GFChaos enableCode:testCode2 withDescription:testCode2ChaosDesc propabilityOfFailure:0];
    [GFChaos enableCode:testCode3 withDescription:testCode3ChaosDesc propabilityOfFailure:0];

    __block BOOL sucTest1 = NO;
    RACSignal *sig1 = [GFChaos chaosWithDelay:10 andCode:testCode1];
    [sig1 subscribeNext:^(id x) {
        sucTest1 = YES;
    } error:^(NSError *error) {
        XCTFail(@"test failed when failure probability is 0");
    }];
    
    __block BOOL sucTest2 = NO;
    RACSignal *sig2 = [GFChaos chaosWithDelay:10 andCode:testCode2];
    [sig2 subscribeNext:^(id x) {
        sucTest2 = YES;
    } error:^(NSError *error) {
        XCTFail(@"test failed when failure probability is 0");
    }];
    
    __block BOOL sucTest3 = NO;
    RACSignal *sig3 = [GFChaos chaosWithDelay:10 andCode:testCode3];
    [sig3 subscribeNext:^(id x) {
        sucTest3 = YES;
    } error:^(NSError *error) {
        XCTFail(@"test failed when failure probability is 0");
    }];
    
    [sig1 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(sucTest1, @"sig1 never finished");
    [sig2 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(sucTest2, @"sig2 never finished");
    [sig3 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(sucTest3, @"sig2 never finished");
}

- (void)testWith1ProbabilityOfFailure
{
    NSUInteger testCode4 = 4;
    NSUInteger testCode5 = 5;
    NSUInteger testCode6 = 6;
    
    NSString *testCode4ChaosDesc = @"Test code 4 Chaos";
    NSString *testCode5ChaosDesc = @"Test code 5 Chaos";
    NSString *testCode6ChaosDesc = @"Test code 6 Chaos";
    
    [GFChaos enableCode:testCode4 withDescription:testCode4ChaosDesc propabilityOfFailure:1];
    [GFChaos enableCode:testCode5 withDescription:testCode5ChaosDesc propabilityOfFailure:1];
    [GFChaos enableCode:testCode6 withDescription:testCode6ChaosDesc propabilityOfFailure:1];
    
    __block BOOL failedTest4 = NO;
    RACSignal *sig1 = [GFChaos chaosWithDelay:1 andCode:testCode4];
    [sig1 subscribeNext:^(id x) {
        XCTFail(@"test succeeded when failure probability is 1");
    } error:^(NSError *error) {
        XCTAssertEqual([error code], (int)testCode4, @"codes did not match");
        XCTAssertEqualObjects([error localizedDescription], testCode4ChaosDesc, @"descriptions did not match");
        failedTest4 = YES;
    }];
    
    __block BOOL failedTest5 = NO;
    RACSignal *sig2 = [GFChaos chaosWithDelay:1 andCode:testCode5];
    [sig2 subscribeNext:^(id x) {
        XCTFail(@"test succeeded when failure probability is 1");
    } error:^(NSError *error) {
        XCTAssertEqual([error code], (int)testCode5, @"codes did not match");
        XCTAssertEqualObjects([error localizedDescription], testCode5ChaosDesc, @"descriptions did not match");
        failedTest5 = YES;
    }];
    
    __block BOOL failedTest6 = NO;
    RACSignal *sig3 = [GFChaos chaosWithDelay:1 andCode:testCode6];
    [sig3 subscribeNext:^(id x) {
        XCTFail(@"test succeeded when failure probability is 1");
    } error:^(NSError *error) {
        XCTAssertEqual([error code], (int)testCode6, @"codes did not match");
        XCTAssertEqualObjects([error localizedDescription], testCode6ChaosDesc, @"descriptions did not match");
        failedTest6 = YES;
    }];
    
    [sig1 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(failedTest4, @"sig4 never failed");
    [sig2 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(failedTest5, @"sig5 never failed");
    [sig3 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(failedTest6, @"sig6 never failed");
}

- (void)testErrorDelay
{
    NSUInteger testCode = 7;
    
    NSString *testCodeChaosDesc = @"Test code 7 Chaos";
    
    [GFChaos enableCode:testCode withDescription:testCodeChaosDesc propabilityOfFailure:1];
    
    NSDate *before = [NSDate date];
    
    __block BOOL failedTest = NO;
    __block NSDate *after;
    RACSignal *sig1 = [GFChaos chaosWithDelay:2 andCode:testCode];
    [sig1 subscribeNext:^(id x) {
        XCTFail(@"test succeeded when failure probability is 1");
    } error:^(NSError *error) {
        failedTest = YES;
        after = [NSDate date];
    }];
    
    [sig1 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(failedTest, @"sig never failed");
    
    XCTAssertTrue([after timeIntervalSinceDate:before] >= 2.0, @"sig was not delayed long enough");
    XCTAssertTrue([after timeIntervalSinceDate:before] < 3.0, @"sig was delayed too long");
}

- (void)testNoDelayWhenSuccess
{
    NSUInteger testCode = 8;
    
    NSString *testCodeChaosDesc = @"Test code 8 Chaos";
    
    [GFChaos enableCode:testCode withDescription:testCodeChaosDesc propabilityOfFailure:0];
    
    NSDate *before = [NSDate date];
    
    __block BOOL sucTest = NO;
    __block NSDate *after;
    RACSignal *sig1 = [GFChaos chaosWithDelay:2 andCode:testCode];
    [sig1 subscribeNext:^(id x) {
        sucTest = YES;
        after = [NSDate date];
    } error:^(NSError *error) {
        XCTFail(@"test failed when failure probability is 0");
    }];
    
    [sig1 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(sucTest, @"sig never succeded");
    XCTAssertTrue([after timeIntervalSinceDate:before] < 0.1, @"sig was delayed during success");
}

- (void)testNoDelayAndSuccessWhenNotEnabled
{
    NSUInteger testCode = 9;
    
    NSDate *before = [NSDate date];
    
    __block BOOL sucTest = NO;
    __block NSDate *after;
    RACSignal *sig1 = [GFChaos chaosWithDelay:2 andCode:testCode];
    [sig1 subscribeNext:^(id x) {
        sucTest = YES;
        after = [NSDate date];
    } error:^(NSError *error) {
        XCTFail(@"test failed when chaos no enabled");
    }];
    
    [sig1 asynchronouslyWaitUntilCompleted:nil];
    XCTAssertTrue(sucTest, @"sig never succeded");
    XCTAssertTrue([after timeIntervalSinceDate:before] < 0.1, @"sig was delayed during success");
}

@end
