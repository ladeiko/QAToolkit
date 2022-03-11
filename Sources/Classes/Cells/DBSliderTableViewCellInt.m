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

#import "DBSliderTableViewCellInt.h"
#import "UIColor+QAToolkit.h"

@interface DBSliderTableViewCellInt ()

@end

@implementation DBSliderTableViewCellInt
@synthesize valueLabel;
@synthesize slider;

- (void)awakeFromNib {
    [super awakeFromNib];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueLabel.textColor = [UIColor labelText];
}

-(IBAction)sliderValueChanged:(UISlider *)sender{
    int discreteValue = roundl([sender value]); // Rounds float to an integer
    valueLabel.text = [NSString stringWithFormat:@"%i", discreteValue];
    [sender setValue:(float)discreteValue]; // Sets your slider to this value
}

-(NSNumber*)getValue{
    return [NSNumber numberWithFloat:self.slider.value];
}

@end
