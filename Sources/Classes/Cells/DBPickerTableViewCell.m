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

#import "DBPickerTableViewCell.h"
#import "UIColor+QAToolkit.h"

@interface DBPickerTableViewCell ()

@end

@implementation DBPickerTableViewCell

@synthesize valueLabel;
@synthesize slider;

- (void)awakeFromNib {
    [super awakeFromNib];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.valueLabel.textColor = [UIColor labelText];
}

- (void)setRangeAndVal:(NSArray*)range value:(id)val{
    
    self.applyButton.enabled = false;
    self.applyButton.alpha = 0.5;
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = [range count] - 1;
   
    self.range = range;
    if ([val isKindOfClass:[NSNumber class]]) {
        self.valueLabel.text = [val description];
    }else{
    self.valueLabel.text = val;
    }
    self.slider.value = [self.range indexOfObject:val];
}

-(IBAction)sliderValueChanged:(UISlider *)sender{
    int discreteValue = roundl([sender value]); // Rounds float to an integer
    self.applyButton.enabled = true;
    self.applyButton.alpha = 1.0;
    [sender setValue:(float)discreteValue]; // Sets your slider to this value
    
    valueLabel.text = [self.range[discreteValue] description];
}

-(NSString*)getValue{
    return self.valueLabel.text;
}

@end
