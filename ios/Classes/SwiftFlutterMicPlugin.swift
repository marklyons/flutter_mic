import Flutter
import UIKit
import AVFoundation
import AVKit
//import SwiftSocket

public class SwiftFlutterMicPlugin: NSObject, FlutterPlugin {
  let audioEngine  = AVAudioEngine()
  let audioSession = AVAudioSession.sharedInstance()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_mic", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterMicPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "startRecording":
      initializeRecorder()
    default:
      result(FlutterMethodNotImplemented)
    }
    
    result(1)
  }
  
  public func initializeRecorder() {
    do {
      try audioSession.setPreferredSampleRate(44100)
    } catch {
      print("Error setting sample rate: \(error)")
    }
    
    startRecording()
  }
  
  /*
  func initUDPclient() -> UDPClient {
    let client = UDPClient(address: "localhost", port: 6100)
    return client
  }
  
  func sendUDPpacket(udpClient: UDPClient, pcmSample: Data) {
    switch(udpClient.send(data: pcmSample)) {
    case .success:
      //print("Packet sent.")
      break
    case .failure(let error):
      print("ERROR: \(error.localizedDescription).")
      break
    }
  }
  */
  
  func startRecording() {
    let bus = 0
    //let udpClient = initUDPclient()
    let inputNode = audioEngine.inputNode
    let inputFormat = inputNode.inputFormat(forBus: bus)
    
    inputNode.installTap(onBus: bus, bufferSize: 32, format: inputFormat) {
      (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
      // We don't ever use this variable
      let _: AVAudioConverterInputBlock = { inNumPackets, outStatus in
        if #available(iOS 9.0, *) {
          outStatus.pointee = AVAudioConverterInputStatus.haveData
        } else {
          // Fallback on earlier versions
        }
        return buffer
      }
      
      /*  So it looks like SwiftSockets is pretty broken and doesn't allow us to just send this packet
       in its entirety which is strange because it's only 8820 bytes. UDP is a max of like 65,000 bytes
       or something like that. So this just splits it up into two packets. The procedure is kind of
       convoluted but I genuinely couldn't find good documentation on this stuf.. */
      let pcmSample = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
      print(pcmSample)
      /*
      let pcmSample_b1 = pcmSample[0..<2205]
      let pcmSample_b2 = pcmSample[2205..<4410]
      
      let _ = pcmSample_b1.withUnsafeBufferPointer{ bufferIN -> Float in
        let bufferData1 = Data(buffer: bufferIN)
        self.sendUDPpacket(udpClient: udpClient, pcmSample: bufferData1)
        return 0.0 //dont ask me..
      }
      
      let _ = pcmSample_b2.withUnsafeBufferPointer{ bufferIN -> Float in
        let bufferData2 = Data(buffer: bufferIN)
        self.sendUDPpacket(udpClient: udpClient, pcmSample: bufferData2)
        return 0.0
      }
       */
    }
    
    // Final engine stuff.
    audioEngine.prepare()
    do {
      try audioEngine.start()
    } catch {
      print("Error info: \(error)")
    }
  }
}
