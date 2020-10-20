//
//  UIWindow+DetoxUtils.m
//  Detox
//
//  Created by Leo Natan (Wix) on 6/4/20.
//  Copyright © 2020 Wix. All rights reserved.
//

#import "UIWindow+DetoxUtils.h"
#import "DTXAppleInternals.h"

@implementation UIWindow (DetoxUtils)

+ (UIWindow*)dtx_keyWindow
{
	if(@available(iOS 13, *))
	{
		return UIWindowScene._keyWindowScene._keyWindow;
	}
	else
	{
		return UIWindow.keyWindow;
	}
}

+ (NSArray<UIWindow *> *)dtx_allKeyWindowSceneWindows
{
	id scene = nil;
	
	if (@available(iOS 13.0, *))
	{
		scene = UIWindowScene._keyWindowScene;
	}
	
	return [self dtx_allWindowsForScene:scene];
}

+ (NSArray<UIWindow*>*)dtx_allWindowsForScene:(id)scene
{
	NSMutableArray<UIWindow*>* windows = [[self dtx_allWindows] mutableCopy];
	
	if (@available(iOS 13.0, *))
	{
		scene = scene ?: UIWindowScene._keyWindowScene;
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"windowScene == %@", scene];
		
		UIScene* keyboardScene = [UIWindowScene _keyboardWindowSceneForScreen:[scene screen] create:NO];
		if(keyboardScene != nil)
		{
			predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, [NSPredicate predicateWithFormat:@"windowScene == %@", keyboardScene]]];
		}
		
		[windows filterUsingPredicate:predicate];
	}
	
	return windows;
}

+ (NSArray<UIWindow*>*)dtx_allWindows
{
	return [[UIWindow allWindowsIncludingInternalWindows:YES onlyVisibleWindows:NO] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hidden == NO"]];
}

+ (void)_dtx_enumerateWindows:(NSArray<UIWindow*>*)windows usingBlock:(void (NS_NOESCAPE ^)(UIWindow* obj, NSUInteger idx, BOOL *stop))block
{
	[windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		block(obj, idx, stop);
	}];
}

+ (void)dtx_enumerateAllWindowsUsingBlock:(void (NS_NOESCAPE ^)(UIWindow* obj, NSUInteger idx, BOOL *stop))block
{
	[self _dtx_enumerateWindows:self.dtx_allWindows usingBlock:block];
}

+ (void)dtx_enumerateKeyWindowSceneWindowsUsingBlock:(void (NS_NOESCAPE ^)(UIWindow* obj, NSUInteger idx, BOOL *stop))block
{
	id scene = nil;
	
	if (@available(iOS 13.0, *))
	{
		scene = UIWindowScene._keyWindowScene;
	}
	
	[self dtx_enumerateWindowsInScene:scene usingBlock:block];
}

+ (void)dtx_enumerateWindowsInScene:(id)scene usingBlock:(void (NS_NOESCAPE ^)(UIWindow* obj, NSUInteger idx, BOOL *stop))block
{
	[self _dtx_enumerateWindows:[self dtx_allWindowsForScene:scene] usingBlock:block];
}

@end
