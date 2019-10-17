//
//  CalcHelper.m
//
//  Created by Mic on 2019/9/2.
//

#import "CalcHelper.h"

@implementation CalcHelper

+ (NSDecimalNumber *)val:(id)valL add:(id)valR {
    return [[self valToDecimal:valL] decimalNumberByAdding:[self valToDecimal:valR]];
}

+ (NSDecimalNumber *)val:(id)valL subtract:(id)valR {
    return [[self valToDecimal:valL] decimalNumberBySubtracting:[self valToDecimal:valR]];
}

+ (NSDecimalNumber *)val:(id)valL divideBy:(id)valR {
    if ([[self valToDecimal:valR] compare:@0] == NSOrderedSame) {
        return [NSDecimalNumber zero];
    } else {
        return [[self valToDecimal:valL] decimalNumberByDividingBy:[self valToDecimal:valR]];
    }
}

+ (NSDecimalNumber *)val:(id)valL multi:(id)valR {
    return [[self valToDecimal:valL] decimalNumberByMultiplyingBy:[self valToDecimal:valR]];
}

+ (NSDecimalNumber *)valToDecimal:(id)val {
    NSDecimalNumber *decimalNum = nil;
    if ([val isKindOfClass:[NSString class]]) {
        decimalNum = [NSDecimalNumber decimalNumberWithString:val];
    } else if ([val isKindOfClass:[NSNumber class]]) {
        decimalNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", val]];
    } else if ([val isKindOfClass:[NSDecimalNumber class]]) {
        decimalNum = (NSDecimalNumber *)val;
    } else {
        decimalNum = [NSDecimalNumber zero];
    }
    return [self makeDecimalNumberLegal:decimalNum];
}

+ (NSString *)valToString:(id)val {
    return [self valToDecimal:val].stringValue;
}

+ (NSDecimalNumber *)makeDecimalNumberLegal:(NSDecimalNumber *)originNum {
    if (!originNum || [[NSDecimalNumber notANumber] isEqualToNumber:originNum]) {
        return [NSDecimalNumber zero];
    } else {
        return originNum;
    }
}

+ (NSDecimalNumber *)valToDecimal:(id)val roundToScale:(NSInteger)scale {
    NSDecimalNumberHandler *handler =
    [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                           scale:scale
                                                raiseOnExactness:NO
                                                 raiseOnOverflow:NO
                                                raiseOnUnderflow:NO
                                             raiseOnDivideByZero:YES];
    return [[self valToDecimal:val] decimalNumberByRoundingAccordingToBehavior:handler];
}

/* 字符串最低小数位数限制
 decimalPartMinLength: 最少需要多少位, 不够补0
 decimalPartMaxLength: 最多能有多少位，超过四舍五入
 */
+ (NSString *)valToString:(id)val
     decimalPartMinLength:(NSInteger)decimalPartMinLength
     decimalPartMaxLength:(NSInteger)decimalPartMaxLength
{
    if (decimalPartMaxLength < 0) {
        decimalPartMaxLength = 0;
    }
    if (decimalPartMaxLength < 0) {
        decimalPartMaxLength = 2;
    }
    if (decimalPartMaxLength < decimalPartMinLength) {
        decimalPartMaxLength = decimalPartMinLength;
    }
    NSString *string = [self valToDecimal:val roundToScale:decimalPartMaxLength].stringValue;
    
    if (decimalPartMinLength <= 0) {
        return string;
    } else {
        // 如果不包含小数点，把小数点加上
        if (![string containsString:@"."]) {
            string = [string stringByAppendingString:@"."];
        }
        
        // 看一下小数点后面有多少位
        NSUInteger nowLenAfterPont = 0;
        NSArray *compot = [string componentsSeparatedByString:@"."];
        if (compot.count < 2) {
            // 小数点后面没有值
            nowLenAfterPont = 0;
        } else {
            nowLenAfterPont = ((NSString *)[compot lastObject]).length;
        }
        
        // 比较现在的小数位数和最低要求的小数位数
        if (nowLenAfterPont >= decimalPartMinLength) {
            return string;
        } else {
            // 补0
            for (int i = 0; i<(decimalPartMinLength - nowLenAfterPont); i++) {
                string = [string stringByAppendingString:@"0"];
            }
            return string;
        }
    }
}

#pragma mark- 一些用的很多的场景
// 固定2位小数，四舍五入 (比如商品价格显示)
+ (NSString *)val_twoLenDecimal_fixed:(id)val {
    return [self valToString:val decimalPartMinLength:2 decimalPartMaxLength:2];
}

// 最多2位小数，四舍五入 (比如商品跟踪报表显示)
+ (NSString *)val_twoLenDecimal_maximum:(id)val {
    return [self valToString:val decimalPartMinLength:0 decimalPartMaxLength:2];
}

#pragma mark- Test
+ (void)test {
    [self test_valToDecimal];
    [self test_DecimalLengthControl];
    [self test_Add];
    [self test_Sub];
    [self test_Mult];
    [self test_Divide];
}
+ (void)test_valToDecimal {
    NSLog(@"-----不同类型val转换控制-----");
    NSLog(@"null to: %@", [self valToDecimal:[NSNull null]]);
    NSLog(@"numstring to: %@", [self valToDecimal:@"1.23"]);
    NSLog(@"num to: %@", [self valToDecimal:@9.88]);
    NSLog(@"text to: %@", [self valToDecimal:@"测试"]);
}

+ (void)test_DecimalLengthControl {
    
    // 小数位截取控制
    NSLog(@"-----小数位截取控制-----");
    NSString *val = @"1.03005";
    NSLog(@"期望1: %@", [self valToString:val decimalPartMinLength:0 decimalPartMaxLength:0]);
    NSLog(@"期望1.0: %@", [self valToString:val decimalPartMinLength:1 decimalPartMaxLength:1]);
    NSLog(@"期望1.03: %@", [self valToString:val decimalPartMinLength:0 decimalPartMaxLength:2]);
    NSLog(@"期望1.030: %@", [self valToString:val decimalPartMinLength:3 decimalPartMaxLength:3]);
    NSLog(@"期望1.0301: %@", [self valToString:val decimalPartMinLength:4 decimalPartMaxLength:4]);
    NSLog(@"期望1.03005: %@", [self valToString:val decimalPartMinLength:5 decimalPartMaxLength:5]);
    
    // 是整数就显示整数，有小数就显示小数，但是最多2位小数
    NSLog(@"-----是整数就显示整数，有小数就显示小数，但是最多2位小数-----");
    NSString *val1 = @"1";
    NSString *val2 = @"0.3";
    NSString *val3 = @"0.324";
    NSString *val4 = @"0.326";
    NSLog(@"期望1: %@", [self valToString:val1 decimalPartMinLength:0 decimalPartMaxLength:2]);
    NSLog(@"期望0.3: %@", [self valToString:val2 decimalPartMinLength:0 decimalPartMaxLength:2]);
    NSLog(@"期望0.32: %@", [self valToString:val3 decimalPartMinLength:0 decimalPartMaxLength:2]);
    NSLog(@"期望0.33: %@", [self valToString:val4 decimalPartMinLength:0 decimalPartMaxLength:2]);
    
    // 不管怎样都显示2位小数
    NSLog(@"-----不管怎样都显示2位小数-----");
    NSLog(@"期望1.00: %@", [self valToString:val1 decimalPartMinLength:2 decimalPartMaxLength:2]);
    NSLog(@"期望0.30: %@", [self valToString:val2 decimalPartMinLength:2 decimalPartMaxLength:2]);
    NSLog(@"期望0.32: %@", [self valToString:val3 decimalPartMinLength:2 decimalPartMaxLength:2]);
    NSLog(@"期望0.33: %@", [self valToString:val4 decimalPartMinLength:2 decimalPartMaxLength:2]);
}

+ (void)test_Add {
    // 加
    NSLog(@"-----加-----");
    NSNull *val1 = [NSNull null];
    NSNumber *val2 = @2.305;
    NSString *val3 = @"1.00";
    NSDecimalNumber *val4 = [NSDecimalNumber zero];
    
    NSLog(@"期望2.305: %@", [self val:val1 add:val2].stringValue);
    NSLog(@"期望1: %@", [self val:val3 add:val4].stringValue);
}

+ (void)test_Sub {
    // 减
    NSLog(@"-----减-----");
    NSNull *val1 = [NSNull null];
    NSNumber *val2 = @2.305;
    NSString *val3 = @"1.00";
    NSDecimalNumber *val4 = [NSDecimalNumber zero];
    
    NSLog(@"期望-2.305: %@", [self val:val1 subtract:val2].stringValue);
    NSLog(@"期望1: %@", [self val:val3 subtract:val4].stringValue);
    NSLog(@"期望1.305: %@", [self val:val2 subtract:val3].stringValue);
}

+ (void)test_Mult {
    // 乘
    NSLog(@"-----乘-----");
    NSNull *val1 = [NSNull null];
    NSNumber *val2 = @2.305;
    NSString *val3 = @"2.00";
    NSDecimalNumber *val4 = [NSDecimalNumber zero];
    
    NSLog(@"期望0: %@", [self val:val1 multi:val2].stringValue);
    NSLog(@"期望0: %@", [self val:val3 multi:val4].stringValue);
    NSLog(@"期望4.61: %@", [self val:val3 multi:val2].stringValue);
}

+ (void)test_Divide {
    // 除
    NSLog(@"-----除-----");
    NSNull *val1 = [NSNull null];
    NSNumber *val2 = @2.305;
    NSString *val3 = @"2.00";
    NSDecimalNumber *val4 = [NSDecimalNumber zero];
    
    NSLog(@"期望0: %@", [self val:val1 divideBy:val2].stringValue);
    NSLog(@"期望0: %@", [self val:val3 divideBy:val4].stringValue);
    NSLog(@"期望1.1525: %@", [self val:val2 divideBy:val3].stringValue);
}

@end
