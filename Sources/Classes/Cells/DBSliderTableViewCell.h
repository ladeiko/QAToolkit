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

@class DBSliderTableViewCell;

/**
 A protocol used for passing the text view delegate methods.
 */
@protocol DBSliderTableViewCellDelegate <NSObject>



@end

/**
 `DBTextViewTableViewCell` is a table view cell displaying a title and a text view allowing the user to input a multiline content.
 */
@interface DBSliderTableViewCell : UITableViewCell

/**
 An outlet to `UILabel` instance displaying the title of the value contained in the text view.
 */
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;



/**
 Delegate that will be responsible for handling some of the `UITextViewDelegate` methods. It needs to conform to `DBTextViewTableViewCellDelegate` protocol.
 */
@property (nonatomic, weak) id <DBSliderTableViewCellDelegate> delegate;

@end
