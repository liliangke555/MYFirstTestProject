//
//  OrderJD.m
//  kyExpress
//
//  Created by mu on 16/12/22.
//  Copyright © 2016年 kyExpress. All rights reserved.
//

#import "OrderJD.h"

static CGFloat const KTextFont = 12.0f;

@implementation OrderJD

+(NSArray *)RouteModelWithArr:(NSArray *)array {
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for(NSDictionary * dic in array){
        OrderJD *model = [[OrderJD alloc] init];
        model.time = dic[@"msgTime"];
        model.recode = dic[@"content"];
        
        [arrayM addObject:model];
    }
    for(int i = 0 ;i < arrayM.count/2;i++){
        [arrayM exchangeObjectAtIndex:i withObjectAtIndex:arrayM.count - i - 1];
    }
    return arrayM;
}

-(void)setRecode:(NSString *)recode
{
    _recode = recode;
    
    if ([_recode isKindOfClass:[NSNull class]]) {
        _recode = @"  ";
    }
    //屏幕比例转换
    CGFloat padding = 40 * ([UIScreen mainScreen].bounds.size.width/320.0);
    
    CGFloat recordW = [UIScreen mainScreen].bounds.size.width - padding - (110/320.0)*kSCREEN_WIDTH - 10;
    _contentH =[self caculateText:_recode fontSize:KTextFont maxSize:CGSizeMake(recordW, CGFLOAT_MAX)].height;
    NSLog(@"%f , %f",_contentH,recordW);
}

-(void)setTime:(NSString *)time {
    _time = time;
    
    if ([_time isKindOfClass:[NSNull class]]) {
        _time = @"  ";
    }
    _titleH =[self caculateText:_time fontSize:KTextFont maxSize:CGSizeMake((110/320.0)*kSCREEN_WIDTH, CGFLOAT_MAX)].height;
}

-(void)setState:(NSString *)state {
    _state = state;
    
    if ([_state isKindOfClass:[NSNull class]]) {
        _state = @"  ";
    }
    _stateH =[self caculateText:_state fontSize:KTextFont maxSize:CGSizeMake((110/320.0)*kSCREEN_WIDTH, CGFLOAT_MAX)].height;
}

-(CGSize)caculateText:(NSString *)str fontSize:(CGFloat)size maxSize:(CGSize)maxSize
{
    UIFont * font = [UIFont systemFontOfSize:size];
    return [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
}

/*根据传过来的文字内容、字体大小、宽度和最大尺寸动态计算文字所占用的size
 * text 文本内容
 * fontSize 字体大小
 * maxSize  size（宽度，1000）
 * return  size （计算的size）
 */
- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize;
    
    labelSize = [text boundingRectWithSize: maxSize
                                   options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine
                                attributes:attributes
                                   context:nil].size;
    
    labelSize.height=ceil(labelSize.height);
    labelSize.width=ceil(labelSize.width);
    return labelSize;
}

@end
