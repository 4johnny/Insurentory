//
//  EHDotLinkedStoryboardSegue.m
//
//  Created by Eli Hini on 2014-10-21.
//  Copyright (c) 2014 Venovis Inc. All rights reserved.
//

#import "EHDotLinkedStoryboardSegue.h"

@implementation EHDotLinkedStoryboardSegue

+ (UIViewController *)sceneNamed:(NSString *)identifier
{
    NSArray *info = [identifier componentsSeparatedByString:@"."];
    NSString *storyboardName = [info firstObject];
    NSString *sceneName = nil;
    
    if (info.count == 2)
    {
       sceneName = info[1];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *scene = nil;
    
    if (sceneName.length == 0)
    {
        scene = [storyboard instantiateInitialViewController];
    }
    else
    {
        scene = [storyboard instantiateViewControllerWithIdentifier:sceneName];
    }
    
    return scene;
}

+ (UIViewController*)sceneWithName:(NSString*)sceneName inStoryboardNamed:(NSString*)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *scene = nil;
    
    if (scene != nil && sceneName.length > 0)
    {
        scene = [storyboard instantiateViewControllerWithIdentifier:sceneName];
    }
    else
    {
        scene = [storyboard instantiateInitialViewController];
    }
    
    return scene;
}

- (id)initWithIdentifier:(NSString *)identifier
                  source:(UIViewController *)source
             destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier
                              source:source
                         destination:[EHDotLinkedStoryboardSegue sceneNamed:identifier]];
}

- (void)perform
{
    UIViewController *source = (UIViewController *)self.sourceViewController;
    [source.navigationController pushViewController:self.destinationViewController
                                           animated:YES];
}
@end
