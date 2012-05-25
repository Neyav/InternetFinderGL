//
//  HUDMessageList.h
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HUDMessageList : NSObject
{
    @public char Message[30];
    @public float Messagefold;
    @public char Messagesize;
    @public int MessageDuration;
    @public BOOL Expired;
    
    @public HUDMessageList *next;
}

@end
