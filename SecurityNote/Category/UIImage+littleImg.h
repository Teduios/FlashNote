//
//  UIImage+littleImg.h
//  sentMail
//
//  Created by xuyao on 16/4/23.
//  Copyright © 2016年 xuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (littleImg)
-(UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
@end
