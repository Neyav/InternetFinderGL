//
//  HUDNotificationHandler.h
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteHandler.h"
#import "HUDMessageList.h"

@interface HUDNotificationHandler : NSObject
{
    SpriteHandler *FontSprites[38];
    HUDMessageList *MessageQueue;
    
}
-(void) SetupTextures:(GLKBaseEffect *)Effect;

-(void) SendMessage:(char *)NewMessage messageDuration:(int) Duration priority:(BOOL)priority;

-(void) HUDTick;

@end
