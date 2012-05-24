//
//  ViewController.m
//  InternetFinderGL
//
//  Created by Chris Laverdure on 12-05-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "SpriteHandler.h"
#import "MapHandler.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define MOVEMENT_SPEED 20

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface ViewController () {
   GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    CADisplayLink *GameTimer;
    MapObject *LocalPlayer;
    int touchX,touchY;
    char touching;
    MapHandler *GameMap;
    
    SpriteHandler *CommonSprites[8];
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;

    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
 //   float scale = [UIScreen mainScreen].scale;
    GLKMatrix4 projectionMatrix;
    
 //   if ( scale < 2.0f )
  //      projectionMatrix = GLKMatrix4MakeOrtho(0, 480, 0, 320, -1024, 1024);
  //  else 
        projectionMatrix = GLKMatrix4MakeOrtho(0, 960, 0, 640, -1024, 1024);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // Load the sprites we're going to use often
    CommonSprites[SPRITE_FLOOR] = [[SpriteHandler alloc] initWithFile:@"tilefloor@2x.png" effect:self.effect];
    CommonSprites[SPRITE_WALL] = [[SpriteHandler alloc] initWithFile:@"tilewall@2x.png" effect:self.effect];
    CommonSprites[SPRITE_INTERNET] = [[SpriteHandler alloc] initWithFile:@"1interwebs@2x.png" effect:self.effect];
    CommonSprites[SPRITE_PLAYER_NORMAL] = [[SpriteHandler alloc] initWithFile:@"player_normal.png" 
                                                                       effect:self.effect];
    CommonSprites[SPRITE_PLAYER_HAPPY] = [[SpriteHandler alloc] initWithFile:@"player_happy.png" 
                                                                       effect:self.effect];
    CommonSprites[SPRITE_PLAYER_VERYHAPPY] = [[SpriteHandler alloc] initWithFile:@"player_superhappy.png" 
                                                                       effect:self.effect];
    CommonSprites[SPRITE_PLAYER_DUMB] = [[SpriteHandler alloc] initWithFile:@"player_dumb.png" 
                                                                       effect:self.effect];
    CommonSprites[SPRITE_NPC_TROLL] = [[SpriteHandler alloc] initWithFile:@"npc_troll_normal.png" 
                                                                   effect:self.effect];
    
    // SETUP THE GAME WORLD -- THIS WILL NEED TO BE MOVED
    GameMap = [[MapHandler alloc] init];
    [GameMap InitMap];
    [GameMap GenerateMap:30 :30];
    
    LocalPlayer = [GameMap MOBJ_Add:1 :1 :MOBJ_PLAYER :NO :YES defaultFrame:SPRITE_PLAYER_NORMAL];
    
    touching = 0;
    
    if ( !LocalPlayer )
        NSLog(@"ERROR: No Local Player!");
    
    // Populate the world with interwebs
    [GameMap PopulatemapwithObject:MOBJ_INTERWEB :SPRITE_INTERNET :60];
    [GameMap PopulatemapwithObject:MOBJ_TROLL :SPRITE_NPC_TROLL :2];
    
    view.enableSetNeedsDisplay = NO;
    GameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(UpdateDisplay:)];
    GameTimer.frameInterval = 2;
    [GameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    
}

- (void)RenderFloors
{
    char RenderX = LocalPlayer->X - 3;
    char RenderY = LocalPlayer->Y - 4;
    
    for ( int x = 0; x < 7; x++)
    {
        for ( int y = 0; y < 9; y++)
        {
            char MapBlock = [GameMap GetBlock:RenderX :RenderY];
            
            // Calculate our draw positions topleft corner of the screen is 0,480
            // Funny story about the 28... Our wall offset is no longer needed because openGL renders
            // bottom left going up.... so now everything is offset...
            int drawPosX = 480 - ( x * 128 - 128 ) + 28; 
            int drawPosY = y * 128;
            
            // Adjust the screen offset by our players offset
            
            drawPosX += LocalPlayer->XOffset;
            drawPosY -= LocalPlayer->YOffset;
            
            // We need the localplayer in the center of the screen
            drawPosY -= 64;
           
            if ( MapBlock == '0' )
            { // We only render floors this round
                CommonSprites[SPRITE_FLOOR].position = GLKVector2Make(drawPosY, drawPosX);
                [CommonSprites[SPRITE_FLOOR] render];
            }
              
            RenderY++;
        }
    
    RenderX++;
    RenderY = LocalPlayer->Y - 4;  
        
    }
    
}

- (void)RenderWallsandObjects
{
    char RenderX = LocalPlayer->X - 3;
    char RenderY = LocalPlayer->Y - 4;
    
    for ( int x = 0; x < 7; x++)
    {
        for ( int y = 0; y < 9; y++)
        {
            char MapBlock = [GameMap GetBlock:RenderX :RenderY];
            
            // Calculate our draw positions topleft corner of the screen is 0,480
            int drawPosX = 480 - ( x * 128 - 128 ) + 28;
            int drawPosY = y * 128;
            
            // Adjust the screen offset by our players offset
            
            drawPosX += LocalPlayer->XOffset;
            drawPosY -= LocalPlayer->YOffset;
            
            // We need the localplayer in the center of the screen
            drawPosY -= 64;
                        
            if ( MapBlock == '1' )
            { // Rendering walls this time!
                drawPosY -= 28;
                
                CommonSprites[SPRITE_WALL].position = GLKVector2Make(drawPosY, drawPosX);
                [CommonSprites[SPRITE_WALL] render];
            }
            else {
                // Search for objects on this location as it is not a wall
                MapObjectLinkedList *ItemList;
                ItemList = [GameMap MOBJ_ListByLocation:RenderX :RenderY];
                
                // iterate the list and draw
                while ( ItemList != nil )
                {
                    int Xoffset = drawPosX - (ItemList->MapObject->XOffset);
                    int Yoffset = drawPosY + (ItemList->MapObject->YOffset);
                    
                    // Adjust offset based on the items size
                    Xoffset += ( 64 - ( ItemList->MapObject->XSize / 2 ) );
                    Yoffset += ( 64 - ( ItemList->MapObject->YSize / 2 ) );
                    
                    if ( ItemList->MapObject->ItemID == MOBJ_PLAYER )
                    {
                        if ( ItemList->MapObject->timeOnWall > 30 )
                        {
                            ItemList->MapObject->timeOnWall = 0;
                            ItemList->MapObject->Currentframe = SPRITE_PLAYER_DUMB;
                            ItemList->MapObject->framesToNext = 120; // You're dumb for 4 seconds!
                        }
                    }
                    
                    {
                        CommonSprites[ItemList->MapObject->Currentframe].position = GLKVector2Make(Yoffset, Xoffset);
                        [CommonSprites[ItemList->MapObject->Currentframe] render];
                        
                    }
                    
                    ItemList = ItemList->next;
                    
                }
            }
            
            RenderY++;
        }
        
        RenderX++;
        RenderY = LocalPlayer->Y - 4;  
        
    }    
}

- (void)UpdateDisplay:(CADisplayLink*)sender
{
 
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    
    // GAME LOGIC
    if ( touching > 0 )
    {
        // Someone is DEFILING OUR SCREEN! Apply the pressure to momentum
        int ScreencenterX = 240 +16;
        int ScreencenterY = 160;
        
        int relativeX = touchX - ScreencenterX;
        int relativeY = touchY - ScreencenterY;
        
        // Relative total is going to calculate the total distance from the center to our touch
        
        int relativeTotal = 0;
        if ( relativeX < 0 )
            relativeTotal += ( relativeX * -1 );
        else
            relativeTotal += relativeX;
        
        if ( relativeY < 0 )
            relativeTotal += ( relativeY * -1 );
        else 
            relativeTotal += relativeY;
        
        int Modifier = relativeTotal / MOVEMENT_SPEED;
        
        if ( Modifier !=  0 )
        {
            relativeX /= Modifier;
            relativeY /= Modifier;
            
            if ( relativeX > MOVEMENT_SPEED )
                relativeX = MOVEMENT_SPEED;
            if ( relativeY > MOVEMENT_SPEED )
                relativeY = MOVEMENT_SPEED;
            
            LocalPlayer->MomentumX = relativeX;
            LocalPlayer->MomentumY = relativeY;
        }
    }
    
    // I REMEMBER YOU.... IN THE MOUNTAINS!!!
    [GameMap GameTick];
    [self RenderFloors];
    [self RenderWallsandObjects];
}

// Respond to screen touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for (UITouch* t in touches)
    {
        touching++;
        touchX = [t locationInView:self.view].x;
        touchY = [t locationInView:self.view].y;
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    for (UITouch* t in touches)
    {
        touchX = [t locationInView:self.view].x;
        touchY = [t locationInView:self.view].y;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* t in touches)
    {
        touching--;
    }
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{

}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_NORMAL, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
