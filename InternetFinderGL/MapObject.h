//
//  MapObject.h
//  InternetFinder
//
//  Created by Chris Laverdure on 12-05-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MOBJ_PLAYER 1
#define MOBJ_INTERWEB 2

@interface MapObject : NSObject
{
    // This is a container for all map objects
    @public int X;
    @public int Y;
    @public int XOffset;
    @public int YOffset;
    @public int XSize;
    @public int YSize;
    
    @public float MomentumX;
    @public float MomentumY;
    
    @public char ItemID;
    @public BOOL Collectable;
    
}
@end
