//
//  MapObjectLinkedList.h
//  InternetFinder
//
//  Created by Chris Laverdure on 12-05-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapObject.h"

@interface MapObjectLinkedList : NSObject
{
    @public MapObject *MapObject;
    @public MapObjectLinkedList *next;
    @public MapObjectLinkedList *prev;  
}
@end
