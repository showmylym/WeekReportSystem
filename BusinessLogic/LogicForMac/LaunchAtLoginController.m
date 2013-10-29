//
//  LaunchAtLoginController.m
//
//  Copyright 2011 Tomáš Znamenáček
//  Copyright 2010 Ben Clark-Robinson
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the ‘Software’),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "LaunchAtLoginController.h"

static NSString *const StartAtLoginKey = @"launchAtLogin";
static NSString *const kLaunchedItemURLs = @"LaunchedItemURLs";
static NSString *const kURLStrings = @"urlStrings";

@interface LaunchAtLoginController ()
@property(assign) LSSharedFileListRef loginItems;
@end

@implementation LaunchAtLoginController
@synthesize loginItems;

#pragma mark Change Observing

void sharedFileListDidChange(LSSharedFileListRef inList, void *context)
{
    LaunchAtLoginController *self = (id) context;
    [self willChangeValueForKey:StartAtLoginKey];
    [self didChangeValueForKey:StartAtLoginKey];
}

#pragma mark Initialization

- (id) init
{
    [super init];
    loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    LSSharedFileListAddObserver(loginItems, CFRunLoopGetMain(),
        (CFStringRef)NSDefaultRunLoopMode, sharedFileListDidChange, self);
    return self;
}

- (void) dealloc
{
    LSSharedFileListRemoveObserver(loginItems, CFRunLoopGetMain(),
        (CFStringRef)NSDefaultRunLoopMode, sharedFileListDidChange, self);
    CFRelease(loginItems);
    [super dealloc];
}

#pragma mark Launch List Control

- (LSSharedFileListItemRef) findItemWithURL: (NSURL*) wantedURL inFileList: (LSSharedFileListRef) fileList
{
    if (wantedURL == NULL || fileList == NULL)
        return NULL;

    NSArray *listSnapshot = [NSMakeCollectable(LSSharedFileListCopySnapshot(fileList, NULL)) autorelease];
    for (id itemObject in listSnapshot) {
        LSSharedFileListItemRef item = (LSSharedFileListItemRef) itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        if (currentItemURL && CFEqual(currentItemURL, wantedURL)) {
            CFRelease(currentItemURL);
            return item;
        }
        if (currentItemURL)
            CFRelease(currentItemURL);
    }

    return NULL;
}

- (BOOL) willLaunchAtLogin: (NSURL*) itemURL
{
    return !![self findItemWithURL:itemURL inFileList:loginItems];
}

- (void) setLaunchAtLogin: (BOOL) enabled forURL: (NSURL*) itemURL
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [userDefaults valueForKey:kLaunchedItemURLs];
    NSMutableDictionary * muDict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (dict != nil) {
        [muDict setValuesForKeysWithDictionary:dict];
    }
    NSArray * lastURLStrings = [muDict valueForKey:kURLStrings];
    NSMutableArray * urlStrings = [NSMutableArray arrayWithCapacity:10];
    if ([lastURLStrings count] > 0) {
        [urlStrings setArray:lastURLStrings];
    } 
    LSSharedFileListItemRef appItem = [self findItemWithURL:itemURL inFileList:loginItems];
    if (enabled && !appItem) {
        LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
            NULL, NULL, (CFURLRef)itemURL, NULL, NULL);
        [urlStrings addObject:[itemURL absoluteString]];
    } else if (!enabled && appItem) {
        LSSharedFileListItemRemove(loginItems, appItem);
        //if it doesn't contain the url string, then the method has no effect 
        [urlStrings removeObject:[itemURL absoluteString]];
    }
    [muDict setValue:urlStrings forKey:kURLStrings];
    [userDefaults setValue:muDict forKey:kLaunchedItemURLs];
    [userDefaults synchronize];
}

#pragma mark Basic Interface

- (NSURL*) appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void) setLaunchAtLogin: (BOOL) enabled
{
    [self willChangeValueForKey:StartAtLoginKey];
    [self setLaunchAtLogin:enabled forURL:[self appURL]];
    [self didChangeValueForKey:StartAtLoginKey];
}

- (BOOL) launchAtLogin
{
    return [self willLaunchAtLogin:[self appURL]];
}

- (void)removeAllWeekReportItems {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [userDefaults valueForKey:kLaunchedItemURLs];
    if (dict != nil) {
        NSArray * urlStrings = [dict valueForKey:kURLStrings];
        for (NSString * urlString in urlStrings) {
            NSURL * url = [NSURL URLWithString:urlString];
            [self setLaunchAtLogin:NO forURL:url];
        }
    }
    [userDefaults setValue:@{} forKey:kLaunchedItemURLs];
    [userDefaults synchronize];
}

@end
