//
//  MainViewController.m
//  iSampleDocument
//
//  Created by Bernardo Breder on 25/03/14.
//  Copyright (c) 2014 Bernardo Breder. All rights reserved.
//

#import "MainViewController.h"

#define PTK_EXTENSION @"ptk"

@interface MainViewController () {
    NSMutableArray *_objects;
    NSURL * _localRoot;
    NSURL * _iCloudRoot;
    BOOL _iCloudAvailable;
    NSMetadataQuery * _query;
    BOOL _iCloudURLsReady;
    NSMutableArray * _iCloudURLs;
    NSURL * _selURL;
    BOOL _moveLocalToiCloud;
    BOOL _copyiCloudToLocal;
}

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation MainViewController

@synthesize mainTableView;

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    {
        UIView *navView = [[UIView alloc] init];
        navView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        [self.view addSubview:navView];
        CONSTRAINT_ON(navView);
        CONSTRAINT(self.view, NSLayoutAttributeLeft, navView, NSLayoutAttributeLeft, 1.0, 0.0);
        CONSTRAINT(self.view, NSLayoutAttributeRight, navView, NSLayoutAttributeRight, 1.0, 0.0);
        CONSTRAINT(self.view, NSLayoutAttributeTop, navView, NSLayoutAttributeTop, 1.0, 0.0);
        CONSTRAINT(self.view, NSLayoutAttributeHeight, navView, NSLayoutAttributeHeight, 0.0, 70.0);
        {
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            [addButton addTarget:self action:@selector(onAddAction) forControlEvents:UIControlEventTouchUpInside];
            [navView addSubview:addButton];
            CONSTRAINT4(addButton, navView, NSLayoutAttributeLeft, 1.0, 0.0, NSLayoutAttributeWidth, 0.0, 44.0, NSLayoutAttributeTop, 1.0, 20.0, NSLayoutAttributeBottom, 1.0, 0.0)
        }
    }
    {
        mainTableView = [[UITableView alloc] init];
        [self.view addSubview:mainTableView];
        CONSTRAINT_ON(mainTableView);
        CONSTRAINT(self.view, NSLayoutAttributeLeft, mainTableView, NSLayoutAttributeLeft, 1.0, 0.0);
        CONSTRAINT(self.view, NSLayoutAttributeWidth, mainTableView, NSLayoutAttributeWidth, 1.0, 0.0);
        CONSTRAINT(self.view, NSLayoutAttributeTop, mainTableView, NSLayoutAttributeTop, 1.0, 71.0);
        CONSTRAINT(self.view, NSLayoutAttributeBottom, mainTableView, NSLayoutAttributeBottom, 1.0, 0.0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _objects = [[NSMutableArray alloc] init];
    _iCloudURLs = [[NSMutableArray alloc] init];
    [self refresh];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didBecomeActive:(NSNotification *)notification {
    [self refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [_query enableUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_query disableUpdates];
}

- (void)onAddAction
{
    
}

//#pragma mark File management methods
//
//- (void)loadDocAtURL:(NSURL *)fileURL {
//    
//    // Open doc so we can read metadata
//    PTKDocument * doc = [[PTKDocument alloc] initWithFileURL:fileURL];
//    [doc openWithCompletionHandler:^(BOOL success) {
//        
//        // Check status
//        if (!success) {
//            NSLog(@"Failed to open %@", fileURL);
//            return;
//        }
//        
//        // Preload metadata on background thread
//        PTKMetadata * metadata = doc.metadata;
//        NSURL * fileURL = doc.fileURL;
//        UIDocumentState state = doc.documentState;
//        NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
//        NSLog(@"Loaded File URL: %@, State: %@, Last Modified: %@", [doc.fileURL lastPathComponent], [self stringForState:state], version.modificationDate.mediumString);
//        
//        // Close since we're done with it
//        [doc closeWithCompletionHandler:^(BOOL success) {
//            
//            // Check status
//            if (!success) {
//                NSLog(@"Failed to close %@", fileURL);
//                // Continue anyway...
//            }
//            
//            // Add to the list of files on main thread
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self addOrUpdateEntryWithURL:fileURL metadata:metadata state:state version:version];
//            });
//        }];
//    }];
//    
//}
//
//- (void)deleteEntry:(PTKEntry *)entry {
//    
//    // Wrap in file coordinator
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
//        [fileCoordinator coordinateWritingItemAtURL:entry.fileURL
//                                            options:NSFileCoordinatorWritingForDeleting
//                                              error:nil
//                                         byAccessor:^(NSURL* writingURL) {
//                                             // Simple delete to start
//                                             NSFileManager* fileManager = [[NSFileManager alloc] init];
//                                             [fileManager removeItemAtURL:entry.fileURL error:nil];
//                                         }];
//    });
//    // Fixup view
//    [self removeEntryWithURL:entry.fileURL];
//    
//}
//
- (void)iCloudToLocalImpl {
    
    NSLog(@"iCloud => local impl");
    
    for (NSURL * fileURL in _iCloudURLs) {
        
        NSString * fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
        NSURL *destURL = [self getDocURL:[self getDocFilename:fileName uniqueInObjects:YES]];
        
        // Perform copy on background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [fileCoordinator coordinateReadingItemAtURL:fileURL options:NSFileCoordinatorReadingWithoutChanges error:nil byAccessor:^(NSURL *newURL) {
                NSFileManager * fileManager = [[NSFileManager alloc] init];
                NSError * error;
                BOOL success = [fileManager copyItemAtURL:fileURL toURL:destURL error:&error];
                if (success) {
                    NSLog(@"Copied %@ to %@ (%d)", fileURL, destURL, self.iCloudOn);
//                    [self loadDocAtURL:destURL];
                } else {
                    NSLog(@"Failed to copy %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                }
            }];
        });
    }
    
}

- (void)iCloudToLocal {
    NSLog(@"iCloud => local");
    
    // Wait to find out what user wants first
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"You're Not Using iCloud" message:@"What would you like to do with the documents currently on this iPad?" delegate:self cancelButtonTitle:@"Continue Using iCloud" otherButtonTitles:@"Keep a Local Copy", @"Keep on iCloud Only", nil];
    alertView.tag = 2;
    [alertView show];
    
}

- (void)localToiCloudImpl {
    
    NSLog(@"local => iCloud impl");
    
    NSArray * localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot includingPropertiesForKeys:nil options:0 error:nil];
    for (int i=0; i < localDocuments.count; i++) {
        
        NSURL * fileURL = [localDocuments objectAtIndex:i];
        if ([[fileURL pathExtension] isEqualToString:PTK_EXTENSION]) {
            
            NSString * fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
            NSURL *destURL = [self getDocURL:[self getDocFilename:fileName uniqueInObjects:NO]];
            
            // Perform actual move in background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                NSError * error;
                BOOL success = [[NSFileManager defaultManager] setUbiquitous:self.iCloudOn itemAtURL:fileURL destinationURL:destURL error:&error];
                if (success) {
                    NSLog(@"Moved %@ to %@", fileURL, destURL);
//                    [self loadDocAtURL:destURL];
                } else {
                    NSLog(@"Failed to move %@ to %@: %@", fileURL, destURL, error.localizedDescription);
                }
            });
        }
    }
}

- (void)localToiCloud {
    NSLog(@"local => iCloud");
    
    // If we have a valid list of iCloud files, proceed
    if (_iCloudURLsReady) {
        [self localToiCloudImpl];
    }
    // Have to wait for list of iCloud files to refresh
    else {
        _moveLocalToiCloud = YES;
    }
}

#pragma mark iCloud Query

- (NSMetadataQuery *)documentQuery {
    
    NSMetadataQuery * query = [[NSMetadataQuery alloc] init];
    if (query) {
        
        // Search documents subdir only
        [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        
        // Add a predicate for finding the documents
        NSString * filePattern = [NSString stringWithFormat:@"*.%@", PTK_EXTENSION];
        [query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                             NSMetadataItemFSNameKey, filePattern]];
        
    }
    return query;
    
}

- (void)stopQuery {
    
    if (_query) {
        
        NSLog(@"No longer watching iCloud dir...");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [_query stopQuery];
        _query = nil;
    }
    
}

- (void)startQuery {
    
    [self stopQuery];
    
    NSLog(@"Starting to watch iCloud dir...");
    
    _query = [self documentQuery];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(processiCloudFiles:)
//                                                 name:NSMetadataQueryDidFinishGatheringNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(processiCloudFiles:)
//                                                 name:NSMetadataQueryDidUpdateNotification
//                                               object:nil];
    
    [_query startQuery];
}

//- (void)processiCloudFiles:(NSNotification *)notification
//{
//    // Always disable updates while processing results
//    [_query disableUpdates];
//    [_iCloudURLs removeAllObjects];
//    // The query reports all files found, every time.
//    NSArray * queryResults = [_query results];
//    for (NSMetadataItem * result in queryResults) {
//        NSURL * fileURL = [result valueForAttribute:NSMetadataItemURLKey];
//        NSNumber * aBool = nil;
//        // Don't include hidden files
//        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
//        if (aBool && ![aBool boolValue]) {
//            [_iCloudURLs addObject:fileURL];
//        }
//    }
//    NSLog(@"Found %d iCloud files.", _iCloudURLs.count);
//    _iCloudURLsReady = YES;
//    if ([self iCloudOn]) {
//        // Remove deleted files
//        // Iterate backwards because we need to remove items form the array
//        for (int i = _objects.count -1; i >= 0; --i) {
//            PTKEntry * entry = [_objects objectAtIndex:i];
//            if (![_iCloudURLs containsObject:entry.fileURL]) {
//                [self removeEntryWithURL:entry.fileURL];
//            }
//        }
//        // Add new files
//        for (NSURL * fileURL in _iCloudURLs) {
//            [self loadDocAtURL:fileURL];
//        }
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
//    if (_moveLocalToiCloud) {
//        _moveLocalToiCloud = NO;
//        [self localToiCloudImpl];
//    }
//    else if (_copyiCloudToLocal) {
//        _copyiCloudToLocal = NO;
//        [self iCloudToLocalImpl];
//    }
//    [_query enableUpdates];
//}

#pragma mark Refresh Methods

- (void)loadLocal {
    
    NSArray * localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot includingPropertiesForKeys:nil options:0 error:nil];
    NSLog(@"Found %d local files.", localDocuments.count);
    for (int i=0; i < localDocuments.count; i++) {
        
        NSURL * fileURL = [localDocuments objectAtIndex:i];
        if ([[fileURL pathExtension] isEqualToString:PTK_EXTENSION]) {
            NSLog(@"Found local file: %@", fileURL);
//            [self loadDocAtURL:fileURL];
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)refresh {
    
    _iCloudURLsReady = NO;
    [_iCloudURLs removeAllObjects];
    [_objects removeAllObjects];
    [mainTableView reloadData];
    [self initializeiCloudAccessWithCompletion:^(BOOL available) {
        _iCloudAvailable = available;
        if (!_iCloudAvailable) {
            // If iCloud isn't available, set promoted to no (so we can ask them next time it becomes available)
            [self setiCloudPrompted:NO];
            // If iCloud was toggled on previously, warn user that the docs will be loaded locally
            if ([self iCloudWasOn]) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"You're Not Using iCloud" message:@"Your documents were removed from this iPad but remain stored in iCloud." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
            // No matter what, iCloud isn't available so switch it to off.
            [self setiCloudOn:NO];
            [self setiCloudWasOn:NO];
        } else {
            // Ask user if want to turn on iCloud if it's available and we haven't asked already
            if (![self iCloudOn] && ![self iCloudPrompted]) {
                [self setiCloudPrompted:YES];
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"iCloud is Available" message:@"Automatically store your documents in the cloud to keep them up-to-date across all your devices and the web." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Use iCloud", nil];
                alertView.tag = 1;
                [alertView show];
            }
            // If iCloud newly switched off, move local docs to iCloud
            if ([self iCloudOn] && ![self iCloudWasOn]) {
                [self localToiCloud];
            }
            // If iCloud newly switched on, move iCloud docs to local
            if (![self iCloudOn] && [self iCloudWasOn]) {
                [self iCloudToLocal];
            }
            // Start querying iCloud for files, whether on or off
            [self startQuery];
            // No matter what, refresh with current value of iCloudOn
            [self setiCloudWasOn:[self iCloudOn]];
        }
        if (![self iCloudOn]) {
            [self loadLocal];
        }
    }];
}

//#pragma mark - UITableViewDataSource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return _objects.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PTKEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    
//    PTKEntry *entry = [_objects objectAtIndex:indexPath.row];
//    
//    cell.titleTextField.text = entry.description;
//    cell.titleTextField.delegate = self;
//    if (entry.metadata && entry.metadata.thumbnail) {
//        cell.photoImageView.image = entry.metadata.thumbnail;
//    } else {
//        cell.photoImageView.image = nil;
//    }
//    if (entry.version) {
//        cell.subtitleLabel.text = [entry.version.modificationDate mediumString];
//    } else {
//        cell.subtitleLabel.text = @"";
//    }
//    if (entry.state & UIDocumentStateInConflict) {
//        cell.warningImageView.hidden = NO;
//    } else {
//        cell.warningImageView.hidden = YES;
//    }
//    
//    return cell;
//}

#pragma mark Helpers

- (NSString *)stringForState:(UIDocumentState)state {
    NSMutableArray * states = [NSMutableArray array];
    if (state == 0) {
        [states addObject:@"Normal"];
    }
    if (state & UIDocumentStateClosed) {
        [states addObject:@"Closed"];
    }
    if (state & UIDocumentStateInConflict) {
        [states addObject:@"In Conflict"];
    }
    if (state & UIDocumentStateSavingError) {
        [states addObject:@"Saving error"];
    }
    if (state & UIDocumentStateEditingDisabled) {
        [states addObject:@"Editing disabled"];
    }
    return [states componentsJoinedByString:@", "];
}

- (BOOL)iCloudOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudOn"];
}

- (void)setiCloudOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"iCloudOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)iCloudWasOn {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudWasOn"];
}

- (void)setiCloudWasOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"iCloudWasOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)iCloudPrompted {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudPrompted"];
}

- (void)setiCloudPrompted:(BOOL)prompted {
    [[NSUserDefaults standardUserDefaults] setBool:prompted forKey:@"iCloudPrompted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL *)localRoot {
    if (_localRoot != nil) {
        return _localRoot;
    }
    
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    _localRoot = [paths objectAtIndex:0];
    return _localRoot;
}

- (NSURL *)getDocURL:(NSString *)filename {
    if ([self iCloudOn]) {
        NSURL * docsDir = [_iCloudRoot URLByAppendingPathComponent:@"Documents" isDirectory:YES];
        return [docsDir URLByAppendingPathComponent:filename];
    } else {
        return [self.localRoot URLByAppendingPathComponent:filename];
    }
}

- (BOOL)docNameExistsInObjects:(NSString *)docName {
    BOOL nameExists = NO;
//    for (PTKEntry * entry in _objects) {
//        if ([[entry.fileURL lastPathComponent] isEqualToString:docName]) {
//            nameExists = YES;
//            break;
//        }
//    }
    return nameExists;
}

- (BOOL)docNameExistsIniCloudURLs:(NSString *)docName {
    BOOL nameExists = NO;
    for (NSURL * fileURL in _iCloudURLs) {
        if ([[fileURL lastPathComponent] isEqualToString:docName]) {
            nameExists = YES;
            break;
        }
    }
    return nameExists;
}

- (NSString*)getDocFilename:(NSString *)prefix uniqueInObjects:(BOOL)uniqueInObjects {
    NSInteger docCount = 0;
    NSString* newDocName = nil;
    
    // At this point, the document list should be up-to-date.
    BOOL done = NO;
    BOOL first = YES;
    while (!done) {
        if (first) {
            first = NO;
            newDocName = [NSString stringWithFormat:@"%@.%@",
                          prefix, PTK_EXTENSION];
        } else {
            newDocName = [NSString stringWithFormat:@"%@ %d.%@",
                          prefix, docCount, PTK_EXTENSION];
        }
        
        // Look for an existing document with the same name. If one is
        // found, increment the docCount value and try again.
        BOOL nameExists;
        if (uniqueInObjects) {
            nameExists = [self docNameExistsInObjects:newDocName];
        } else {
            nameExists = [self docNameExistsIniCloudURLs:newDocName];
        }
        if (!nameExists) {
            break;
        } else {
            docCount++;
        }
        
    }
    
    return newDocName;
}

- (void)initializeiCloudAccessWithCompletion:(void (^)(BOOL available)) completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _iCloudRoot = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (_iCloudRoot != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud available at: %@", _iCloudRoot);
                completion(TRUE);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"iCloud not available");
                completion(FALSE);
            });
        }
    });
}

@end
