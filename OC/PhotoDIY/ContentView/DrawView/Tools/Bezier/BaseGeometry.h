/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <UIKit/UIKit.h>

// Just because
#define TWO_PI (2 * M_PI)

// Undefined point
#define NULLPOINT CGRectNull.origin
#define POINT_IS_NULL(_POINT_) CGPointEqualToPoint(_POINT_, NULLPOINT)

// General
#define RECTSTRING(_aRect_)        NSStringFromCGRect(_aRect_)
#define POINTSTRING(_aPoint_)    NSStringFromCGPoint(_aPoint_)
#define SIZESTRING(_aSize_)        NSStringFromCGSize(_aSize_)

#define RECT_WITH_SIZE(_SIZE_) (CGRect){.size = _SIZE_}
#define RECT_WITH_POINT(_POINT_) (CGRect){.origin = _POINT_}

// Conversion
CGFloat DegreesFromRadians(CGFloat radians);
CGFloat RadiansFromDegrees(CGFloat degrees);

// General Geometry
CGPoint RectGetCenter(CGRect rect);
CGFloat PointDistanceFromPoint(CGPoint p1, CGPoint p2);

// Construction
CGRect RectMakeRect(CGPoint origin, CGSize size);
CGRect SizeMakeRect(CGSize size);
CGRect PointsMakeRect(CGPoint p1, CGPoint p2);
CGRect OriginMakeRect(CGPoint origin);
CGRect RectAroundCenter(CGPoint center, CGSize size);
CGRect RectCenteredInRect(CGRect rect, CGRect mainRect);

// Point Locations
CGPoint RectGetPointAtPercents(CGRect rect, CGFloat xPercent, CGFloat yPercent);

// Aspect and Fitting
CGSize  SizeScaleByFactor(CGSize aSize, CGFloat factor);
CGSize  RectGetScale(CGRect sourceRect, CGRect destRect);
CGFloat AspectScaleFill(CGSize sourceSize, CGRect destRect);
CGFloat AspectScaleFit(CGSize sourceSize, CGRect destRect);
CGRect  RectByFittingRect(CGRect sourceRect, CGRect destinationRect);
CGRect  RectByFillingRect(CGRect sourceRect, CGRect destinationRect);

// Transforms
CGFloat TransformGetXScale(CGAffineTransform t);
CGFloat TransformGetYScale(CGAffineTransform t);
CGFloat TransformGetRotation(CGAffineTransform t);
