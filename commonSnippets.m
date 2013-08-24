//ios6 only
-(void) addRefreshControll{

UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
[refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
[myTableView addSubview:refreshControl];
}

//Copy Text to Clipboard
-(void) copyToPasteboaed:(NSString *) string {
UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
pasteboard.string = string;

}

//Take Screenshot Programmatically

-(void) tajeScreenShot {

UIGraphicsBeginImageContext(self.view.bounds.size);
[self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);

}

//Get Screen Size from Orientation

- (CGSize) currentSize{
    return [self sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}
 
- (CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
        size = CGSizeMake(size.height, size.width);
    if (application.statusBarHidden == NO)
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    return size;
}

// Email validation

-(BOOL)validateEmail: (NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}


//Thumbnail Image from PDF

- (UIImage *)buildThumbnailImage
{
    BOOL hasRetinaDisplay = FALSE;  // by default
    CGFloat pixelsPerPoint = 1.0;  // by default (pixelsPerPoint is just the "scale" property of the screen)
    
    if ([UIScreen instancesRespondToSelector:@selector(scale)])  // the "scale" property is only present in iOS 4.0 and later
        {
        // we are running iOS 4.0 or later, so we may be on a Retina display;  we need to check further...
        if ((pixelsPerPoint = [[UIScreen mainScreen] scale]) == 1.0)
            hasRetinaDisplay = FALSE;
        else
            hasRetinaDisplay = TRUE;
        }
    else
        {
        // we are NOT running iOS 4.0 or later, so we can be sure that we are NOT on a Retina display
        pixelsPerPoint = 1.0;
        hasRetinaDisplay = FALSE;
        }
    
    size_t imageWidth = 190;  // width of thumbnail in points
    size_t imageHeight = 210;  // height of thumbnail in points
    
    if (hasRetinaDisplay)
        {
        imageWidth *= pixelsPerPoint;
        imageHeight *= pixelsPerPoint;
        }
    
    size_t bytesPerPixel = 4;  // RGBA
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = bytesPerPixel * imageWidth;
    
    void *bitmapData = malloc(imageWidth * imageHeight * bytesPerPixel);
    
    // in the event that we were unable to mallocate the heap memory for the bitmap,
    // we just abort and preemptively return nil:
    if (bitmapData == NULL)
        return nil;
    
    // remember to zero the buffer before handing it off to the bitmap context:
    bzero(bitmapData, imageWidth * imageHeight * bytesPerPixel);
    
    CGContextRef theContext = CGBitmapContextCreate(bitmapData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow,
                                                    CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    
    NSURL* pdfFileUrl = [NSURL fileURLWithPath:inputPDFFile];

    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfFileUrl);  // NOTE: you will need to modify this line to supply the CGPDFDocumentRef for your file here...
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, 1);  // get the first page for your thumbnail
    
    CGAffineTransform shrinkingTransform =
    CGPDFPageGetDrawingTransform(pdfPage, kCGPDFMediaBox, CGRectMake(0, 0, imageWidth, imageHeight), 0, YES);
    
    CGContextConcatCTM(theContext, shrinkingTransform);
    
    CGContextDrawPDFPage(theContext, pdfPage);  // draw the pdfPage into the bitmap context
    CGPDFDocumentRelease(pdfDocument);
    
    //
    // create the CGImageRef (and thence the UIImage) from the context (with its bitmap of the pdf page):
    //
    CGImageRef theCGImageRef = CGBitmapContextCreateImage(theContext);
    free(CGBitmapContextGetData(theContext));  // this frees the bitmapData we malloc'ed earlier
    CGContextRelease(theContext);
    
    UIImage *theUIImage;
    
    // CAUTION: the method imageWithCGImage:scale:orientation: only exists on iOS 4.0 or later!!!
    if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
        {
        theUIImage = [UIImage imageWithCGImage:theCGImageRef scale:pixelsPerPoint orientation:UIImageOrientationUp];
        }
    else
        {
        theUIImage = [UIImage imageWithCGImage:theCGImageRef];
        }
    
    CFRelease(theCGImageRef);
    return theUIImage;
}

//return array of files from directory path

-(NSArray *) filesInDirectoryPath:(NSString *) path {

    NSError *error;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSArray *filelist= [filemgr contentsOfDirectoryAtPath:path error:&error];
    
    return filelist;

}


//Create directory with name 
- (void)createDirectoryInDocumentsFolderWithName:(NSString *)dirName {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *yourDirPath = [documentsDirectory stringByAppendingPathComponent:dirName];     
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL isDirExists = [fileManager fileExistsAtPath:yourDirPath isDirectory:&isDir];
    if (!isDirExists) [fileManager createDirectoryAtPath:yourDirPath withIntermediateDirectories:YES attributes:nil error:nil];
}

// pring all responsers
- (void)_printNextResponder {
    id nextObj = self;
    while (nextObj) {
        NSLog(@"nextResponder %@",nextObj);
        nextObj = [nextObj nextResponder];
    }
}

