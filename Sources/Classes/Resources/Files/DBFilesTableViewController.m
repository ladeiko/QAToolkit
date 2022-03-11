// The MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DBFilesTableViewController.h"
#import "NSBundle+QAToolkit.h"
#import "UILabel+QAToolkit.h"
#import "DBFileTableViewCell.h"
#import "FilePreviewController.h"
#import "WebviewPreviewViewContoller.h"
#import "UIColor+QAToolkit.h"
#import "QAToolkit.h"

static NSString *const DBFilesTableViewControllerDirectoryCellIdentifier = @"DirectoryCell";
static NSString *const DBFilesTableViewControllerFileCellIdentifier = @"FileCell";
static NSString *const DBFilesTableViewControllerSkippedDirectory = @"QAToolkit";
static const NSInteger DBFilesTableViewControllerNextSizeAbbreviationThreshold = 1024;

@interface DBFilesTableViewController ()

@property (nonatomic, strong, readonly) NSMutableArray *subdirectories;
@property (nonatomic, strong, readonly) NSMutableArray *files;
@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, weak) IBOutlet UILabel *pathLabel;
@property (nonatomic, copy) NSString* rootPath;
@property (nonatomic, copy) NSArray<NSString*>* sharedContainers;
@end

@implementation DBFilesTableViewController
@synthesize sharedContainers;

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    //NSURL *urlResouses = [[NSBundle bundleWithIdentifier:@"Open Source.QAToolkit"] resourceURL];
    
    NSBundle *bundle = [NSBundle debugToolkitBundle];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBFileTableViewCell" bundle:bundle]
         forCellReuseIdentifier:DBFilesTableViewControllerFileCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
    [self setupBackgroundLabel];
    [self setupContents];
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedInInstancesOfClasses:@[[DBFilesTableViewController class]]];//LABEL APPEARANCE
    [appearanceLabel setTextColor:UIColor.labelText];
}

- (void)setupContents {

    if (self.path == nil) {
        self.path = NSHomeDirectory();
        self.rootPath = self.path;
        self.sharedContainers = [QAToolkit registeredSecurityApplicationGroupIdentifiers];
    }

    if (self.path) {
        NSString* const relPath = [self.path stringByReplacingOccurrencesOfString:self.rootPath withString:@""];
        self.pathLabel.text = [relPath isEqualToString:@""] ? @"/" : relPath;
    }
    else {
        self.pathLabel.text = @"/";
    }

    NSMutableArray *subdirectories = [NSMutableArray array];
    NSMutableArray *files = [NSMutableArray array];
    NSError *error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
    for (NSString *element in directoryContent) {
        if ([element isEqualToString:DBFilesTableViewControllerSkippedDirectory]) {
            continue;
        }
        BOOL isDirectory;
        NSString *fullElementPath = [self.path stringByAppendingPathComponent:element];
        [[NSFileManager defaultManager] fileExistsAtPath:fullElementPath isDirectory:&isDirectory];
        if (isDirectory) {
            [subdirectories addObject:element];
        } else {
            [files addObject:element];
        }
    }
    _subdirectories = [NSMutableArray arrayWithArray:[subdirectories sortedArrayUsingSelector:@selector(compare:)]];
    _files = [NSMutableArray arrayWithArray:[files sortedArrayUsingSelector:@selector(compare:)]];
    [self refreshBackgroundLabel];
}

#pragma mark - Background label

- (void)setupBackgroundLabel {
    self.backgroundLabel = [UILabel tableViewBackgroundLabel];
    self.tableView.backgroundView = self.backgroundLabel;
}

- (void)refreshBackgroundLabel {
    self.backgroundLabel.text = self.subdirectories.count + self.files.count > 0 ? @"" : @"This directory is empty.";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.subdirectories.count;
        case 1:
            return self.files.count;
        case 2:
            return self.sharedContainers.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            UITableViewCell *subdirectoryCell = [tableView dequeueReusableCellWithIdentifier:DBFilesTableViewControllerDirectoryCellIdentifier];
            subdirectoryCell.textLabel.text = self.subdirectories[indexPath.row];
            return subdirectoryCell;
        }

        case 1:
        {
            NSString *fileName = self.files[indexPath.row];
            DBFileTableViewCell *fileCell = [tableView dequeueReusableCellWithIdentifier:DBFilesTableViewControllerFileCellIdentifier];
            fileCell.nameLabel.text = fileName;
            fileCell.sizeLabel.text = [self sizeStringForFileWithName:fileName];
            return fileCell;
        }

        case 2:
        {
            UITableViewCell *subdirectoryCell = [tableView dequeueReusableCellWithIdentifier:DBFilesTableViewControllerDirectoryCellIdentifier];
            subdirectoryCell.textLabel.text = self.sharedContainers[indexPath.row];
            return subdirectoryCell;
        }
        default:
            assert(false);
            return [UITableViewCell new];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fullPath = [self fullPathForElementWithIndexPath:indexPath];
    return [[NSFileManager defaultManager] isDeletableFileAtPath:fullPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *fullPath = [self fullPathForElementWithIndexPath:indexPath];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (error) {
            [self presentAlertWithError:error];
        } else {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      fullPath,@"path",nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QATFileDeletedNotification" object:self userInfo:userInfo];
            
            [self removeElementFromDataSourceWithIndexPath:indexPath];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self refreshBackgroundLabel];
            
            
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 2:
            if (!self.sharedContainers.count) {
                return nil;
            }
            return @"Shared Containers";
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            NSString *subdirectoryName = self.subdirectories[indexPath.row];
            NSBundle *bundle = [NSBundle debugToolkitBundle];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBFilesTableViewController" bundle:bundle];
            DBFilesTableViewController *filesTableViewController = [storyboard instantiateInitialViewController];
            filesTableViewController.path = [self.path stringByAppendingPathComponent:subdirectoryName];
            filesTableViewController.rootPath = self.rootPath;
            filesTableViewController.title = subdirectoryName;
            [self.navigationController pushViewController:filesTableViewController animated:YES];
            break;
        }

        case 1:
        {
            //QLPreviewController qlController = [QLPreviewController i
            //NSBundle *bundle = [NSBundle debugToolkitBundle];
          //  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBFileViewController" bundle:bundle];
            NSString *fullPath = [self fullPathForElementWithIndexPath:indexPath];

            if([[[NSURL fileURLWithPath:fullPath] pathExtension] isEqual:@"plist"]){
                WebviewPreviewViewContoller *PreviewController = [[WebviewPreviewViewContoller alloc]initWithPath:fullPath];
                [self.navigationController pushViewController:PreviewController animated:YES];
            }
            else if ([[[NSURL fileURLWithPath:fullPath] pathExtension] isEqual:@"json"]){
                WebviewPreviewViewContoller *PreviewController = [[WebviewPreviewViewContoller alloc]initWithPath:fullPath];
                [self.navigationController pushViewController:PreviewController animated:YES];
            }
            else{
                FilePreviewController *PreviewController = [[FilePreviewController alloc] initWithPath:fullPath];
                [self.navigationController pushViewController:PreviewController animated:YES];
            }

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case 2:
        {
            NSBundle *bundle = [NSBundle debugToolkitBundle];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DBFilesTableViewController" bundle:bundle];
            DBFilesTableViewController *filesTableViewController = [storyboard instantiateInitialViewController];
            filesTableViewController.path = [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:self.sharedContainers[indexPath.row]].path;
            filesTableViewController.rootPath = filesTableViewController.path;
            filesTableViewController.title = self.sharedContainers[indexPath.row];
            [self.navigationController pushViewController:filesTableViewController animated:YES];
            break;
        }
    }
}

#pragma mark - File size

- (NSString *)sizeStringForFileWithName:(NSString *)fileName {
    NSString *fullPath = [self.path stringByAppendingPathComponent:fileName];
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil] fileSize];
    NSArray *sizeUnitAbbreviations = [NSArray arrayWithObjects:@"B", @"KB", @"MB", @"GB", nil];
    for (int abbreviationIndex = 0; abbreviationIndex < sizeUnitAbbreviations.count; abbreviationIndex++) {
        if (fileSize < DBFilesTableViewControllerNextSizeAbbreviationThreshold) {
            return [NSString stringWithFormat:@"%llu%@", fileSize, sizeUnitAbbreviations[abbreviationIndex]];
        }
        fileSize /= DBFilesTableViewControllerNextSizeAbbreviationThreshold;
    }
    
    return nil;
}

#pragma mark - Element paths

- (NSString* _Nullable)fullPathForElementWithIndexPath:(NSIndexPath *)indexPath {
    NSString *elementName;
    switch (indexPath.section) {
        case 0:
            elementName = self.subdirectories[indexPath.row];
            break;
        case 1:
            elementName = self.files[indexPath.row];
            break;
        case 2:
            if (!self.sharedContainers) {
                return nil;
            }
            return [NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:self.sharedContainers[indexPath.row]].path;
    }
    return [self.path stringByAppendingPathComponent:elementName];
}

- (void)removeElementFromDataSourceWithIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *affectedArray;
    switch (indexPath.section) {
        case 0:
            affectedArray = self.subdirectories;
            break;
        case 1:
            affectedArray = self.files;
            break;
        case 2:
            return;
    }
    [affectedArray removeObjectAtIndex:indexPath.row];
}

#pragma mark - Alert

- (void)presentAlertWithError:(NSError *)error {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Deletion error"
                                                                   message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
