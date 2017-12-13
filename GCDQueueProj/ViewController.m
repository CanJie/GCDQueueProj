//
//  ViewController.m
//  GCDQueueProj
//
//  Created by CHANGJIE DONG on 2017/12/13.
//  Copyright © 2017年 CHANGJIE DONG. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)test7{
    //一、方式一适合任务代码是同步执行的情况
    dispatch_group_t group = dispatch_group_create();
    // 某个任务放进 group
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 任务代码1
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 任务代码2
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 任务全部完成处理
        NSLog(@"isover");
    });
    
    //二、方式二适合任务代码是异步执行的情况
    dispatch_group_t group = dispatch_group_create();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 3; i ++){
            //在任务开始前 调用 enter
            dispatch_group_enter(group);
            // 任务代码...
            
            //任务完成时调用leave
            dispatch_group_leave(group);
        }
    });
    //dispatch_group_wait函数是阻塞的:wait函数一直阻塞，直到它发现group里面的任务全部leave，它才放弃阻塞（任务全部完成）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    //dispatch_group_notify函数会隐式retain 当先的调用者，在使用的时候要知道这一点
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //然后我们在主线程更新UI告知用户
    });
}
- (void)test6{
    /**
     *  GCD 小结:http://www.jianshu.com/p/21956cfedb38
     *  一、 同步/异步、串行/并行的区别
     1.同步/异步
     同步/异步是指线程与线程之间的关系.
     2.串行/并行
     串行/并行是指队列内部任务与任务之间的关系.
     如果是串行队列,那么队列内部的任务是按顺序执行的,主线程队列是串行的。
     如果是并行队列, 那么队列内部的任务执行是无序的, 没有先后顺序,全局队列是并行的。
     *  二、几种常见的任务处理方式
     1. 异步串行队列:队列中所有任务在异步线程中按顺序执行
     2. 异步并行队列:队列中所有任务在异步线程并行执行, 无先后顺序
     3. 异步串行队列, 并在任务完成后进行通知
     4. 异步并行队列, 并在任务完成后进行通知
     */
    //    1. 异步串行队列:队列中所有任务在异步线程中按顺序执行
    dispatch_queue_t queue=dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"------- %d", i);
        });
    }
    //    2. 异步并行队列:队列中所有任务在异步线程并行执行, 无先后顺序
    dispatch_queue_t queue2=dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue2, ^{
            NSLog(@"------- %d", i);
        });
    }
    //        3. 异步串行队列, 并在任务完成后进行通知
    dispatch_group_t group=dispatch_group_create();
    dispatch_queue_t queue3=dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, queue3, ^{
            NSLog(@"------- %d", i);
        });
    }
    dispatch_group_notify(group, queue3, ^{
        NSLog(@"任务执行完毕!");
    });
    //        4. 异步并行队列, 并在任务完成后进行通知
    dispatch_group_t group2=dispatch_group_create();
    dispatch_queue_t queue4=dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group2, queue4, ^{
            NSLog(@"------- %d", i);
        });
    }
    dispatch_group_notify(group2, queue4, ^{
        NSLog(@"任务执行完毕!");
    });
}
- (void)test5{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore1 = dispatch_semaphore_create(0);
    dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
    //一、开启三个异步线程：获取网络和缓存途径数据
    dispatch_async(concurrentQueue, ^{
#warning TODO <#待处理事项#>
        
        //通知第1个信号量；
        dispatch_semaphore_signal(semaphore1);
    });
    
    //二、从其他途径构造数据源
    dispatch_async(concurrentQueue, ^{
        //第1个信号量等待；
        dispatch_semaphore_wait(semaphore1, DISPATCH_TIME_FOREVER);
#warning TODO <#待处理事项#>
        
        //通知第2个信号量；
        dispatch_semaphore_signal(semaphore2);
    });
    //三、构造视图数据源
    dispatch_async(concurrentQueue, ^{
        //第2个信号量等待；
        dispatch_semaphore_wait(semaphore2, DISPATCH_TIME_FOREVER);
#warning TODO <#待处理事项#>
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}
- (void)test4{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.OperationBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    __block NSInteger count=0;
    for (<#type#> *<#model#> in <#list#>) {
        dispatch_barrier_async(concurrentQueue, ^{
            BOOL success=<#expression#>;
            if (success) {
                count++;
            }else{
                count--;
            }
        });
    }
    dispatch_barrier_async(concurrentQueue, ^{
        if (<#block#> && count==<#list#>.count) {
            <#block#>(YES);
        }else{
            <#block#>(NO);
        }
    });
}
- (void)test3{
    dispatch_queue_t targetQueue = dispatch_queue_create("tablename.target.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue1 = dispatch_queue_create("tablename.delete", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("tablename.insertupdate", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue3 = dispatch_queue_create("tablename.judgment", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_set_target_queue(queue3, targetQueue);
    
    dispatch_async(queue1, ^{
        
    });
    dispatch_async(queue2, ^{
        
    });
    dispatch_async(queue3, ^{
        
    });
}
- (void)test2{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        // some one-time task
        
    });
}
- (void)test1{
    //全局并发队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#warning TODO <#message#>
        
        //发送异步网路请求
        NSURL *url = [NSURL URLWithString:@""];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            //回调到主队列
            dispatch_async(dispatch_get_main_queue(), ^{
                if (connectionError) {
                    NSLog(@"发送异步请求响应错误信息：%@",connectionError);
                }else{
                    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    
                }
            });
        }];
    });
}


@end
