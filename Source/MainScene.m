//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene
    - (void) play {
        CCLOG(@"play button pressed!");
        CCScene *gameplayScene = [CCBReader loadAsScene:@"gameplay"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
    }
@end
