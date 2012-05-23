//
//  MapHandler.h
//  InternetFinder
//
//  Created by Chris Laverdure on 12-05-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapObject.h"
#import "MapObjectLinkedList.h"

@interface MapHandler : NSObject
{
    char MapData[100][100];
    MapObjectLinkedList *MOBJ_List;
    MapObjectLinkedList *MOBJ_Last;
    
    int ActiveInterwebs;
    
    @public int XSize;
    @public int YSize;
    
}

-(void) InitMap;

-(void) GenerateMap:(char) X:(char) Y;

-(char) GetBlock:(char) X:(char) Y;

-(void) GameTick;

-(MapObject *) MOBJ_Add:(int)X :(int)Y :(char)ItemID:(BOOL) Collectable defaultFrame:(int) defaultFrame;

-(void) MOBJ_Remove:(MapObject *) DeletedObject;

-(MapObjectLinkedList *) MOBJ_ListByLocation:(int) X:(int) Y;

-(void) PopulatemapwithObject: (char) objectToPopulate: (int) defaultFrame: ( int ) numberOfItems;
@end
