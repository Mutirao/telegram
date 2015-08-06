//
//  TGSharedLinkRowView.m
//  Telegram
//
//  Created by keepcoder on 24.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSharedLinkRowView.h"
#import "MessageTableItemText.h"
#import "TGWebpageContainer.h"
#import "POPCGUtils.h"
#import "TGEmbedModalView.h"
#import "TGSharedLinksTableView.h"
@interface TGSharedLinkRowView ()
@property (nonatomic,strong) TGCTextView *textField;
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) TMHyperlinkTextField *linkField;
@property (nonatomic,strong) TGImageView *imageView;

@property (nonatomic,assign,getter=isEditable,readonly) BOOL editable;

@property (nonatomic,strong) BTRButton *selectButton;

@property (nonatomic,strong) TMTextField *domainTextField;

@property (nonatomic,strong) TMView *imageContainerView;

@end

#define s_lox 30

@implementation TGSharedLinkRowView


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR set];
    
    NSRectFill(NSMakeRect(72, 0, NSWidth(dirtyRect) - 24, 1));

}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _containerView = [[TMView alloc] initWithFrame:NSMakeRect(12, 0, NSWidth(frameRect) - 24, NSHeight(frameRect))];
        
        [self addSubview:_containerView];
        
        
        _textField = [[TGCTextView alloc] initWithFrame:self.bounds];
        
        [_textField setEditable:YES];
        [_containerView addSubview:_textField];
        
                
        _linkField = [TMHyperlinkTextField defaultTextField];
        [[_linkField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_linkField cell] setTruncatesLastVisibleLine:YES];
        [_linkField setFont:TGSystemFont(13)];
        [_linkField setTextColor:LINK_COLOR];
        
        [_linkField setFrameSize:NSMakeSize(0, 20)];
        dispatch_block_t block = ^{
            open_link(_linkField.stringValue);
        };
        
        [_linkField setClickBlock:^{
           
            block();
            
        }];
        
        [_containerView addSubview:_linkField];
        
        
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        
        _imageView.cornerRadius = 4;
        
        
        dispatch_block_t embed = ^{
           
            
            MessageTableItemText *item = ((MessageTableItemText *)self.item);
            
            if([item.webpage.webpage.embed_type isEqualToString:@"iframe"])
            {
                TGEmbedModalView *embed =  [[TGEmbedModalView alloc] init];
                
                [embed setWebpage:item.webpage.webpage];
                
                [embed show:self.window animated:YES];
                
                
            } else {
                block();
            }
            
        };
        
        [_imageView setTapBlock:^{
            embed();
        }];
        
        
        self.imageContainerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 50, 50)];
        
        [self.imageContainerView addSubview:_imageView];
        
        
        [self.containerView addSubview:self.imageContainerView];
        
        _domainTextField = [TMTextField defaultTextField];
        
        [_domainTextField setFont:TGSystemFont(20)];
        [_domainTextField setTextColor:[NSColor whiteColor]];
        
        [_imageView addSubview:_domainTextField];
        
        self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(-image_ComposeCheckActive().size.width, 0, image_ComposeCheckActive().size.width, image_ComposeCheckActive().size.height)];
        
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateSelected];
        
        [self.selectButton setUserInteractionEnabled:NO];
        
        [self.selectButton setHidden:YES];
        [self.containerView addSubview:self.selectButton];

        
    }
    
    return self;
}

static NSImage *sharedLinkCapImage() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 50, 50);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xf1f1f1) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:4 yRadius:4];
        [path fill];
        
        [image unlockFocus];
    });
    return image;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_containerView setFrame:NSMakeRect(12, 0, newSize.width - 24, newSize.height)];
    [self.selectButton setCenteredYByView:self.containerView];
}

-(void)mouseDown:(NSEvent *)theEvent {
    if(self.isEditable) {
        
        TGDocumentsMediaTableView *table = (TGDocumentsMediaTableView *) self.item.table;
        
        [table setSelected:![table isSelectedItem:self.item] forItem:self.item];
        
        [self setSelected:[table isSelectedItem:self.item]];
    } else {
        [super mouseDown:theEvent];
    }
}

-(NSString *)firstDomainCharacter {
    
    MessageTableItemText *item = (MessageTableItemText *)self.item;
    
    NSString *url;
    
    if(item.webpage)
        url = item.webpage.webpage.url;
     else
         if(item.links.count > 0)
             url = item.links[0];
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
    
    return [[components.host substringToIndex:1] uppercaseString];
}


-(void)setItem:(MessageTableItemText *)item {
    
    [super setItem:item];
    
    
    
    
    [_textField setHidden:item.webpage == nil];
    
    
    [self.linkField setFrame:NSMakeRect(self.isEditable ? s_lox-2 + 60 : 60 , 5, NSWidth(_containerView.frame) - (self.isEditable ? s_lox + 60 : 65), 20)];
    [_imageContainerView setFrame:NSMakeRect(self.isEditable ? s_lox : 0, NSHeight(self.containerView.frame) - 50 - 5, 50, 50)];
   
    if(item.webpage) {
        [_textField setAttributedString:item.webpage.desc];
        
        [_textField setFrameSize:item.webpage.descSize];
        
        [_textField setFrameOrigin:NSMakePoint(self.isEditable ? s_lox +60 : 62, NSHeight(self.frame) - NSHeight(_textField.frame) - 5 )];
        
        
        
        [_linkField setStringValue:item.webpage.webpage.url];
        
        [_imageView setObject:item.webpage.imageObject];
        
    } else {
        [_linkField setAttributedStringValue:item.allAttributedLinks];
        [_linkField setFrameSize:item.allAttributedLinksSize];
        
        [_linkField setCenteredYByView:_linkField.superview];
        
    }
    
    if(!item.webpage.imageObject)
         self.imageView.image = sharedLinkCapImage();
    
    
    [_domainTextField setHidden:item.webpage.imageObject != nil];
    
    [_domainTextField setStringValue:[self firstDomainCharacter]];
    [_domainTextField sizeToFit];
    [_domainTextField setCenterByView:_imageView];
    
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
    [self.selectButton setSelected:self.isSelected];
    
    if(animated) {
        
        [self.selectButton setHidden:NO];
        
        [self.selectButton setAlphaValue:1];
        
        if(editable){
            [self.selectButton setAlphaValue:0];
        }
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [context setDuration:0.2];
            
            
            [[self.textField animator] setFrameOrigin:NSMakePoint(editable ? s_lox + 60 : 62, NSMinY(self.textField.frame))];
            [[self.imageContainerView animator] setFrameOrigin:NSMakePoint(editable ? s_lox : 0, NSMinY(self.imageContainerView.frame))];
            [[self.linkField animator] setFrame:NSMakeRect(editable ? s_lox-2 + 60 : 60 , NSMinY(self.linkField.frame), NSWidth(_containerView.frame) - (self.isEditable ? s_lox + 60 : 65), NSHeight(self.linkField.frame))];
            [[self.selectButton animator] setFrameOrigin:NSMakePoint(self.isEditable ? 0 : -NSWidth(self.selectButton.frame), NSMinY(self.selectButton.frame))];
            
            [[self.selectButton animator] setAlphaValue:editable ? 1 : 0];
            
        } completionHandler:^{
            [self setItem:self.item];
        }];
        
  
        
        
    } else {
        [self setItem:self.item];
    }
    
}

-(BOOL)isEditable {
    return [(TGSharedLinksTableView *)self.item.table isEditable];
}

-(void)setSelected:(BOOL)selected {
    [self.selectButton setSelected:selected];
}

-(BOOL)isSelected {
    return [(TGSharedLinksTableView *)self.item.table isSelectedItem:self.item];
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    
    [super _didChangeBackgroundColorWithAnimation:anim toColor:color];
    
    if(!anim) {
        self.textField.backgroundColor = color;
        return;
    }
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    
    animation.property = [POPAnimatableProperty propertyWithName:@"background" initializer:^(POPMutableAnimatableProperty *prop) {
        
        [prop setReadBlock:^(TGCTextView *textView, CGFloat values[]) {
            POPCGColorGetRGBAComponents(textView.backgroundColor.CGColor, values);
        }];
        
        [prop setWriteBlock:^(TGCTextView *textView, const CGFloat values[]) {
            CGColorRef color = POPCGColorRGBACreate(values);
            textView.backgroundColor = [NSColor colorWithCGColor:color];
        }];
        
    }];
    
    animation.toValue = anim.toValue;
    animation.fromValue = anim.fromValue;
    animation.duration = anim.duration;
    [self.textField pop_addAnimation:animation forKey:@"background"];
    
}



-(void)_colorAnimationEvent {
    
    CALayer *currentLayer = (CALayer *)[self.textField.layer presentationLayer];
    
    id value = [currentLayer valueForKeyPath:@"backgroundColor"];
    
    self.textField.layer.backgroundColor = (__bridge CGColorRef)(value);
    [self.textField setNeedsDisplay:YES];
    
}

@end
