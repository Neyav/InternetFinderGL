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
#import "HUDNotificationHandler.h"

@interface MapHandler : NSObject
{
    char MapData[100][100];
    MapObjectLinkedList *MOBJ_List;
    MapObjectLinkedList *MOBJ_Last;
    HUDNotificationHandler *HUDNotifications;
    
    int ActiveInterwebs;
    char TicksSinceAI;
    
    @public int XSize;
    @public int YSize;
    
    
    
}

-(void) InitMap;

-(void) LinkToNotifications:(HUDNotificationHandler *) NHand;

-(void) GenerateMap:(char) X:(char) Y;

-(char) GetBlock:(char) X:(char) Y;

-(void) GameTick;

-(MapObject *) MOBJ_Add:(int)X :(int)Y :(char)ItemID:(BOOL) Collectable :(BOOL) CanCollect 
                                defaultFrame:(int) defaultFrame;

-(void) MOBJ_Remove:(MapObject *) DeletedObject;

-(MapObjectLinkedList *) MOBJ_ListByLocation:(int) X:(int) Y;

-(void) PopulatemapwithObject: (char) objectToPopulate: (int) defaultFrame: ( int ) numberOfItems;
@end
