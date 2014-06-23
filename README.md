This demo used to explain that how can we create a Bookself UI design & downloading books from given url on multiple threads. 
This demo used ASIHTTP class for multiple downloading. For creating Bookself, UICollection view is used. Application is only 
for iPad devices since Books are preferable in iPad devices. But you ca integrate into iPhone devices too.

For creating a simple Book self add TableCell .h & .m files into your projects.

import TableCell into yourviewController. Within viewDidLoad of yourViewController add
 //In case of .xib
[self.myCollectionView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellWithReuseIdentifier:CollectionCellIdentifier];
//Or 
[self.myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCellIdentifier"];//If you are using storyboard


Within -(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
add follwing

 TableCell *cell=(TableCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellIdentifier forIndexPath:indexPath];
 
and also all neccessary collectionView delegate/UICollectionViewDelegateFlowLayout methods.
Run your Book Self view is done.

Now If you want to add download functionallty. Add all methods/variabless from BookSelfViewController .h&.m class into yourviewController.

Now main point is number of files to download. In viewDidLoad method of yourviewController, create urlArray with download urls.

Ex. For download option
urlArray = [[NSMutableArray alloc ]initWithObjects:@"http://dl.dropbox.com/u/97700329/file1.mp4",@"http://dl.dropbox.com/u/97700329/file2.mp4",@"http://dl.dropbox.com/u/97700329/file3.mp4",@"http://dl.dropbox.com/u/97700329/FileZilla_3.6.0.2_i686-apple-darwin9.app.tar.bz2",@"http://dl.dropbox.com/u/97700329/GCDExample-master.zip", nil];

Rest leave on me. Feel free to report any issue, If you found.
