//
//  UIImage+ImageTool.m
//  新闻家天下
//
//  Created by zhangkai on 16/3/3.
//  Copyright © 2016年 zhangkai. All rights reserved.
//

#import "UIImage+ImageTool.h"

@implementation UIImage (ImageTool)
+(UIImage*)cricleImageWithImage:(UIImage*)image borderWidth:(CGFloat)borderWidth  borderColor:(UIColor*)borderColor{
    CGFloat imageH=image.size.height+borderWidth*2;
    CGFloat imageW=image.size.width+borderWidth*2;
    CGSize imageSize=CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);

    CGContextRef contextRef=UIGraphicsGetCurrentContext();
    
    [borderColor set];
    
    CGFloat radius=imageW/2;
    CGFloat centerX=radius;
    CGFloat centerY=radius;
    CGContextAddArc(contextRef, centerX, centerY, radius, 0, M_PI*2, 0);
    CGContextFillPath(contextRef);
    
    CGFloat smalleRadius=radius-borderWidth;
      CGContextAddArc(contextRef, centerX, centerY, smalleRadius, 0, M_PI*2, 0);
    
    CGContextClip(contextRef);
    
    [image drawInRect:CGRectMake(borderWidth, borderWidth , image.size.width , image.size.height)];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
