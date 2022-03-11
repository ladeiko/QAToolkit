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

#import <UIKit/UIKit.h>
#import "DBUserInterfaceToolkit.h"

@class DBUserInterfaceTableViewController;

/**
 A protocol used for informing about showing the `UIDebuggingInformationOverlay`.
 */
@protocol DBUserInterfaceTableViewControllerDelegate <NSObject>

/**
 Informs the delegate that the `UIDebuggingInformationOverlay` is shown.
 @param userInterfaceTableViewController The table view controller that received the `Show UIDebuggingInformationOverlay` cell selection.
 */
- (void)userInterfaceTableViewControllerDidOpenDebuggingInformationOverlay:(DBUserInterfaceTableViewController *)userInterfaceTableViewController;

@end

/**
 `DBUserInterfaceTableViewController` is a view controller presenting options related to user interface.
 */
@interface DBUserInterfaceTableViewController : UITableViewController

/**
 `DBUserInterfaceToolkit` instance serving as a data source for the table view controller. It is also informed about switch state changes.
 */
@property (nonatomic, strong) DBUserInterfaceToolkit *userInterfaceToolkit;

/**
 Delegate that will be informed about showing the `UIDebuggingInformationOverlay`. It needs to conform to `DBUserInterfaceTableViewControllerDelegate` protocol.
 */
@property (nonatomic, weak) id <DBUserInterfaceTableViewControllerDelegate> delegate;

@end
