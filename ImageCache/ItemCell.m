//
//  ItemCell.m
//  ImageCache
//
//  Created by Hantao Yang on 12/7/21.
//

#import "ItemCell.h"
#import "UIImageView+ImageCache.h"

@interface ItemCell()

@property (nonatomic, weak) IBOutlet UIImageView *cellImageView;

@end

@implementation ItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)configCell:(NSString *)urlStr{
    [self.cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.cellImageView setImage:urlStr completion:nil];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.cellImageView.image = nil;
    [self.cellImageView cancelImageLoading];
    
}
@end
