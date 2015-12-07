/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The view controller displaying the root list of the app.
 */

#import "AAPLRootListViewController.h"

#import "AAPLAssetGridViewController.h"
#import "GifAssetHelper.h"
#import "AssetGroupTableViewCell.h"

@import Photos;


@interface AAPLRootListViewController () <PHPhotoLibraryChangeObserver>
{
    BOOL isCreate;
    BOOL notAuthord;
}
@property (nonatomic, strong) NSArray *sectionFetchResults;
@property (nonatomic, strong) NSArray *sectionLocalizedTitles;

@end

@implementation AAPLRootListViewController

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

static NSString * const AllPhotosSegue = @"showAllPhotos";
static NSString * const CollectionSegue = @"showCollection";

- (void)awakeFromNib {
    // Create a PHFetchResult object for each section in the table view.
    
    if (PHAuthorizationStatusAuthorized == [PHPhotoLibrary authorizationStatus]) {
        
        [self initPhotoData];
    } else {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized ) {
            
                [self initPhotoData];
            } else {
                
                notAuthord = YES;
            
            }
        }];
    }

    
}

- (void)initPhotoData {
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // Store the PHFetchResult objects and localized titles for each section.
    self.sectionFetchResults = @[allPhotos, smartAlbums, topLevelUserCollections];
    self.sectionLocalizedTitles = @[@"", NSLocalizedString(@"Smart Albums", nil), NSLocalizedString(@"Albums", nil)];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self checkNOCreatein:topLevelUserCollections];
}

-(void)checkNOCreatein:(PHFetchResult *)fetchResult {
    
    __block BOOL isExist = NO;
    
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHCollection *collection = (PHCollection *)obj;
        
        if ([collection.localizedTitle isEqualToString:NSLocalizedString(@"iDongtu", nil)]) {
            
            isExist = YES;
            
            *stop = YES;
            
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                
                PHAssetCollection *assetCollection  = (PHAssetCollection *)collection;
                
                [GifAssetHelper sharedAssetHelper].assetCollection = assetCollection;
            }
        }
        
    }];
    
    if (!isExist) {
        
        // Create a new album with the title entered.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:NSLocalizedString(@"iDongtu", nil)];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            }
            [self prepushForAll];
            
            isCreate = YES;
        }];
    } else {
        
        [self prepushForAll];
    }
    
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    

    if (notAuthord ) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"无相册访问权限\n请在设置中修改访问权限" preferredStyle:(UIAlertControllerStyleAlert)];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
            
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.juvham.iDongtu"]];
        }]];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];

    }
    
    
}
#pragma mark - UIViewController

- (void)prepushForAll {
    
    PHFetchResult *fetchResult = self.sectionFetchResults[0];
    AAPLAssetGridViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:assetGridViewController];
    viewController.assetsFetchResults = fetchResult;
    viewController.title = NSLocalizedString(@"All Photos", nil);
    [self.navigationController setViewControllers:@[self,viewController]];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*
     Get the AAPLAssetGridViewController being pushed and the UITableViewCell
     that triggered the segue.
     */
    if (![segue.destinationViewController isKindOfClass:[AAPLAssetGridViewController class]] || ![sender isKindOfClass:[UITableViewCell class]]) {
        return;
    }
    
    AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
    
    NSIndexPath *indexPath;
    
    UITableViewCell *cell = sender;
    
    // Set the title of the AAPLAssetGridViewController.

    PHFetchResult *fetchResult;
    // Get the PHFetchResult for the selected section.
    indexPath = [self.tableView indexPathForCell:cell];
    assetGridViewController.title = cell.textLabel.text;
    fetchResult = self.sectionFetchResults[indexPath.section];
    
    if ([segue.identifier isEqualToString:AllPhotosSegue]) {
        assetGridViewController.assetsFetchResults = fetchResult;
    } else if ([segue.identifier isEqualToString:CollectionSegue]) {
        // Get the PHAssetCollection for the selected row.
        PHCollection *collection = fetchResult[indexPath.row];
        if (![collection isKindOfClass:[PHAssetCollection class]]) {
            return;
        }
        
        // Configure the AAPLAssetGridViewController with the asset collection.
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        assetGridViewController.assetsFetchResults = assetsFetchResult;
        assetGridViewController.assetCollection = assetCollection;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionFetchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 74;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        // The "All Photos" section only ever has a single row.
        numberOfRows = 1;
    } else {
        PHFetchResult *fetchResult = self.sectionFetchResults[section];
        numberOfRows = fetchResult.count;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetGroupTableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
         PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        [cell setData:fetchResult];
        cell.nameLabel.text = NSLocalizedString(@"All Photos", nil);
    } else  {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        PHCollection *collection = fetchResult[indexPath.row];
        cell.nameLabel.text = collection.localizedTitle;
        
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
//        if (indexPath.section == 1) {
//            
//            assetsFetchResult = self.smartFetchResults[indexPath.row];
//            
//            
//        } else if (indexPath.section ==2) {
//            
//             assetsFetchResult = self.userCollectionFetchResults[indexPath.row];
//        }
        
         [cell setData:assetsFetchResult];
        
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionLocalizedTitles[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [self.sectionFetchResults mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [self.sectionFetchResults enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                
                PHFetchResult *fetctResult = [changeDetails fetchResultAfterChanges];
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:fetctResult];
                reloadRequired = YES;
                
                if (index == 2) {
                    
                    [fetctResult enumerateObjectsUsingBlock:^(PHAssetCollection * collection, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (isCreate) {
                            
                            if ([collection.localizedTitle isEqualToString:@"iDongtu"]) {
                                
                                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                                    
                                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                                    [GifAssetHelper sharedAssetHelper].assetCollection = assetCollection;
                                    isCreate = NO;
                                }
                            }
                        }

                    }];
                }
            }
        }];
        
        if (reloadRequired) {
            self.sectionFetchResults = updatedSectionFetchResults;
            [self.tableView reloadData];
        }
        
    });
}

#pragma mark - Actions
//
//- (IBAction)handleAddButtonItem:(id)sender {
//    // Prompt user from new album title.
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
//    
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = NSLocalizedString(@"Album Name", nil);
//    }];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:NULL]];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        UITextField *textField = alertController.textFields.firstObject;
//        NSString *title = textField.text;
//        if (title.length == 0) {
//            return;
//        }
//        
//        // Create a new album with the title entered.
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
//        } completionHandler:^(BOOL success, NSError *error) {
//            if (!success) {
//                NSLog(@"Error creating album: %@", error);
//            }
//        }];
//    }]];
//    
//    [self presentViewController:alertController animated:YES completion:NULL];
//}

@end
