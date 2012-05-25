//
//  HUDNotificationHandler.m
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <string.h>
#import "HUDNotificationHandler.h"

@implementation HUDNotificationHandler

-(void) SetupTextures:(GLKBaseEffect *)Effect
{
    // Load our textures here
    FontSprites[0] = [[SpriteHandler alloc] initWithFile:@"mofont-A.png" effect:Effect];
    FontSprites[1] = [[SpriteHandler alloc] initWithFile:@"mofont-B.png" effect:Effect];
    FontSprites[2] = [[SpriteHandler alloc] initWithFile:@"mofont-C.png" effect:Effect];
    FontSprites[3] = [[SpriteHandler alloc] initWithFile:@"mofont-D.png" effect:Effect];
    FontSprites[4] = [[SpriteHandler alloc] initWithFile:@"mofont-E.png" effect:Effect];
    FontSprites[5] = [[SpriteHandler alloc] initWithFile:@"mofont-F.png" effect:Effect];
    FontSprites[6] = [[SpriteHandler alloc] initWithFile:@"mofont-G.png" effect:Effect];
    FontSprites[7] = [[SpriteHandler alloc] initWithFile:@"mofont-H.png" effect:Effect];
    FontSprites[8] = [[SpriteHandler alloc] initWithFile:@"mofont-I.png" effect:Effect];
    FontSprites[9] = [[SpriteHandler alloc] initWithFile:@"mofont-J.png" effect:Effect];
    FontSprites[10] = [[SpriteHandler alloc] initWithFile:@"mofont-K.png" effect:Effect];
    FontSprites[11] = [[SpriteHandler alloc] initWithFile:@"mofont-L.png" effect:Effect];
    FontSprites[12] = [[SpriteHandler alloc] initWithFile:@"mofont-M.png" effect:Effect];
    FontSprites[13] = [[SpriteHandler alloc] initWithFile:@"mofont-N.png" effect:Effect];
    FontSprites[14] = [[SpriteHandler alloc] initWithFile:@"mofont-O.png" effect:Effect];
    FontSprites[15] = [[SpriteHandler alloc] initWithFile:@"mofont-P.png" effect:Effect];
    FontSprites[16] = [[SpriteHandler alloc] initWithFile:@"mofont-Q.png" effect:Effect];
    FontSprites[17] = [[SpriteHandler alloc] initWithFile:@"mofont-R.png" effect:Effect];
    FontSprites[18] = [[SpriteHandler alloc] initWithFile:@"mofont-S.png" effect:Effect];
    FontSprites[19] = [[SpriteHandler alloc] initWithFile:@"mofont-T.png" effect:Effect];
    FontSprites[20] = [[SpriteHandler alloc] initWithFile:@"mofont-U.png" effect:Effect];
    FontSprites[21] = [[SpriteHandler alloc] initWithFile:@"mofont-V.png" effect:Effect];
    FontSprites[22] = [[SpriteHandler alloc] initWithFile:@"mofont-W.png" effect:Effect];
    FontSprites[23] = [[SpriteHandler alloc] initWithFile:@"mofont-X.png" effect:Effect];
    FontSprites[24] = [[SpriteHandler alloc] initWithFile:@"mofont-Y.png" effect:Effect];
    FontSprites[25] = [[SpriteHandler alloc] initWithFile:@"mofont-Z.png" effect:Effect];
    FontSprites[26] = [[SpriteHandler alloc] initWithFile:@"mofont-0.png" effect:Effect];
    FontSprites[27] = [[SpriteHandler alloc] initWithFile:@"mofont-1.png" effect:Effect];
    FontSprites[28] = [[SpriteHandler alloc] initWithFile:@"mofont-2.png" effect:Effect];
    FontSprites[29] = [[SpriteHandler alloc] initWithFile:@"mofont-3.png" effect:Effect];
    FontSprites[30] = [[SpriteHandler alloc] initWithFile:@"mofont-4.png" effect:Effect];
    FontSprites[31] = [[SpriteHandler alloc] initWithFile:@"mofont-5.png" effect:Effect];
    FontSprites[32] = [[SpriteHandler alloc] initWithFile:@"mofont-6.png" effect:Effect];
    FontSprites[33] = [[SpriteHandler alloc] initWithFile:@"mofont-7.png" effect:Effect];
    FontSprites[34] = [[SpriteHandler alloc] initWithFile:@"mofont-8.png" effect:Effect];
    FontSprites[35] = [[SpriteHandler alloc] initWithFile:@"mofont-9.png" effect:Effect];
    FontSprites[36] = [[SpriteHandler alloc] initWithFile:@"mofont-!.png" effect:Effect];
    FontSprites[37] = [[SpriteHandler alloc] initWithFile:@"mofont-period.png" effect:Effect];
    
    MessageQueue = nil;
}

// Adds a new message to the end of the current message list to get queued up.
-(void) SendMessage:(char *)NewMessage messageDuration:(int)Duration priority:(BOOL)priority
{ 
    HUDMessageList *Iterator;
    HUDMessageList *NewItem;
    int MessageLength;
    
    NewItem = [[HUDMessageList alloc] init];
    
    Iterator = MessageQueue;
    
    if ( priority == NO && Iterator != nil)
    {
        // Not a high priority, move to the end of the list
        while ( Iterator->next != nil )
            Iterator = Iterator->next;
        
        Iterator->next = NewItem;
    }
    else {
        NewItem->next = Iterator;
        MessageQueue = NewItem;
    }
    
    NewItem->MessageDuration = Duration;
    
    MessageLength = strlen(NewMessage);
    
    if (MessageLength > 30)
        MessageLength = 30; // We only care about 30 bytes maximum, otherwise we'd clip off the screen.
    
    strncpy( NewItem->Message, NewMessage, MessageLength );
    NewItem->Messagesize = MessageLength;
    
    NewItem->Messagefold = 1.0;
    
    NewItem->Expired = NO;
}

-(int) LettertoFontRef:(char) letter
{
    if ( letter >= 65 && letter <= 90 )
    {
        // Main alphabet letter.
        return letter-65;
    }
    if ( letter >= 48 && letter <= 57 )
    {
        // It's a number
        return (letter - 48) + 26;
    }
    if ( letter == '!' )
        return 36;
    if ( letter == '.' )
        return 37;
    
    // Undefined
    return -1;
}

// Executed every tick, responsible for rendering letters and removing displayed queue'd text
-(void) HUDTick
{
    if ( MessageQueue == nil )
        return; //There is no message to display.
    
    // Deal with the folding in and out of the message
    if ( MessageQueue->Expired == YES )
    {
        if ( MessageQueue->Messagefold == 1.0 )
        {
            // Message has folded up, get rid of it.
            MessageQueue = MessageQueue->next;
            return;
        }
        
        MessageQueue->Messagefold += 0.05;
    }
    else {
        if ( MessageQueue->Messagefold > 0.0 )
        {
            // Message hasn't unfolded yet.
            MessageQueue->Messagefold -= 0.05;
        }
            
    }
    
    // Each letter is 32 pixels wide, screen is 960 pixels wide. Our start position is ( 960 /2 ) - ( 16 * len )
    int ScreenPosition = ( 960 / 2 ) - ( 16 * MessageQueue->Messagesize );
    
    // Iterate through every letter in the message.
    for ( int x = 0; x < MessageQueue->Messagesize; x++ )
    {
        int fontref = [self LettertoFontRef:MessageQueue->Message[x]];
        
        if ( fontref >= 0 )
        {   // Displayable letter
            [FontSprites[fontref] Foldup:MessageQueue->Messagefold];
            FontSprites[fontref].position = GLKVector2Make(ScreenPosition, 550);
            [FontSprites[fontref] render];
        }
        
        ScreenPosition += 32;
    }
    
    MessageQueue->MessageDuration--;
    
    if ( MessageQueue->MessageDuration == 0 )
        MessageQueue->Expired = YES; // Message is done.

}

@end
