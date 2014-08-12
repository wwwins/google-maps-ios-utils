#import <CoreText/CoreText.h>
#import "GDefaultClusterRenderer.h"
#import "GQuadItem.h"
#import "GCluster.h"

@implementation GDefaultClusterRenderer

- (id)initWithGoogleMap:(GMSMapView*)googleMap {
    if (self = [super init]) {
        map = googleMap;
        markerCache = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)clustersChanged:(NSSet*)clusters {
    for (GMSMarker *marker in markerCache) {
        marker.map = nil;
    }
    
    [markerCache removeAllObjects];
    
    for (id <GCluster> cluster in clusters) {
        GMSMarker *marker;
        marker = [[GMSMarker alloc] init];
        [markerCache addObject:marker];
        
        if ([cluster count] > 1) {
            marker.icon = [self generateClusterIconWithCount:[cluster count]];
        }
        else {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:0.800 green:0.200 blue:0.200 alpha:1.000]];
        }
        marker.position = cluster.position;
        marker.map = map;
    }
}

- (UIImage*) generateClusterIconWithCount:(int)count {
    
    int diameter = 40;
    float inset = 3;
    
    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // set stroking color and draw circle
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] setStroke];
    [[UIColor colorWithRed:0.800 green:0.200 blue:0.200 alpha:1.000] setFill];

    CGContextSetLineWidth(ctx, inset);

    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(0, 0, diameter, diameter);
    circleRect = CGRectInset(circleRect, inset, inset);

    // draw circle
    CGContextFillEllipseInRect(ctx, circleRect);
    CGContextStrokeEllipseInRect(ctx, circleRect);

    CTFontRef myFont = CTFontCreateWithName( (CFStringRef)@"Helvetica-Bold", 18.0f, NULL);
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)myFont, (id)kCTFontAttributeName,
                    [UIColor whiteColor], (id)kCTForegroundColorAttributeName, nil];

    // create a naked string
    NSString *string = [[NSString alloc] initWithFormat:@"%d", count];

    NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributesDict];

    // flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, diameter);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(stringToDraw));
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        frameSetter, /* Framesetter */
                                                                        CFRangeMake(0, stringToDraw.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        CGSizeMake(diameter, diameter), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                        );
    CFRelease(frameSetter);
    
    //Get the position on the y axis
    float midHeight = diameter;
    midHeight -= suggestedSize.height;
    
    float midWidth = diameter / 2;
    midWidth -= suggestedSize.width / 2;

    CTLineRef line = CTLineCreateWithAttributedString(
            (__bridge CFAttributedStringRef)stringToDraw);
    CGContextSetTextPosition(ctx, midWidth, 12);
    CTLineDraw(line, ctx);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
