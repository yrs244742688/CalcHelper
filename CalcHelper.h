//
//  CalcHelper.h
//
//  Created by Mic on 2019/9/2.
//

#import <Foundation/Foundation.h>

@interface CalcHelper : NSObject

// 加
+ (NSDecimalNumber *)val:(id)valL add:(id)valR;
// 减
+ (NSDecimalNumber *)val:(id)valL subtract:(id)valR;
// 乘
+ (NSDecimalNumber *)val:(id)valL multi:(id)valR;
// 除
+ (NSDecimalNumber *)val:(id)valL divideBy:(id)valR;

// 转换: 可保证值的合法性，省去做非空和类型检测
+ (NSDecimalNumber *)valToDecimal:(id)val;
+ (NSString *)valToString:(id)val;

// 结果固定2位小数，四舍五入 (比如商品价格显示)
+ (NSString *)val_twoLenDecimal_fixed:(id)val;
// 结果最多2位小数，四舍五入 (比如商品跟踪报表显示)
+ (NSString *)val_twoLenDecimal_maximum:(id)val;

/* 字符串最低小数位数限制
 decimalPartMinLength: 最少需要多少位, 不够补0
 decimalPartMaxLength: 最多能有多少位，超过四舍五入
 */
+ (NSString *)valToString:(id)val
     decimalPartMinLength:(NSInteger)decimalPartMinLength
     decimalPartMaxLength:(NSInteger)decimalPartMaxLength;

+ (NSDecimalNumber *)valToDecimal:(id)val roundToScale:(NSInteger)scale;

// 测试
+ (void)test;

@end
