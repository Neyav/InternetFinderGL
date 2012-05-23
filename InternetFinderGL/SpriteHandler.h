//
//  SpriteHandler.h
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SpriteHandler : NSObject

@property (assign) GLKVector2 position;
@property (assign) CGSize contentSize;

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (void)render;

@end
