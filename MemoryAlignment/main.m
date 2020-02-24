//
//  main.m
//  MemoryAlignment
//
//  Created by 002and001 on 2020/2/22.
//  Copyright © 2020 002. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "Teacher1.h"
#import "Teacher2.h"
#import "Teacher3.h"


//#pragma pack(1)
//#pragma pack(2)
//#pragma pack(4)
//#pragma pack(8) // 默认为8
//#pragma pack(16)

struct Person1 {
    char a;
    long b;
    int c;
    short d;
}MyPerson1;

struct Person2 {
    long b;
    char a;
    int c;
    short d;
}MyPerson2;

struct Person3 {
    long b;
    int c;
    char a;
    short d;
}MyPerson3;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        MyPerson1.a = 'a';
        MyPerson1.b = 8;
        MyPerson1.c = 4;
        MyPerson1.d = 2;
        
        MyPerson2.b = 18;
        MyPerson2.a = 'b';
        MyPerson2.c = 14;
        MyPerson2.d = 12;
        
        MyPerson3.b = 28;
        MyPerson3.c = 24;
        MyPerson3.a = 'c';
        MyPerson3.d = 22;
        NSLog(@"Adress=======MyPerson1:%p,MyPerson2:%p,MyPerson3:%p",&MyPerson1,&MyPerson2,&MyPerson3);
NSLog(@"Size=======MyPerson1:%lu,MyPerson2:%lu,MyPerson3:%lu",sizeof(MyPerson1),sizeof(MyPerson2),sizeof(MyPerson3));
        
        Teacher1 *t1 = [[Teacher1 alloc] init];
        t1.a = 'a';
        t1.b = 8;
        t1.c = 4;
        t1.d = 2;
        
        Teacher2 *t2 = [[Teacher2 alloc] init];
        t2.b = 18;
        t2.a = 'b';
        t2.c = 14;
        t2.d = 12;
        
        Teacher3 *t3 = [[Teacher3 alloc] init];
        t3.b = 28;
        t3.c = 24;
        t3.a = 'c';
        t3.d = 22;
        
        NSLog(@"Adress=======t1:%p,t2:%p,t3:%p",&t1,&t2,&t3);
    }
    return 0;
}
