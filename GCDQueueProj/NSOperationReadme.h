//
//  NSOperationReadme.h
//  GCDQueueProj
//
//  Created by CHANGJIE DONG on 2017/12/22.
//  Copyright © 2017年 CHANGJIE DONG. All rights reserved.
//

#ifndef NSOperationReadme_h
#define NSOperationReadme_h
#import <dispatch/dispatch.h>

#define NSOperationQualityOfService NSQualityOfService
#define NSOperationQualityOfServiceUserInteractive NSQualityOfServiceUserInteractive
#define NSOperationQualityOfServiceUserInitiated NSQualityOfServiceUserInitiated
#define NSOperationQualityOfServiceUtility NSQualityOfServiceUtility
#define NSOperationQualityOfServiceBackground NSQualityOfServiceBackground

@interface NSOperation : NSObject
- (void)main;
- (void)start;
- (void)cancel;
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isFinished) BOOL finished;
@property (nullable, copy) void (^completionBlock)(void) NS_AVAILABLE(10_6, 4_0);
- (void)waitUntilFinished NS_AVAILABLE(10_6, 4_0);
// 是否在执行、准备
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isReady) BOOL ready;
// 是否异步
@property (readonly, getter=isConcurrent) BOOL concurrent;
@property (readonly, getter=isAsynchronous) BOOL asynchronous NS_AVAILABLE(10_8, 7_0);
// 添加依赖关系有三点需要注意：1.不要建立循环依赖，会造成死锁，原因同循环引用。2.使用依赖建议只使用NSInvocationOperation，NSInvocationOperation和NSBlockOperation混用会导致依赖关系无法正常实现。3.依赖关系不光在同队列中生效，不同队列的NSOperation对象之前设置的依赖关系一样会生效。4. 添加依赖的代码最好放到添加队列之前，因为NSOperationQueue会在『合适』的时间自动去执行任务，因此你无法确定它到底何时执行，有可能前一秒添加的任务，在你这一秒准备添加依赖的时候就已经执行完了，就会出现依赖无效的假象。
- (void)addDependency:(NSOperation *)op;
- (void)removeDependency:(NSOperation *)op;
@property (readonly, copy) NSArray<NSOperation *> *dependencies;
// 线程信息
@property (nullable, copy) NSString *name NS_AVAILABLE(10_10, 8_0);
typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};
// 设置队列优先级，不过它并不总是起作用，因为线程优先级代表的是线程获取CPU时间片的能力，高优先级的执行概率高，不是执行顺序靠前。所以还是建议用依赖关系来控制流程。
@property NSOperationQueuePriority queuePriority;
@property NSQualityOfService qualityOfService;
@property double threadPriority NS_DEPRECATED(10_6, 10_10, 4_0, 8_0);
@end

// 支持并发的执行一个或多个block，它并非是将所有的block都放到放到了子线程中，它会优先将block放到主线程中执行，若主线程已有待执行的代码，就开辟新的线程，但最大并发数为4（包括主线程在内）。如果block数量大于了4，那么剩下的Block就会等待某个线程空闲下来之后被分配到该线程，且依然是优先分配到主线程。最大并发数和运行环境也是有关系的。
// 另外同一个block中的代码是同步执行的，即：使用同一个线程的block一定是等待前一个block的代码全部执行结束后才执行，且同步执行。
@interface NSBlockOperation : NSOperation
@property (readonly, copy) NSArray<void (^)(void)> *executionBlocks;
+ (instancetype)blockOperationWithBlock:(void (^)(void))block;
- (void)addExecutionBlock:(void (^)(void))block;
@end

/** NSInvocationOperation其实是同步执行的，因此单独使用的话，这个东西也没有什么卵用，它需要配合我们后面介绍的NSOperationQueue去使用才能实现多线程调用 */
@interface NSInvocationOperation : NSOperation
- (nullable instancetype)initWithTarget:(id)target selector:(SEL)sel object:(nullable id)arg;
- (instancetype)initWithInvocation:(NSInvocation *)inv;
@property (readonly, retain) NSInvocation *invocation;
@property (nullable, readonly, retain) id result;
@end

FOUNDATION_EXPORT NSExceptionName const NSInvocationOperationVoidResultException NS_AVAILABLE(10_5, 2_0);
FOUNDATION_EXPORT NSExceptionName const NSInvocationOperationCancelledException NS_AVAILABLE(10_5, 2_0);
static const NSInteger NSOperationQueueDefaultMaxConcurrentOperationCount = -1;

/** NSOperationQueue就是执行NSOperation的队列，我们可以将一个或多个NSOperation对象放到队列中去执行。NSInvocationOperation 和 NSBlockOperation是异步执行的，NSBlockOperation中的每一个Block也是异步执行且都在子线程中执行，每一个Block内部也依然是同步执行。 */
@interface NSOperationQueue : NSObject
// 把任务添加到执行队列中
- (void)addOperation:(NSOperation *)op;
- (void)addOperationWithBlock:(void (^)(void))block NS_AVAILABLE(10_6, 4_0);
// 把多个任务添加到执行队列中
- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait;
@property (readonly, copy) NSArray<__kindof NSOperation *> *operations;
@property (readonly) NSUInteger operationCount NS_AVAILABLE(10_6, 4_0);
- (void)waitUntilAllOperationsAreFinished;
// 执行队列名称、设置暂停、取消。这里需要强调的是，所谓的暂停和取消并不会立即暂停或取消当前操作，而是不在调用新的NSOperation。
@property (nullable, copy) NSString *name NS_AVAILABLE(10_6, 4_0);
@property (getter=isSuspended) BOOL suspended;
- (void)cancelAllOperations;
// 设置最大并发数：1.最大并发数是有上限的，即使你设置为100，它也不会超过其上限，而这个上限的数目也是由具体运行环境决定的。2.设置最大并发数一定要在NSOperationQueue初始化后立即设置，因为被放到队列中的NSOperation对象是由队列自己决定何时执行的，有可能你这边一添加立马就被执行，因此要想让设置生效一定要在初始化后立即设置。
@property NSInteger maxConcurrentOperationCount;
// <#函数内部注释#>
@property (class, readonly, strong, nullable) NSOperationQueue *currentQueue;
@property (class, readonly, strong) NSOperationQueue *mainQueue;
@property (nullable, assign) dispatch_queue_t underlyingQueue;
@property NSQualityOfService qualityOfService NS_AVAILABLE(10_10, 8_0);
@end

#endif /* NSOperationReadme_h */



@interface NSThread : NSObject
@property (class, readonly, strong) NSThread *currentThread;
@property (readonly, retain) NSMutableDictionary *threadDictionary;
@property (nullable, copy) NSString *name;
@property (readonly) BOOL isMainThread;
@property (class, readonly) BOOL isMainThread;
@property (class, readonly, strong) NSThread *mainThread;

+ (void)detachNewThreadWithBlock:(void (^)(void))block API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));
+ (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(nullable id)argument;
+ (BOOL)isMultiThreaded;
+ (void)exit;

+ (void)sleepUntilDate:(NSDate *)date;
+ (void)sleepForTimeInterval:(NSTimeInterval)ti;

+ (double)threadPriority;
+ (BOOL)setThreadPriority:(double)p;
@property double threadPriority NS_AVAILABLE(10_6, 4_0);
@property NSQualityOfService qualityOfService NS_AVAILABLE(10_10, 8_0);

@property (class, readonly, copy) NSArray<NSNumber *> *callStackReturnAddresses;
@property (class, readonly, copy) NSArray<NSString *> *callStackSymbols;
@property NSUInteger stackSize NS_AVAILABLE(10_5, 2_0);

#pragma mark - <#函数mark注释#>
- (instancetype)init;
- (instancetype)initWithTarget:(id)target selector:(SEL)selector object:(nullable id)argument;
- (instancetype)initWithBlock:(void (^)(void))block;
@property (readonly, getter=isExecuting) BOOL executing NS_AVAILABLE(10_5, 2_0);
@property (readonly, getter=isFinished) BOOL finished NS_AVAILABLE(10_5, 2_0);
@property (readonly, getter=isCancelled) BOOL cancelled NS_AVAILABLE(10_5, 2_0);
- (void)start NS_AVAILABLE(10_5, 2_0);
- (void)cancel NS_AVAILABLE(10_5, 2_0);
- (void)main NS_AVAILABLE(10_5, 2_0);
@end

FOUNDATION_EXPORT NSNotificationName const NSWillBecomeMultiThreadedNotification;
FOUNDATION_EXPORT NSNotificationName const NSDidBecomeSingleThreadedNotification;
FOUNDATION_EXPORT NSNotificationName const NSThreadWillExitNotification;
@interface NSObject (NSThreadPerformAdditions)
- (void)performSelectorInBackground:(SEL)aSelector withObject:(nullable id)arg;
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array;
// equivalent to the first method with kCFRunLoopCommonModes
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait;
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(nullable id)arg waitUntilDone:(BOOL)wait modes:(nullable NSArray<NSString *> *)array;
@end
