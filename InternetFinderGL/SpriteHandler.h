//
//  SpriteHandler.h
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define SPRITE_FLOOR            0
#define SPRITE_WALL             1
#define SPRITE_INTERNET         2
#define SPRITE_PLAYER_NORMAL    3
#define SPRITE_PLAYER_HAPPY     4
#define SPRITE_PLAYER_VERYHAPPY 5
#define SPRITE_PLAYER_DUMB      6
#define SPRITE_NPC_TROLL        7

@interface SpriteHandler : NSObject

@property (assign) GLKVector2 position;
@property (assign) CGSize contentSize;

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (void)render;

@end
