## 前言
* 在iOS底层源码学习中，会需要分析一个结构体所占用的内存大小，这里面就涉及到了**内存对齐**
* 今天，我将结合内存对齐的概念、原因、规则、实际例子，让你深入理解内存对齐，掌握分析结构体所占内存大小的方法。
![目录](https://upload-images.jianshu.io/upload_images/2351207-41dafd4d10c41464.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 简介
内存对齐”应该是编译器的“管辖范围”。编译器为程序中的每个“数据单元”安排在适当的位置上。如果你想了解更加底层的秘密，探究“内存对齐”对你就不应该再模糊了。

* 平台原因(移植原因)：不是所有的硬件平台都能访问任意地址上的任意数据的；某些硬件平台只能在某些地址处取某些特定类型的数据，否则抛出硬件异常。
* 性能原因：数据结构(尤其是栈)应该尽可能地在自然边界上对齐。原因在于，为了访问未对齐的内存，处理器需要作两次内存访问；而对齐的内存访问仅需要一次访问。


特别对于我们学习底层源码，是需要掌握的知识点之一，下面我就结合[百度百科-内存对齐](![image.png](https://upload-images.jianshu.io/upload_images/2351207-8211323b55edff05.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
)以及实际的demo进行详细分析。

## 规则定义
* 规则1、数据成员对齐规则：结构(struct)(或联合(union))的数据成员，第一个数据成员放在offset为0的地方，以后每个数据成员的对齐，按照#pragma pack指定的数值和这个数据成员自身长度中，比较小的那个进行。

* 规则2、结构(或联合)的整体对齐规则：在数据成员完成各自对齐之后，结构(或联合)本身也要进行对齐，对齐将按照#pragma pack指定的数值和结构(或联合)最大数据成员长度中，比较小的那个进行。

* 规则3、结合1、2可推断：当#pragma pack的n值等于或超过所有数据成员长度的时候，这个n值的大小将不产生任何效果。

## 规则解析
* 规则1中表明数据成员的存放是按照定义的顺序依次存放的
* \#pragma pack是对齐系数，每个平台不一样，程序员可以通过预编译命令#pragma pack(n)，n=1,2,4,8,16来改变这一系数（32位平台一般为4，64位平台一般为8）。iOS下默认为8。这个数值大家可以通过调试#pragma pack(n)测试验证得到。
* 规则1，当第x(x>1)个成员y存放的时候，y按照min(n,m)来对齐存放，其中n为对齐系数，m为成员y的数据类型长度。
* 在完成各个数据成员的存放排列后，通过规则2，取max(n,maxM)进行对齐，其中n为对齐系数，maxM为所有数据成员类型中长度的最大值。


## 实例分析
demo例子中我们定义具有相同类型和个数成员的结构体，但是其定义的顺序不同成员不同，并对其进行赋值，然后结合规则，详细进行分析。
##### 基础知识点介绍
 1.一个字节包含8个二进制位
 2.一个十六进制位可用4个二进制位表示
 3.一个字节可以由2个十六进制位表示
0x0000 0000 0000 0008表示16个16进制位，可以表示8个字节
所以8可以用8个字节0x0000 0000 0000 0008表示，或者4个字节0x0000 0008，或者2个字节0x0008，取决于定义8的数据类型。
字符'a'换成ASCII码为97，可以用 0x61表示。
此外，iOS系统的编译平台是按照小端法进行编译。

下面进入具体的实例分析，
环境：
**Xcode 11.3.1,Deployment Target:10.15**
代码如下：
CommandLineTool类型工程的main.m文件中
```

#import <Foundation/Foundation.h>

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
        MyPerson2.a = 'a';
        MyPerson2.c = 14;
        MyPerson2.d = 12;
        
        MyPerson3.b = 28;
        MyPerson3.c = 24;
        MyPerson3.a = 'a';
        MyPerson3.d = 22;
        NSLog(@"Adress=======MyPerson1:%p,MyPerson2:%p,MyPerson3:%p",&MyPerson1,&MyPerson2,&MyPerson3);  
        NSLog(@"Size=======MyPerson1:%lu,MyPerson2:%lu,MyPerson3:%lu",sizeof(MyPerson1),sizeof(MyPerson2),sizeof(MyPerson3));

    }
    return 0;
}

```
#### 分析MyPerson1
```
struct Person1 {
    char a;
    long b;
    int c;
    short d;
}MyPerson1;
```

* 第一个成员char类型的成员a='a'占用1字节，此时:
 a: 0x61
* 第二个成员long类型的成员b=8占用8个字节，根据规则解析3，b=8按照min(8,8)=8对齐，b的起始位置为8的倍数，不满足，a需要补齐7个字节保证b的起始位置为8的倍数
此时：
a:0000 0000 0000 0061 
b:0x0000 0000 0000 0008
* 第三个成员int类型的成员c=4占用4个字节,根据规则解析3，整数c=4需要按照min(8,4)=4进行对齐，c的起始位置需要为4的整数倍，现在已经满足
此时：
a:0000 0000 0000 0061 
b:0x0000 0000 0000 0008 
c:0x0000 0004
* 第四个成员short类型的整数d=2占用2个字节，根据规则解析3，d按照min(8,2)=2进行对齐，d的起始位置需要为2的整数倍，现在已经满足
此时：
a:0000 0000 0000 0061 
b:0x0000 0000 0000 0008 
c:0x0000 0004 
d:0x0002

* 根据规则解析4，结构体需要进行整体对齐，取max(n,maxDataLength) = max(8,8) = 8对齐，现在为8+8+4+2=22字节，需要补2个字节，按照排列顺序，在d占用内存段补2个字节;

* 最后得到 
a:0000 0000 0000 0061 
b:0x0000 0000 0000 0008 
c:0x0000 0004
d:0000 0002
**其中我们看把c和d看成共占用一段8字节的内存，因为对齐系数为8，编译器按照8的整数倍来读取内存地址**。
* 按照小端法进行修正，此时内存排列应该内应该是 
**a:0000 0000 0000 0061 
b:0x0000 0000 0000 0008 
dc:0x0000 0002 0000 0004**，
其中dc:0x0000 0002 0000 0004的第**1-8**位表示成员d的值，右边第**9-16**位表示成员c的值

* 综上,MyPerson1结构体整体占用**8+8+8=24**字节
#### 分析MyPerson2
```
struct Person2 {
    long b;
    char a;
    int c;
    short d;
}MyPerson2;

```
* 第一个成员long类型的成员b=18占用8字节，此时：
b:0x0000 0000 0000 0012
* 第二个成员char类型的成员a='b'占用1个字节，根据规则解析3，a按照min(8,1)=1对齐，a的起始位置需要为1的整数倍，已经满足，此时：
b:0x0000 0000 0000 0012  
a:0x62
* 第三个成员int类型的成员c=14占用4个字节,根据规则解析3，c按照min(8,4)=4进行对齐，c的起始位置需要未4的整数倍，不满足，所以成员a='b'需要补齐3个字节， 此时：
b:0x0000 0000 0000 0012  
a:0x0000 0062 
c:0x0000 000e
* 第四个成员short类型的成员d=12占用2个字节，根据规则解析3，成员d按照min(8,2)=2进行对齐,起始位置需要为2的整数倍，已经满足，此时 ：
b:0x0000 0000 0000 0012  
a:0x0000 0062 
c:0x0000 000e 
d:000c

* 根据规则解析4，结构体需要进行整体对齐，取max(n,maxDataLength) = max(8,8) = 8对齐， 现在占用8+4+4+2=18个字节，需要补6个字节，按照排列顺序，在d占用的内存段补6个字节
* 最后得到 ：
b:0x0000 0000 0000 0012  
a:0x0000 0062 
c:0x0000 000e 
d:0000 0000 0000 000c，**其中我们看把a、c看成共占用一段8字节的内存，因为对齐系数为8，编译器按照8的整数倍来读取内存地址**
* 按照小端法修正，此时真正的内存排列应该内应该是：
**b:0x0000 0000 0000 0012  
ca:0x0000 000e 0000 0062  
d:0x0000 0000 0000 000c ，** 
其中ca:0x0x0000 000e 0000 0062 的第**1-8**位表示c的值，第**9-16**表示a的值
 
* 综上，MyPerson2整体占用**8+8+8=24**个字节


#### 分析MyPerson3
```
struct Person3 {
    long b;
    int c;
    char a;
    short d;
}MyPerson3;
```
* 第一个成员long类型的成员b=28占用8字节，此时：
 b:0x0000 0000 0000 001c

* 第二个成员int类型的成员c=24占用4个字节，根据规则1, 成员c按min(8,4)=4对齐，c的起始位置需要为4的整数倍，已经满足，此时：
b:0x0000 0000 0000 001c  
c:0x0000 0018

* 第三个成员char类型的成员a='c'占用1个字节,根据规则1，成员a按min(8,1)=1进行对齐此时：
b:0x0000 0000 0000 001c  
c:0x0000 0018  
a:0x63

* 第四个成员short类型的成员d=22占用2个字节，根据规则1，成员d按照min(8,2)=2进行对齐,d的起始位置需要为2的整数倍，因此成员a需要补1字节，此时：
b:0x0000 0000 0000 001c  
c:0x0000 0018  
a:0x0063 
d:0x0016
* 根据规则解析4，结构体需要进行整体对齐，取max(n,maxDataLength) = max(8,8) = 8对齐，但是现在占用8+4+2+2=16个字节，已经满足了
* 最后得到：
b:0x0000 0000 0000 001c  
c:0x0000 0018 
a:0063 
d:0016，**其中我们看把c、a、d看成共占用一段8字节的内存，因为对齐系数为8，编译器按照8的整数倍来读取内存地址**
* 按照小端法修正，此时真正的内存排列应该内应该是 最后得到 
**b:0x0000 0000 0000 001c  
dac:0x0016 0063 0000 0018**  ,其中dac:0x0016 0063 0000 0018的左边第**1-4**位表示d存储的值，左边第**5-8**位表示a存储的值，右边第**9-16**位表示c存储的值
*综上，***MyPerson3结构体整体占用8+8=16个字节**

#### 验证
如图输出结构体成员信息
![lldb输出.png](https://upload-images.jianshu.io/upload_images/2351207-8eb066063572bf14.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


* 我们把各个结构体的地址打印出来，然后利用lldb的x/4gx命令输出各个结构体里面的从第一个成员的起始位置开始的4段8字节内存信息
* **x/4gx 0x100002020**表示打印从MyPerson1的成员a='a'开始的4段内存信息，其中前3段 0x0000000000000061 0x0000000000000008，0x0000000200000004和我们前面分析的MyPerson1得出的内存表示一致，最后一段0x0000000000000012不属于MyPerson1，代表MyPerson2的成员b=18内存表示
* **x/4gx 0x100002038**表示打印从MyPerson2的成员b=18开始的4段内存信息，其中前**3**段 0x0000000000000012，0x0000000e00000062, 0x000000000000000c和我们前面分析的MyPerson2得出的内存表示一致，最后一段0x000000000000001c不属于MyPerson2，代表MyPerson3的成员b=28的内存表示
* **x/4gx 0x100002050** 表示打印从MyPerson3的成员b=28开始的4段内存信息，其中前**2**段 0x000000000000001c，0x0016006300000018和我们前面分析的MyPerson2得出的内存表示一致，后面2段0x0000000000000000不属于MyPerson3

#### 优化lldb的打印输出如下
![优化输出](https://upload-images.jianshu.io/upload_images/2351207-6149d32dfedd1379.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 通过优化输出可以看到lldb输出的内存表示与我们前面实例分析的是一致。

#### OC对象分析
#### 仿照上面的3个结构体定义3个类Teacher1,Teacher2,Teacher3
```
@interface Teacher1 : NSObject

@property (nonatomic, assign) char a;
@property (nonatomic, assign) long b;
@property (nonatomic, assign) int c;
@property (nonatomic, assign) short d;

@end
```

```
@interface Teacher2 : NSObject

@property (nonatomic, assign) long b;
@property (nonatomic, assign) char a;
@property (nonatomic, assign) int c;
@property (nonatomic, assign) short d;

@end
```

```
@interface Teacher3 : NSObject

@property (nonatomic, assign) int c;
@property (nonatomic, assign) long b;
@property (nonatomic, assign) char a;
@property (nonatomic, assign) short d;

@end
```
main.m中添加如下代码

```
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
```

##### 对象的输出如下
![image.png](https://upload-images.jianshu.io/upload_images/2351207-0ba2cac001c5c126.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

* 可以看到，3个对象的第2个八字节和第三个八字节这2个内存段存储了我们定义的成员变量a、b、c、d的值，说明编译器做了相应的优化，不会直接按照我们在类中定义成员的顺序生成构造对应的结构体
* 3个对象的第一个八字节存储着各自isa的值



##### 源码地址
[MemoryAlignment](https://github.com/002and001/MemoryAlignment)

### 总结
* 本文主要对内存对齐的规则进行介绍和并结合实际的demo例子对结构体和对象进行详细分析
