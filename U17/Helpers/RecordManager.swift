import Foundation
import AVFoundation

class RecordManager: NSObject {
        
    static let shareManager:RecordManager =  RecordManager()
        
    var volumeTimer:Timer! //定时器线程，循环监测录音的音量大小
    typealias volumeCallBack_ = (_ averagePower:Float?,_ peakPower:Float?,_ lowPass:Double?)->()
    typealias audioResultCallBack_ = (_ duration:Double?,_ base64Data:String?)->()
    var volumeCallBack:volumeCallBack_?

    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    
    let file_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/record.wav")
    
    private override init() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let err{
            print("设置类型失败:\(err.localizedDescription)")
        }
        //设置session动作
        do {
            try session.setActive(true)
        } catch let err {
            print("初始化动作失败:\(err.localizedDescription)")
        }
    }
    func getInstance() -> RecordManager{
        return self
    }

    open func beginRecord(resultBack:@escaping volumeCallBack_){
        self.volumeCallBack = resultBack
        let recordSetting: [String: Any] = [AVSampleRateKey: NSNumber(value: 44000),//采样率
                                            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
                                            AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
                                            AVNumberOfChannelsKey: NSNumber(value: 2),//录音的声道数，立体声为双声道
                                            AVEncoderBitRateKey : 320000,
                                            AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.max.rawValue)//录音质量
        ];
        
        //开始录音
        do {
            let url = URL(fileURLWithPath: file_path!)
            recorder = try AVAudioRecorder(url: url, settings: recordSetting)
            recorder!.prepareToRecord()
            volumeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                selector: #selector(levelTimer),
                                userInfo: nil, repeats: true)
            recorder!.isMeteringEnabled = true
            recorder!.record()
            print("开始录音")
        } catch let err {
            print("录音失败:\(err.localizedDescription)")
        }
    }
    
    //定时检测录音音量
    @objc func levelTimer(){
        recorder!.updateMeters() // 刷新音量数据
        let averagePower:Float = recorder!.averagePower(forChannel: 0) //获取音量的平均值
        let peakPower:Float = recorder!.peakPower(forChannel: 0) //获取音量最大值
        let lowPass:Double = pow(Double(10), Double(0.05*peakPower))
        volumeCallBack!(averagePower,peakPower,lowPass)
//        print(String(format: "0 averageV: %f maxV: %f maxV: %f",averageV,maxV,lowPassResult))

    }
    //结束录音
    func stopRecord()-> RecordManager{
        if let recorder = self.recorder {
            if recorder.isRecording {
                print("正在录音，马上结束它，文件保存到了：\(file_path!)")
            }else {
                print("没有录音，但是依然结束它")
            }
            volumeTimer.invalidate()
            recorder.stop()
            volumeTimer = nil
            self.recorder = nil
        }else {
            print("没有初始化")
        }
        return self
    }
    
    func fetchResult(resultBack:@escaping audioResultCallBack_){
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file_path!))
            let fileData = try! NSData(contentsOfFile: file_path!, options: NSData.ReadingOptions.mappedIfSafe)
            let base64Data = "data:audio/.wav;base64," + fileData.base64EncodedString()
            print("长度：\(player!.duration)")
            resultBack(player!.duration,base64Data.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
}
