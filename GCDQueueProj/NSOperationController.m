//
//  NSOperationController.m
//  GCDQueueProj
//
//  Created by CHANGJIE DONG on 2017/12/22.
//  Copyright © 2017年 CHANGJIE DONG. All rights reserved.
//

#import "NSOperationController.h"

@interface NSOperationController ()

@end

@implementation NSOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test3{
    NSOperationQueue *asyncQueue=[[NSOperationQueue alloc]init];
    [asyncQueue addOperationWithBlock:^{
        //这里是你想做的操作....
    }];
//    自定义NSOperation可以参照AFURLConnectionOperation
}
- (void)test2{
    NSBlockOperation *op1=[NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"我是op1  我在第%@个线程",[NSThread currentThread]);
    }];
    [op1 addExecutionBlock:^{
        // 同一个block中的代码是同步执行的，即：使用同一个线程的block一定是等待前一个block的代码全部执行结束后才执行，且同步执行。
        NSLog(@"我是op1  我在第%@个线程",[NSThread currentThread]);
    }];
    NSBlockOperation *op2=[NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"我是op2  我在第%@个线程",[NSThread currentThread]);
    }];
    NSBlockOperation *op3=[NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"我是op3  我在第%@个线程",[NSThread currentThread]);
    }];
    [op3 setCompletionBlock:^{
        //回调到主队列
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }];
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}
- (void)test1{
    NSInvocationOperation *op1=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation1) object:nil];
    NSInvocationOperation *op2=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation2) object:nil];
    NSInvocationOperation *op3=[[NSInvocationOperation alloc]initWithTarget:self selector:@selector(testOperation3) object:nil];
    [op3 setCompletionBlock:^{
        //回调到主队列
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }];
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount=6;
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}

- (void)testOperation1{
    NSLog(@"我是op1  我在第%@个线程",[NSThread currentThread]);
}
- (void)testOperation2{
    NSLog(@"我是op2 我在第%@个线程",[NSThread currentThread]);
}
- (void)testOperation3{
    NSLog(@"我是op3 我在第%@个线程",[NSThread currentThread]);
}

@end
