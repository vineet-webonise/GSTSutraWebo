//
//  FAQDetailViewController.m
//  GSTSutra
//
//  Created by niyuj on 1/19/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "FAQDetailViewController.h"

@interface FAQDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *ansLabel;

@end

@implementation FAQDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitleLabel:@"CBEC FAQs"];
    [self setupBackBarButtonItems];
    @try {
        _questionLabel.hidden = YES;
        _ansLabel.hidden = YES;
        
        UILabel *faqLabel = [[UILabel alloc] init];
        faqLabel.font = [UIFont fontWithName:centuryGothicRegular size:titleFont];
        
        
        NSAttributedString *tempQues = [[NSAttributedString alloc] initWithData:[self.QueString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        
        NSString *boldString  = [[[@"Q " stringByAppendingString:[tempQues string]] stringByAppendingString:@"\n\n"] stringByAppendingString:@"Ans "];
        
        NSAttributedString *tempAtributedString =  [[NSAttributedString alloc] initWithData:[self.AnsString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        
        
        NSString *yourString =  [boldString stringByAppendingString:[tempAtributedString string]];
        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
        
        NSRange boldRange = [yourString rangeOfString:boldString];
        [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:centuryGothicBold size:titleFont] range:boldRange];
        
        NSString *str = [tempAtributedString string];
        
        CGRect textRect = [str boundingRectWithSize:CGSizeMake(SCREENWIDTH, 999)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont fontWithName:centuryGothicBold size:titleFont]}
                                            context:nil];
        
        CGSize size = textRect.size;
        
        faqLabel.frame = CGRectMake(10, 20, SCREENWIDTH - 10, size.height+ 100);
        faqLabel.numberOfLines = 0;
        [faqLabel setAttributedText: yourAttributedString];
        [self.view addSubview:faqLabel];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
