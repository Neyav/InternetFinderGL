//
//  MapHandler.m
//  InternetFinder
//
//  Created by Chris Laverdure on 12-05-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#include <time.h>

#import "MapHandler.h"
#import "SpriteHandler.h"

@implementation MapHandler

-(void) InitMap
{
/*    // Fill our map with bullshit. Weehah
    strcpy( MapData[0], "11111111111111111111");
    strcpy( MapData[1], "10100000000011111111");
    strcpy( MapData[2], "10101111011011111111");
    strcpy( MapData[3], "10000110001011111111");
    strcpy( MapData[4], "11011110001011111111");
    strcpy( MapData[5], "10001110001011111111");
    strcpy( MapData[6], "10100000111011111111");
    strcpy( MapData[7], "10001101100011111111");
    strcpy( MapData[8], "10111100001111111111");
    strcpy( MapData[9], "11111111101111111111");
    strcpy( MapData[10], "11111111101111111111");
    strcpy( MapData[11], "11111111101111111111");
    strcpy( MapData[12], "11111111101111111111");
    strcpy( MapData[13], "11111100101111111111");
    strcpy( MapData[14], "11111100001111111111");
    strcpy( MapData[15], "11111100101111111111");
    strcpy( MapData[16], "11111111101111111111");
    strcpy( MapData[17], "11111111111111111111");
    strcpy( MapData[18], "11111111111111111111");
    strcpy( MapData[19], "11111111111111111111");*/
    
    MOBJ_List = nil;
    MOBJ_Last = nil;
    
    XSize = 19;
    YSize = 19;
    
    ActiveInterwebs = 0; // We are interwebless
    TicksSinceAI = 0;
    
    HUDNotifications = nil;
    
    // Seed the random number generator
    srandom ( time( NULL) );
}

-(void) LinkToNotifications:(HUDNotificationHandler *)NHand
{
    HUDNotifications = NHand;
}

// THIS IS USED BY AND ONLY BY GenerateMap
// Do not CALL.
-(void) BlockIterator:(char)X :(char)Y
{
    
    // YOU HAVE BEEN FLOORIFIED!
    MapData[X][Y] = '0';
    
    // We need to find a block that both isn't one of the map boundry walls and also
    // doesn't have any empty spaces adjacent to it.
    BOOL ValidDirections[4];
    
    while (1)
    {
        ValidDirections[0] = ValidDirections[1] = ValidDirections[2] = ValidDirections[3] = NO;
        // Determine which directions are valid.
        if ( ( X - 1 ) > 0 )
        { // Only check north if it doesn't fall off the boundries of the map
            if ( MapData[X - 1][Y - 1] == '1' && MapData[X - 2][Y] == '1' && MapData[X - 1][Y + 1] == '1' )
            {
                // The northern position is valid
                ValidDirections[0] = YES;
            }
            
        }
        if ( X < ( XSize - 1 ))
        { // Only check south if it doesn't fall off the boundries of the map
            if ( MapData[X + 1][Y - 1] == '1' && MapData[X + 2][Y] == '1' && MapData[X + 1][Y + 1] == '1' )
            {
                // The southern wall WILL HOLD AGAINST THE ORCS!
                ValidDirections[1] = YES;
            }
                
        }
        if ( ( Y - 1 ) > 0 )
        {
            if ( MapData[X][Y - 2] == '1' && MapData[X - 1][Y - 1] == '1' && MapData[X + 1][Y - 1] == '1' )
            {
                ValidDirections[2] = YES;
            }
        }
        if ( Y < ( XSize - 1 ))
        {
            if ( MapData[X][Y + 2] == '1' && MapData[X - 1][Y + 1] == '1' && MapData[X + 1][Y + 1] == '1' )
            {
                ValidDirections[3] = YES;
            }
        }
        
        // If those sections are already floors they aren't valid
        if ( MapData[X-1][Y] == '0' )
            ValidDirections[0] = NO;
        if ( MapData[X+1][Y] == '0' )
            ValidDirections[1] = NO;
        if ( MapData[X][Y-1] == '0' )
            ValidDirections[2] = NO;
        if ( MapData[X][Y+1] == '0' )
            ValidDirections[3] = NO;
        
        // If we have no valid locations, terminate
        if ( ValidDirections[0] == NO && ValidDirections[1] == NO && ValidDirections[2] == NO && ValidDirections[3] == NO )
            break;
        
        char Direction = random() % 3;
        
        while (ValidDirections[Direction] == NO) // Find the first valid location
        {
            Direction++;
            if ( Direction == 4 )
                Direction = 0;
        }
        
        if ( Direction == 0 )
            [self BlockIterator:X -1 :Y];
        else if ( Direction == 1 )
            [self BlockIterator:X + 1: Y];
        else if ( Direction == 2 )
            [self BlockIterator:X :Y - 1];
        else if ( Direction == 3 )
            [self BlockIterator:X :Y + 1];
        
    }
    
}

// Randomly generate a map of X,Y size
-(void) GenerateMap:(char)X :(char)Y
{
    // Set the maps dimensions
    XSize = X;
    YSize = Y;
    
    // Make sure our values are in proper range.
    if ( XSize > 99 )
        XSize = 99;
    if ( YSize > 99 )
        YSize = 99;
    if ( XSize < 10 )
        XSize = 10;
    if ( YSize < 10 )
        YSize = 10;
    
    for ( int tx = 0; tx < 100; tx++ )
    {
        for ( int ty = 0; ty < 100; ty++ )
        {
            // Initalize every block with a wall.
            MapData[tx][ty] = '1';
        }
    }
    // Start our iterator at 1,1
    [self BlockIterator:1 :1];
    
    // The map has been generated, now we are going to randomly destroy walls! sunder ME!
    int Blockstodestroy = (XSize + YSize) * 1.3;
    
    while ( Blockstodestroy )
    {
        int DestroyX = random() % (XSize - 2) + 1;
        int DestroyY = random() % (YSize - 2) + 1;
        
        if ( MapData[DestroyX][DestroyY] == '1' )
        {
            MapData[DestroyX][DestroyY] = '0';
            Blockstodestroy--;
        }
    }
}

-(char) GetBlock:(char)X :(char)Y
{
    // Gets the block value from a position
    // Returning 1 for a wall in the event that the block exceeds the map size
 
    //printf("Called X: %i Y: %i\n", X, Y );
    
    if ( X > XSize || Y > YSize)
        return 49;
    else if ( X < 0 || Y < 0)
        return 49;

    //printf("X: %i Y: %i  Data:%i\n", X, Y, MapData[X][Y]);
    return (MapData[X][Y]);
}

// TROLL AI CODE

-(BOOL) TrollWayPointGenerate: (MapObject *) Troll: (char) Depth: (char) MaxDepth: (char) X: (char) Y
{
    MapObjectLinkedList *CurrentBlock;
    WayPointList *ListIterator;
    WayPointList *EndofList;
    WayPointList *OurEntry;
    
    if ( Depth > MaxDepth )
        return NO; // We went too far.
    
    if ( Depth == MaxDepth && MaxDepth >= 35 )
    {
        // We can't keep doing searches like this or we'll run the processor to the core, just give it a 5%
        // chance that we'll accept any route at max depth.
        int Chance = random() % 100;
        
        if ( Chance <= 15 )
            return YES; // I LIED!!!!
    }
    
    ListIterator = EndofList = OurEntry = Troll->WayPoint;
    
    // Make sure we haven't called on this block before
    while ( ListIterator != nil )
    {
            if ( ListIterator->X == X && ListIterator->Y == Y )
            {   // We called on this block before
                return NO;
            }
        
        if ( ListIterator->next != nil )
            EndofList = ListIterator->next;
        ListIterator = ListIterator->next;
    }
    
    // This is at least a valid waypoint block, so lets add it to the current list.
    OurEntry = [[WayPointList alloc] init];
    
    if ( EndofList == nil )
    {
        EndofList = OurEntry;
        Troll->WayPoint = OurEntry;
    }
    else {
        EndofList->next = OurEntry;
    }
    OurEntry->next = nil;
    OurEntry->X = X;
    OurEntry->Y = Y;
    
    // Check this block for internet
    CurrentBlock = [self MOBJ_ListByLocation:X :Y];
    while ( CurrentBlock != nil )
    {
        if ( CurrentBlock->MapObject->ItemID == MOBJ_INTERWEB )
        {
            // This path is confirmed!
            return YES;
        }
        
        CurrentBlock = CurrentBlock->next;
    }
    
    // This block doesn't have anything on it,
    // Expand in all valid directions.
    if ( MapData[X - 1][Y] == '0' )
        if ([self TrollWayPointGenerate:Troll :Depth+1 :MaxDepth :X-1 :Y] == YES )
            return YES;
    
    OurEntry->next = nil;
    
    if ( MapData[X + 1][Y] == '0' )
        if ([self TrollWayPointGenerate:Troll :Depth+1 :MaxDepth :X+1 :Y] == YES )
            return YES;
    
    OurEntry->next = nil;
    
    if ( MapData[X][Y - 1] == '0' )
        if ([self TrollWayPointGenerate:Troll :Depth+1 :MaxDepth :X :Y - 1] == YES )
            return YES;
    
    OurEntry->next = nil;
    
    if ( MapData[X][Y + 1] == '0' )
        if ([self TrollWayPointGenerate:Troll :Depth+1 :MaxDepth :X :Y + 1] == YES )
            return YES;

    OurEntry->next = nil;
    
    return NO;
}

-(void) TrollAITick: (MapObject *) Troll
{
    while ( Troll->WayPoint == nil )
    {
        // Generate a new waypoint
        if ( [self TrollWayPointGenerate:Troll :1 :Troll->DepthSearch :Troll->X :Troll->Y] == NO )
        {
            Troll->WayPoint = nil;
            Troll->DepthSearch += 5;
            return; // Only do a search every ai gametick
        }
    }
    
    Troll->DepthSearch = 5;
    
    // Navigate towards the center of the next waypoint object.
    char NextX = Troll->WayPoint->X;
    char NextY = Troll->WayPoint->Y;
    int DestOffsetX, DestOffsetY;
    
    
    DestOffsetX = Troll->X - NextX;
    DestOffsetY = Troll->Y - NextY;
    
    DestOffsetX *= 128;
    DestOffsetY *= 128;
    
    
    DestOffsetX += Troll->XOffset;
    DestOffsetY += Troll->YOffset;
    
    DestOffsetX *= -1;
    DestOffsetY *= -1;
    

    
    if ( DestOffsetX > -25 && DestOffsetX < 25 )
    {
        if ( DestOffsetY > -25 && DestOffsetY < 25 )
        {
            // We reached the waypoint, set the next one
            Troll->WayPoint = Troll->WayPoint->next;
        }
    }
    
    int relativeTotal = 0;
    if ( DestOffsetX < 0 )
        relativeTotal += ( DestOffsetX * -1 );
    else
        relativeTotal += DestOffsetX;
    
    if ( DestOffsetY < 0 )
        relativeTotal += ( DestOffsetY * -1 );
    else 
        relativeTotal += DestOffsetY;
    
    int Modifier = relativeTotal / 10;
    
    if ( Modifier !=  0 )
    {
        DestOffsetX /= Modifier;
        DestOffsetY /= Modifier;
        
        Troll->MomentumX = DestOffsetY;
        Troll->MomentumY = DestOffsetX;
    }

    
}

// --- TROLL AI CODE ---

-(void) GameTick
{
    MapObjectLinkedList *Iterator;
    
    Iterator = MOBJ_List;
    
    if ( TicksSinceAI > 2 )
        TicksSinceAI = 1;
    else     
        TicksSinceAI++;
    
    // Iterate through the list to find objects with momentum
    while ( Iterator != nil )
    {
        
        if ( Iterator->MapObject->ItemID == MOBJ_TROLL && TicksSinceAI > 2)
        { // Object is an internet troll. See what is under his bridge!
            [self TrollAITick:Iterator->MapObject];
        }
        
        if ( Iterator->MapObject->InternetsCollectedquicklytimer > 0 )
        {
            Iterator->MapObject->InternetsCollectedquicklytimer--;   // Tick Tock
            
            if ( Iterator->MapObject->InternetsCollectedquicklytimer == 0 )
                Iterator->MapObject->InternetsCollectedquickly = 0;
        }
        
        // Frame change
        // Count down the timer and if it hits zero switch to defaultFrame
        if ( Iterator->MapObject->framesToNext > 0 )
        {
            Iterator->MapObject->framesToNext--;
            
            if ( Iterator->MapObject->framesToNext == 0 )
                Iterator->MapObject->Currentframe = Iterator->MapObject->defaultFrame;
            
        }
        
        if ( Iterator->MapObject->MomentumX != 0 || Iterator->MapObject->MomentumY != 0 )
        {
            // This object has momentum
            int tempX = Iterator->MapObject->X;
            int tempY = Iterator->MapObject->Y;
            float tempmox = Iterator->MapObject->MomentumX;
            float tempmoy = Iterator->MapObject->MomentumY;
            int tempXO = Iterator->MapObject->XOffset;
            int tempYO = Iterator->MapObject->YOffset;
            int ObjectXSize = Iterator->MapObject->XSize / 2;
            int ObjectYSize = Iterator->MapObject->YSize / 2;
            BOOL hitWall = NO;
            
            tempXO += tempmoy;
            tempYO += tempmox;
            
            // Check to see if we left our block
            // The player extends 64x64 in either direction. 
            
            if ( tempXO > 64 - ObjectXSize )
            {
                // Bounding of the character has extended below us. Check
                if ( MapData[tempX + 1][tempY] == '1' )
                {
                    // hit a wall.
                    tempXO = 64-ObjectXSize; // Put us back to the last safe location.
                    hitWall = YES;
                }
            
            }
            else if ( tempXO < -64 + ObjectXSize )
            {
                // Bounding of the character has extended above us. Check
                if ( MapData[tempX - 1][tempY] == '1' )
                {
                    // hit a wall.
                    tempXO = -64+ObjectXSize; // Put us back to the last safe location.
                    hitWall = YES;
                }
            
            }                
            if ( tempYO > 64 - ObjectYSize )
            {
                // Bounding of the character has extended right of us. Check
                if ( MapData[tempX][tempY + 1] == '1' )
                {
                    // hit a wall.
                    tempYO = 64-ObjectYSize; // Put us back to the last safe location.
                    hitWall = YES;
                }
            
            }                
            else if ( tempYO < -64 + ObjectYSize )
            {
                // Bounding of the character has extended left of us. Check
                if ( MapData[tempX][tempY - 1] == '1' )
                {
                    // hit a wall.
                    tempYO = -64 + ObjectYSize; // Put us back to the last safe location.
                    hitWall = YES;
                }
            
            }
            
            // Now check to see if we are traversing the boundry, since we know it's safe just move us
            if ( tempXO > 64 )
            {
                // Moving south
                if ( MapData[tempX + 1][tempY] == '0' )
                {
                    tempX++;
                    tempXO = -63;
                }
            }
            if ( tempXO < -64 )
            {
                if ( MapData[tempX - 1][tempY] == '0' )
                {
                // Moving north
                tempX--;
                tempXO = 63;
                }
            }
            if ( tempYO > 64 )
            {
                if ( MapData[tempX][tempY + 1] == '0' )
                {
                // moving right
                tempY++;
                tempYO = -63;
                }
            }
            if ( tempYO < -64 )
            {
                if ( MapData[tempX][tempY - 1] == '0' )
                {
                // moving left
                tempY--;
                tempYO = 63;
                }
            }
            
            // atrophy momentum
            if ( tempmox > 0 )
            {
                tempmox -= 1;
                if ( tempmox <= 0 )
                    tempmox = 0;
            }
            else if ( tempmox < 0 )
            {
                tempmox += 1;
                if ( tempmox >= 0 )
                    tempmox = 0;
            }
            
            if ( tempmoy > 0 )
            {
                tempmoy -= 1;
                if ( tempmoy <= 0 )
                    tempmoy = 0;
            }
            else if ( tempmoy < 0 )
            {
                tempmoy += 1;
                if ( tempmoy >= 0 )
                    tempmoy = 0;
            }
            
            // Commit changes
            Iterator->MapObject->X = tempX;
            Iterator->MapObject->Y = tempY;
            Iterator->MapObject->XOffset = tempXO;
            Iterator->MapObject->YOffset = tempYO;
            Iterator->MapObject->MomentumX = tempmox;
            Iterator->MapObject->MomentumY = tempmoy;
            if ( hitWall )
                Iterator->MapObject->timeOnWall++;
            else
                Iterator->MapObject->timeOnWall = 0;
            
            // If we are capable of collecting items then check for them.
            if ( Iterator->MapObject->CanCollect == YES )
            {
                MapObjectLinkedList *newlocation = 
                            [self MOBJ_ListByLocation:Iterator->MapObject->X :Iterator->MapObject->Y];
                
                // Iterate through the objects and do some math on them bitches
                while ( newlocation != nil )
                {
                    MapObject *LocationObject = newlocation->MapObject;
                    if ( LocationObject->Collectable )
                    {
                        // This is a collectable item.. Put per object handling code in here, but
                        // remove the item regardless
                        
                        if ( LocationObject->ItemID == MOBJ_INTERWEB ) 
                        { // An interweb has been collected
                            Iterator->MapObject->InternetsCollected++;
                            ActiveInterwebs--;
                            
                            if ( Iterator->MapObject->ItemID == MOBJ_TROLL )
                                [HUDNotifications SendMessage:"TROLL GOT INTERNETS!" messageDuration:60 priority:NO];
                            
                            if ( Iterator->MapObject->ItemID == MOBJ_PLAYER )
                            { // This is our player. Make him/her happy!!! tickle tickle!
                                Iterator->MapObject->InternetsCollectedquickly++;
                                Iterator->MapObject->InternetsCollectedquicklytimer = 120; // 4 second timer
                                
                                if ( Iterator->MapObject->InternetsCollectedquickly == 5 )
                                {
                                    [HUDNotifications SendMessage:"OH MY GOODNESS YES!" messageDuration:120 priority:YES];
                                    Iterator->MapObject->Currentframe = SPRITE_PLAYER_VERYHAPPY;
                                    Iterator->MapObject->framesToNext = 240; // 8 second orgasm
                                }
                                else {
                                    if ( Iterator->MapObject->Currentframe != SPRITE_PLAYER_VERYHAPPY )
                                    { // Never interupt the orgasm!
                                        Iterator->MapObject->Currentframe = SPRITE_PLAYER_HAPPY;
                                        Iterator->MapObject->framesToNext = 120; // 4 seconds of me gusta...
                                        [HUDNotifications SendMessage:"ME GUSTA!" messageDuration:30 priority:YES];
                                    }
                                }
                                
                            }
                        }
                        
                        [self MOBJ_Remove:LocationObject];
                        
                    }
                    
                newlocation = newlocation->next;
                    
                }
            }
            
            
        }
        
        Iterator = Iterator->next;
    }
}

-(MapObject *) MOBJ_Add:(int)X :(int)Y :(char)ItemID:(BOOL) Collectable:(BOOL) CanCollect 
                            defaultFrame:(int) defaultFrame
{
    // This function adds a new map object to our game
    MapObject *NewObject;
    
    // Verify the location
    if ( MapData[X][Y] != '0' )
        return nil;
    
    // Bounds checking
    if ( X > XSize || Y > YSize )
        return nil;
    if ( X < 0 || Y < 0 )
        return nil;
    
        // This is a clippable object, we need to locate all other objects and make
        // sure there are none where we plan to spawn
        
        MapObjectLinkedList *ListPosition = MOBJ_List;
        
        while ( ListPosition != nil )
        {
            if ( ListPosition->MapObject->X == X
                        && ListPosition->MapObject->Y == Y )
            {
                // We're intersecting a clippable object. Sorry
                return nil;
            }
            
            ListPosition = ListPosition->next;
            
        }
    
    // Initalize it
    NewObject = [[MapObject alloc] init];
    
    NewObject->X = X;
    NewObject->Y = Y;
    NewObject->ItemID = ItemID;
    NewObject->Currentframe = NewObject->defaultFrame = defaultFrame;
    NewObject->framesToNext = -1; // No timeout on default frame
    NewObject->timeOnWall = 0;
    NewObject->WayPoint = nil;
    
    if ( ItemID == MOBJ_PLAYER )
    {
        NewObject->XSize = 64;
        NewObject->YSize = 64;
    }
    else if ( ItemID == MOBJ_INTERWEB )
    {
        NewObject->XSize = 64;
        NewObject->YSize = 64;
    }
    else if ( ItemID == MOBJ_TROLL )
    {
        NewObject->XSize = 64;
        NewObject->YSize = 64;
        NewObject->DepthSearch = 5;
    }
    
    NewObject->XOffset = 0;
    NewObject->YOffset = 0;
    NewObject->MomentumX = 0;
    NewObject->MomentumY = 0;
    NewObject->InternetsCollected = 0;
    NewObject->Collectable = Collectable;
    NewObject->CanCollect = CanCollect;
    NewObject->InternetsCollectedquickly = NewObject->InternetsCollectedquicklytimer = 0;
    
    // If the last item is nil then this is the first item. Initalize the list
    if ( !MOBJ_Last )
    {
        MOBJ_List = [[MapObjectLinkedList alloc] init];
        MOBJ_List->next = nil;
        MOBJ_List->prev = nil;
        MOBJ_Last = MOBJ_List;
        MOBJ_Last->MapObject = NewObject;
    }
    else {
        // Tack it on to the end of our list and make it the new end
        MapObjectLinkedList *NewListItem;
        
        NewListItem = [[MapObjectLinkedList alloc] init];
        
        MOBJ_Last->next = NewListItem;
        NewListItem->next = nil;
        NewListItem->prev = MOBJ_Last;
        MOBJ_Last = NewListItem;
        
        MOBJ_Last->MapObject = NewObject;
    }
    return NewObject;
}

-(void)MOBJ_Remove:(MapObject *)DeletedObject
{
    MapObjectLinkedList *Iterator;
    
    Iterator = MOBJ_List;
    
    // Iterator through the list looking for our object
    while ( Iterator->MapObject != DeletedObject )
    {
        // Next object
        if ( Iterator->next == nil )
            return; // How the fuck did we reach the end of the list without finding the object?????
        
        Iterator = Iterator->next;
    }
    
    // This is our object. Kill it
    Iterator->prev->next = Iterator->next;
    if ( Iterator->next != nil )
        Iterator->next->prev = Iterator->prev;
    // haha, ARC..... love it.... I feel dirty not doing memory management manually.
}

// Returns a linked list of map objects on any location with player's being put at the end of the list.
-(MapObjectLinkedList *)MOBJ_ListByLocation:(int)X :(int)Y
{
    MapObjectLinkedList *LocationList;
    MapObjectLinkedList *LocationListEnd;
    MapObjectLinkedList *ListIterator;
    
    LocationList = LocationListEnd = nil;
    
    ListIterator = MOBJ_List;
    
    while ( ListIterator != nil )
    {
        if ( ListIterator->MapObject->X == X && ListIterator->MapObject->Y == Y )
        {
            // This Map Object is on our position.
            MapObjectLinkedList *InsertPosition;
            
            InsertPosition = [[MapObjectLinkedList alloc] init];
            
            InsertPosition->MapObject = ListIterator->MapObject;
            
            // If our list is empty than this is easy
            if (LocationList == nil)
            {
                LocationList = InsertPosition;
                LocationList->next = nil;
                LocationList->prev = nil;
                LocationListEnd = LocationList;
            }
            else {
                if ( ListIterator->MapObject->ItemID == MOBJ_PLAYER )
                {
                    // It's a player. Add to the end of the list
                    LocationListEnd->next = InsertPosition;
                    InsertPosition->prev = LocationListEnd;
                    InsertPosition->next = nil;
                    
                    LocationListEnd = InsertPosition;                    
                }
                else {
                    // Otherwise add it to the beginning of the list
                    LocationList->prev = InsertPosition;
                    InsertPosition->next = LocationList;
                    InsertPosition->prev = nil;
                    
                    LocationList = InsertPosition;
                }
            }
        }
        ListIterator = ListIterator->next;
    }
    
    // return the list
    return LocationList;
}

-(void) PopulatemapwithObject: (char) objectToPopulate: (int) defaultFrame: ( int ) numberOfItems
{
    // We need to fill the map with the appropriate number of interwebs.
    BOOL CanCollect = NO;
    BOOL Collectable = YES;
    
    if ( objectToPopulate == MOBJ_TROLL )
    {
        CanCollect = YES;
        Collectable = NO;
    }
    
    for ( int x = 0; x < numberOfItems; x++ )
    {
        BOOL Spawned = NO;
        
        while ( Spawned == NO )
        {
            int spawnX = random() % XSize;
            int spawnY = random() % YSize;
            if ( [self MOBJ_Add:spawnX :spawnY :objectToPopulate :Collectable :CanCollect defaultFrame:defaultFrame] != nil )
                Spawned = YES;
        }
    }
}

@end
