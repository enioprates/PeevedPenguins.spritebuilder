//
//  Gameplay.h
//  PeevedPenguins
//
//  Created by Enio on 08/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>{
    CCNode* _levelNode;
    CCNode* _contentNode;
    CCPhysicsNode* _physicsNode;
    CCNode* _catapultArm;
    CCPhysicsJoint *_catapultJoint;
    CCNode* _catapult;
    CCNode* _pullbackNode;
    CCPhysicsJoint* _pullbackJoint;
    CCNode* _mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    
    CCNode* _currentPenguin;
    CCPhysicsJoint* _penguinCatapultJoint;
}
@end
