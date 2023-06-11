import UIKit
 
class ImageController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
 
    //图片展示
    @IBOutlet weak var image: UIImageView!
    var takingPicture:UIImagePickerController!
    
    //点击按钮弹出拍照、相册的选择框
    @IBAction func getImage(_ sender: Any) {
        let actionSheetController = UIAlertController()
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { (alertAction) -> Void in
            print("Tap 取消 Button")
        }
        
        let takingPicturesAction = UIAlertAction(title: "拍照", style: UIAlertAction.Style.destructive) { (alertAction) -> Void in
            self.getImageGo(type: 1)
        }
        
        let photoAlbumAction = UIAlertAction(title: "相册", style: UIAlertAction.Style.default) { (alertAction) -> Void in
            self.getImageGo(type: 2)
        }
                
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(takingPicturesAction)
        actionSheetController.addAction(photoAlbumAction)
        
        //iPad设备浮动层设置锚点
        actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
        //显示
        self.present(actionSheetController, animated: true, completion: nil)
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "pic"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view.
    }
    
    //去拍照或者去相册选择图片
    func getImageGo(type:Int){
        takingPicture =  UIImagePickerController.init()
        if(type==1){
            takingPicture.sourceType = .camera
            //拍照时是否显示工具栏
            //takingPicture.showsCameraControls = true
        }else if(type==2){
            takingPicture.sourceType = .photoLibrary
        }
        //是否截取，设置为true在获取图片后可以将其截取成正方形
        takingPicture.allowsEditing = false
        takingPicture.delegate = self
        present(takingPicture, animated: true, completion: nil)
    }
    
    //拍照或是相册选择返回的图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        takingPicture.dismiss(animated: true, completion: nil)
        if(takingPicture.allowsEditing == false){
            //原图
            image.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }else{
            //截图
            image.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
 
    }
}
