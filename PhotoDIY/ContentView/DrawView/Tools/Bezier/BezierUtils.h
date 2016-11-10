/*
 
 Erica Sadun, http://ericasadun.com
 
 */

#import <Foundation/Foundation.h>
#import "BaseGeometry.h"

CGRect PathBoundingBox(UIBezierPath *path);
CGRect PathBoundingBoxWithLineWidth(UIBezierPath *path);
CGPoint PathBoundingCenter(UIBezierPath *path);
CGPoint PathCenter(UIBezierPath *path);

// Transformations
void ApplyCenteredPathTransform(UIBezierPath *path, CGAffineTransform transform);
UIBezierPath *PathByApplyingTransform(UIBezierPath *path, CGAffineTransform transform);

// Utility
void RotatePath(UIBezierPath *path, CGFloat theta);
void ScalePath(UIBezierPath *path, CGFloat sx, CGFloat sy);
void OffsetPath(UIBezierPath *path, CGSize offset);
void MovePathToPoint(UIBezierPath *path, CGPoint point);
void MovePathCenterToPoint(UIBezierPath *path, CGPoint point);
void MirrorPathHorizontally(UIBezierPath *path);
void MirrorPathVertically(UIBezierPath *path);

// Fitting
void FitPathToRect(UIBezierPath *path, CGRect rect);
void AdjustPathToRect(UIBezierPath *path, CGRect destRect);

// Path Attributes
void CopyBezierState(UIBezierPath *source, UIBezierPath *destination);
void CopyBezierDashes(UIBezierPath *source, UIBezierPath *destination);
void AddDashesToPath(UIBezierPath *path);

// String to Path
UIBezierPath *BezierPathFromString(NSString *string, UIFont *font);
UIBezierPath *BezierPathFromStringWithFontFace(NSString *string, NSString *fontFace);

// N-Gons
UIBezierPath *BezierPolygon(NSUInteger numberOfSides);
UIBezierPath *BezierInflectedShape(NSUInteger numberOfInflections, CGFloat percentInflection);
UIBezierPath *BezierStarShape(NSUInteger numberOfInflections, CGFloat percentInflection);

// Misc
void ClipToRect(CGRect rect);
void FillRect(CGRect rect, UIColor *color);

@interface UIBezierPath (HandyUtilities)
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) CGRect computedBounds;
@property (nonatomic, readonly) CGRect computedBoundsWithLineWidth;

// Stroke/Fill
- (void) stroke: (CGFloat) width;
- (void) stroke: (CGFloat) width color: (UIColor *) color;
- (void) strokeInside: (CGFloat) width;
- (void) strokeInside: (CGFloat) width color: (UIColor *) color;
- (void) fill: (UIColor *) fillColor;
- (void) addDashes;
- (void) addDashes: (NSArray *) pattern;
- (void) applyPathPropertiesToContext;

// Clipping
- (void) clipToPath; // I hate addClip
- (void) clipToStroke: (NSUInteger) width;

// Util
- (UIBezierPath *) safeCopy;
@end
