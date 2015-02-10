//
//  EHDotLinkedStoryboardSegue.h
//  Giusto
//
//  Created by Eli Hini on 2014-10-21.
//  Copyright (c) 2014 Venovis Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHDotLinkedStoryboardSegue : UIStoryboardSegue
+ (UIViewController*)sceneWithName:(NSString*)sceneName inStoryboardNamed:(NSString*)storyboardName;
@end
