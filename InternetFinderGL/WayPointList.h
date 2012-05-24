//
//  WayPointList.h
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WayPointList : NSObject
{
    @public char X;
    @public char Y;
    
    @public WayPointList *next;
}
@end
