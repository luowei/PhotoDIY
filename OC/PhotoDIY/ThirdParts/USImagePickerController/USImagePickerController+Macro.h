//
//  USImagePickerController+Macro.h
//  USImagePickerController
//
//  Created by marujun on 16/7/14.
//  Copyright © 2016年 marujun. All rights reserved.
//

#define USSYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

/**
 *  8.1以下的系统获取不到相机胶卷，继续使用ALAssetsLibrary
 *  在iPad设备上使用但是"project target"设置的是"iPhone mode"，9.3以下的系统继续使用ALAssetsLibrary
*/
#define PHPhotoLibraryClass ((USSYSTEM_VERSION_LESS_THAN(@"8.1") || ([PHAsset targetSizeNeedsSupportiPad] && USSYSTEM_VERSION_LESS_THAN(@"9.3")))?nil:NSClassFromString(@"PHPhotoLibrary"))

/**
 注意事项：
  8.1~8.2：即使PHImageRequestOptions的resizeMode设置为PHImageRequestOptionsResizeModeExact，使用requestImageForAsset获取到的图片尺寸也和设置的targetSize不一致；并且获取PHPhotoLibrary的速度特别慢！
  8.3~8.4：当图片的imageOrientation不是UIImageOrientationUp时，使用requestImageForAsset获取到的图片尺寸和设置的targetSize的宽高是颠倒的；如果PHImageRequestOptions设置了normalizedCropRect，返回的图片内容和设置的裁剪区域的内容完全不一样！
  http://stackoverflow.com/questions/30288789/requesting-images-to-phimagemanager-results-in-wrong-image-in-ios-8-3
 
  所以想要正常使用一些高级功能没有BUG，还是只支持到iOS9吧；如果只是简单的用于获取全屏图和原图可以从iOS8开始支持！！！
 
  "project target"设置的是"iPhone mode"，但是在iPad设备上使用的情况下：iPadAir,iPadAir2,iPadPro，iPadMini 无法获取缩略图；在iOS 9.3以上系统获取图片时设置短边大于500可以解决这个问题，但是9.3以下的系统只能通过使用ALAsset来解决
*/

/**
 Supported Image Formats
 
 Table C-2 lists the image formats supported directly by iOS.
 
 | Format                                   | Filename extensions  |
 | :--------------------------------------- | :------------------- |
 | Portable Network Graphic (PNG)           | .png                 |
 | Tagged Image File Format (TIFF)          | .tiff or .tif        |
 | Joint Photographic Experts Group (JPEG)  | .jpeg or .jpg        |
 | Graphic Interchange Format (GIF)         | .gif                 |
 | Windows Bitmap Format (DIB)              | .bmp or .BMPf        |
 | Windows Icon Format                      | .ico                 |
 | Windows Cursor                           | .cur                 |
 | XWindow bitmap                           | .xbm                 |
 
 Of these formats, the PNG format is the one most recommended for use in your apps.
 Generally, the image formats that UIKit supports are the same formats supported by the Image I/O framework.
 
 */

#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#ifdef DEBUG
#define USPickerLog(fmt,...)    NSLog((@"[%@][%d] " fmt),[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,##__VA_ARGS__)
#else
#define USPickerLog(fmt,...)
#endif
