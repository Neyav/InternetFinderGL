//
//  MapObject.h
//  InternetFinder
//
//  Created by Chris Laverdure on 12-05-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WayPointList.h"

#define MOBJ_PLAYER 1
#define MOBJ_INTERWEB 2
#define MOBJ_TROLL 3

@interface MapObject : NSObject
{
    // This is a container for all map objects
    @public int X;
    @public int Y;
    @public int XOffset;
    @public int YOffset;
    @public int XSize;
    @public int YSize;
    
    // Gameplay specific
    @public int InternetsCollected;
    @public char InternetsCollectedquickly;
    @public char InternetsCollectedquicklytimer;
    
    // AI specific
    @public WayPointList *WayPoint;
    @public char DepthSearch;
    
    // Render specific
    @public int Currentframe;
    @public int defaultFrame;
    @public int framesToNext;

    @public char timeOnWall; // How many frames you clipped into a wall in a row
    
    @public float MomentumX;
    @public float MomentumY;
    
    @public char ItemID;
    @public BOOL Collectable;
    @public BOOL CanCollect;
}
@end
