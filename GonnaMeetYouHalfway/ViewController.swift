//
//  ViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 12/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import Moscapsule

class ViewController: UIViewController {

    var mqttClient: MQTTClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let mqttConfig = MQTTConfig(clientId: "karwer-a048e4923f4ad202f10eb51476c39995", host: "broker.hivemq.com", port: 1883, keepAlive: 60)
        mqttConfig.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
            // publish and subscribe
            self.mqttClient.publish(string: "message from simulator", topic: "karwer/test/1", qos: 2, retain: false)
            self.mqttClient.subscribe("karwer/test/2", qos: 2)
        }
        mqttConfig.onMessageCallback = { mqttMessage in
            NSLog("MQTT Message received: payload=\(mqttMessage.payloadString)")
        }
        
        // create new MQTT Connection
        mqttClient = MQTT.newConnection(mqttConfig)
        
        // disconnect
        // mqttClient.disconnect()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

