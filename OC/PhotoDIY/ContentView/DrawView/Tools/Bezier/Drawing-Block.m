/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import "Drawing-Block.h"

#pragma mark - Drawing
UIImage *ImageWithBlock(DrawingBlock block, CGSize size)
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    if (block) block((CGRect){.size = size});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

void PushDraw(DrawingStateBlock block)
{
    if (!block) return; // nothing to do
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"No context to draw into", nil);
        return;
    }
    
    CGContextSaveGState(context);
    block();
    CGContextRestoreGState(context);
}

// Improve performance by pre-clipping context
// before beginning layer drawing
void PushLayerDraw(DrawingStateBlock block)
{
    if (!block) return; // nothing to do
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        NSLog(@"No context to draw into", nil);
        return;
    }
    
    CGContextBeginTransparencyLayer(context, NULL);
    block();
    CGContextEndTransparencyLayer(context);
}
