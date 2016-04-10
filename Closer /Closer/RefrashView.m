//
//  RefrashView.m
//  mpp
//
//  Created by 李辉 on 16/3/18.
//  Copyright © 2016年 李辉. All rights reserved.
//

#import "RefrashView.h"

@implementation RefrashView

-(void)drawRect:(CGRect)rect{
   CGContextRef context = UIGraphicsGetCurrentContext();
//    UIBezierPath*patch=[[UIBezierPath alloc]init];
//    [patch addArcWithCenter:CGPointMake(150, 150) radius:150 startAngle:0 endAngle:M_PI *2 clockwise:YES];
    
    
    CGFloat x=self.frame.size.width/2;
    CGFloat y=self.frame.size.height/2;
     UIColor*aColor = [UIColor colorWithRed:0.3 green:0.5 blue:0.2 alpha:0.3];
    CGContextAddArc(context, x, y, x, 0, 2*M_PI, 0);
    
    
//    [[UIColor yellowColor]setFill];
    
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
  
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextDrawPath(context, kCGPathFillStroke);
  
    UIColor*BColor = [UIColor colorWithRed:1 green:0.1 blue:0.2 alpha:0.3];
    CGContextAddArc(context, x, y, x*0.7, 0, 2*M_PI, 0);
    
    
    //    [[UIColor yellowColor]setFill];
    
    CGContextSetFillColorWithColor(context, BColor.CGColor);
    
    
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextDrawPath(context, kCGPathFillStroke);

    
    
    for (int i=0; i<60; i++) {
        UIColor *color=[UIColor colorWithRed:0.1+i*(0.7/60) green:0.02 blue:0.1 alpha:0.05+i*(0.85/60)];
        CGContextMoveToPoint(context, x, y);
        CGContextAddArc(context, x, x, x, (i-1)*(M_PI/180), i*(M_PI/180), 0);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        
        CGContextDrawPath(context, kCGPathFill);
        
        CGContextDrawPath(context, kCGPathFillStroke);

    }
//    UIColor*  aColor1 = [UIColor colorWithRed:0.3 green:0.1 blue:0.7 alpha:0.4];
//    CGContextSetFillColorWithColor(context, aColor1.CGColor);//填充颜色
//    //以10为半径围绕圆心画指定角度扇形
//    CGContextMoveToPoint(context, 150, 150);
//    CGContextAddArc(context, 150, 150, 150,  -120 * M_PI / 180, -150 * M_PI / 180, 1);
////    CGContextClosePath(context);
//    CGContextDrawPath(context, kCGPathFill);
//
//    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    
//    for (int i=0; i<1000; i++) {
//        UIBezierPath *patch2=[UIBezierPath bezierPath];
//        [patch2 addArcWithCenter:CGPointMake(150, 150) radius:150 startAngle:(M_PI/180)*(i-1) endAngle:(M_PI/180)*i clockwise:YES];
//        
//        [[UIColor colorWithRed:100/255 green:(100-2i)/255 blue:80/255 alpha:(30-i)/150] setFill];
//        [[UIColor blueColor ]setFill];
//        
//        [patch2 stroke];
//        [patch2 fill];
//    }
    
    
    
    
}











/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
