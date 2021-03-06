//
//  TestURLSesssionDirect.m
//  YMHTTP_Tests
//
//  Created by zymxxxs on 2020/3/26.
//  Copyright © 2020 zymxxxs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <YMHTTP/YMHTTP.h>
#import "YMHTTPRedirectionDataTask.h"

@interface TestURLSesssionDirect : XCTestCase

@end

@implementation TestURLSesssionDirect

- (void)testHttpRedirectionWithCode300 {
    NSArray *httpMethods = @[ @"HEAD", @"GET", @"PUT", @"POST", @"DELETE" ];
    for (NSString *method in httpMethods) {
        NSString *urlString = @"http://httpbin.org/redirect-to?url=%2Fget&status_code=300";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method;
        XCTestExpectation *te = [self
            expectationWithDescription:[NSString
                                           stringWithFormat:@"%@ testHttpRedirectionWithCode300: with HTTP redirection",
                                                            method]];
        YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
        [d runWithRequest:request];
        [self waitForExpectationsWithTimeout:12 handler:nil];
        XCTAssertNil(d.httpError);
        XCTAssertNil(d.redirectionResponse);
        XCTAssertNotNil(d.response);
        XCTAssertEqual(d.response.statusCode, 300);

        XCTAssertEqual(d.callbacks.count, 2);
        XCTAssertEqualObjects(d.callbacks[0],
                              NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
        XCTAssertEqualObjects(d.callbacks[1], NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
    }
}

- (void)testHttpRedirectionWithCode301_302 {
    NSArray *httpMethods = @[ @"POST", @"HEAD", @"GET", @"PUT", @"DELETE" ];
    for (NSNumber *statusCode in @[ @(301), @(302) ]) {
        for (NSString *method in httpMethods) {
            NSString *urlString =
                [NSString stringWithFormat:@"http://httpbin.org/redirect-to?url=/anything&status_code=%@",
                                           statusCode.stringValue];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = method;
            XCTestExpectation *te =
                [self expectationWithDescription:
                          [NSString stringWithFormat:@"%@ %@ testHttpRedirectionWithCode301_302: with HTTP redirection",
                                                     method,
                                                     statusCode.stringValue]];
            YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
            [d runWithRequest:request];
            [self waitForExpectationsWithTimeout:12 handler:nil];
            XCTAssertNil(d.httpError);
            XCTAssertEqual(d.response.statusCode, 200);
            XCTAssertEqual(d.redirectionResponse.statusCode, statusCode.integerValue);

            if ([method isEqualToString:@"HEAD"]) {
                XCTAssertEqual(d.callbacks.count, 3);
                XCTAssertEqualObjects(d.callbacks[0],
                                      NSStringFromSelector(@selector(
                                          YMURLSession:
                                                  task:willPerformHTTPRedirection:newRequest:completionHandler:)));
                XCTAssertEqualObjects(
                    d.callbacks[1],
                    NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
                XCTAssertEqualObjects(d.callbacks[2],
                                      NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
                XCTAssertNil(d.result);
            } else {
                XCTAssertEqual(d.callbacks.count, 4);
                XCTAssertEqualObjects(d.callbacks[0],
                                      NSStringFromSelector(@selector(
                                          YMURLSession:
                                                  task:willPerformHTTPRedirection:newRequest:completionHandler:)));
                XCTAssertEqualObjects(
                    d.callbacks[1],
                    NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
                XCTAssertEqualObjects(d.callbacks[2],
                                      NSStringFromSelector(@selector(YMURLSession:task:didReceiveData:)));
                XCTAssertEqualObjects(d.callbacks[3],
                                      NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
                XCTAssertEqualObjects(d.task.currentRequest.HTTPMethod,
                                      [method isEqualToString:@"POST"] ? @"GET" : method);
            }
        }
    }
}

- (void)testHttpRedirectionWithCode303 {
    NSArray *httpMethods = @[ @"POST", @"HEAD", @"GET", @"PUT", @"DELETE" ];
    for (NSString *method in httpMethods) {
        NSString *urlString = @"http://httpbin.org/redirect-to?url=/anything&status_code=303";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method;
        XCTestExpectation *te = [self
            expectationWithDescription:[NSString
                                           stringWithFormat:@"%@ testHttpRedirectionWithCode303: with HTTP redirection",
                                                            method]];
        YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
        [d runWithRequest:request];
        [self waitForExpectationsWithTimeout:12 handler:nil];
        XCTAssertNil(d.httpError);
        XCTAssertEqual(d.response.statusCode, 200);
        XCTAssertEqual(d.redirectionResponse.statusCode, 303);
        XCTAssertEqual(d.callbacks.count, 4);
        XCTAssertEqualObjects(
            d.callbacks[0],
            NSStringFromSelector(@selector(YMURLSession:
                                                   task:willPerformHTTPRedirection:newRequest:completionHandler:)));
        XCTAssertEqualObjects(d.callbacks[1],
                              NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
        XCTAssertEqualObjects(d.callbacks[2], NSStringFromSelector(@selector(YMURLSession:task:didReceiveData:)));
        XCTAssertEqualObjects(d.callbacks[3], NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
        XCTAssertEqualObjects(d.task.currentRequest.HTTPMethod, @"GET");
    }
}

- (void)testHttpRedirectionWithCode304 {
    NSArray *httpMethods = @[ @"HEAD", @"GET", @"PUT", @"POST", @"DELETE" ];
    for (NSString *method in httpMethods) {
        NSString *urlString = @"http://httpbin.org/redirect-to?url=%2Fget&status_code=304";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method;
        XCTestExpectation *te = [self
            expectationWithDescription:[NSString
                                           stringWithFormat:@"%@ testHttpRedirectionWithCode300: with HTTP redirection",
                                                            method]];
        YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
        [d runWithRequest:request];
        [self waitForExpectationsWithTimeout:12 handler:nil];
        XCTAssertNil(d.httpError);
        XCTAssertNil(d.redirectionResponse);
        XCTAssertNotNil(d.response);
        XCTAssertEqual(d.response.statusCode, 304);

        XCTAssertEqual(d.callbacks.count, 2);
        XCTAssertEqualObjects(d.callbacks[0],
                              NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
        XCTAssertEqualObjects(d.callbacks[1], NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
        XCTAssertNil(d.result);
    }
}

- (void)testHttpRedirectionWithCode305_308 {
    NSArray *httpMethods = @[ @"POST", @"HEAD", @"GET", @"PUT", @"DELETE" ];
    for (NSNumber *statusCode in @[ @(305), @(306), @(307), @(308) ]) {
        for (NSString *method in httpMethods) {
            NSString *urlString =
                [NSString stringWithFormat:@"http://httpbin.org/redirect-to?url=/anything&status_code=%@",
                                           statusCode.stringValue];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod = method;
            XCTestExpectation *te =
                [self expectationWithDescription:
                          [NSString stringWithFormat:@"%@ %@ testHttpRedirectionWithCode305_308: with HTTP redirection",
                                                     method,
                                                     statusCode.stringValue]];
            YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
            [d runWithRequest:request];
            [self waitForExpectationsWithTimeout:20 handler:nil];
            XCTAssertNil(d.httpError);
            XCTAssertEqual(d.response.statusCode, 200);
            XCTAssertEqual(d.redirectionResponse.statusCode, statusCode.integerValue);

            if ([method isEqualToString:@"HEAD"]) {
                XCTAssertEqual(d.callbacks.count, 3);
                XCTAssertEqualObjects(d.callbacks[0],
                                      NSStringFromSelector(@selector(
                                          YMURLSession:
                                                  task:willPerformHTTPRedirection:newRequest:completionHandler:)));
                XCTAssertEqualObjects(
                    d.callbacks[1],
                    NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
                XCTAssertEqualObjects(d.callbacks[2],
                                      NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
                XCTAssertNil(d.result);
            } else {
                XCTAssertEqual(d.callbacks.count, 4);
                XCTAssertEqualObjects(d.callbacks[0],
                                      NSStringFromSelector(@selector(
                                          YMURLSession:
                                                  task:willPerformHTTPRedirection:newRequest:completionHandler:)));
                XCTAssertEqualObjects(
                    d.callbacks[1],
                    NSStringFromSelector(@selector(YMURLSession:task:didReceiveResponse:completionHandler:)));
                XCTAssertEqualObjects(d.callbacks[2],
                                      NSStringFromSelector(@selector(YMURLSession:task:didReceiveData:)));
                XCTAssertEqualObjects(d.callbacks[3],
                                      NSStringFromSelector(@selector(YMURLSession:task:didCompleteWithError:)));
                XCTAssertEqualObjects(d.task.currentRequest.HTTPMethod, method);
            }
        }
    }
}

- (void)testHttpRedirectionWithCompleteRelativePath {
    NSString *urlString = @"http://httpbin.org/redirect-to?url=http%3A%2F%2Fhttpbin.org%2Fget";
    NSURL *url = [NSURL URLWithString:urlString];
    XCTestExpectation *te =
        [self expectationWithDescription:@"GET testHttpRedirectionWithCompleteRelativePath: with HTTP redirection"];
    YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
    [d runWithURL:url];
    [self waitForExpectationsWithTimeout:12 handler:nil];
    if (!d.error) {
        XCTAssertEqualObjects(d.result[@"url"],
                              @"http://httpbin.org/get",
                              @"testHttpRedirectionWithCompleteRelativePath returned an unexpected result");
    }
}

- (void)testHttpRedirectionWithInCompleteRelativePath {
    NSString *urlString = @"http://httpbin.org/redirect-to?url=%2Fget";
    NSURL *url = [NSURL URLWithString:urlString];
    XCTestExpectation *te =
        [self expectationWithDescription:@"GET testHttpRedirectionWithInCompleteRelativePath: with HTTP redirection"];
    YMHTTPRedirectionDataTask *d = [[YMHTTPRedirectionDataTask alloc] initWithExpectation:te];
    [d runWithURL:url];
    [self waitForExpectationsWithTimeout:12 handler:nil];
    if (!d.error) {
        XCTAssertEqualObjects(d.result[@"url"],
                              @"http://httpbin.org/get",
                              @"testHttpRedirectionWithCompleteRelativePath returned an unexpected result");
    }
}

- (void)testHttpRedirectionTimeout {
    XCTestExpectation *te =
        [self expectationWithDescription:@"GET testHttpRedirectionTimeout: timeout with redirection"];

    YMURLSessionConfiguration *config = [YMURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 5;
    YMURLSession *session = [YMURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];

    NSString *urlString = @"http://httpbin.org/redirect-to?url=%2Fdelay%2F10";
    NSURL *url = [NSURL URLWithString:urlString];

    YMURLSessionTask *task =
        [session taskWithURL:url
            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                if (!error) {
                    XCTFail("must fail");
                } else {
                    XCTAssertEqual(error.code, NSURLErrorTimedOut, @"Unexpected error code");
                }
                [te fulfill];
            }];
    [task resume];
    [self waitForExpectationsWithTimeout:12 handler:nil];
}

@end
