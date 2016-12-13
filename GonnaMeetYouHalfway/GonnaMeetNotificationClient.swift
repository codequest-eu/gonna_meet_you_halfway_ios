//
//  GonnaMeetNotificationClient.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 12/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import RxSwift
import Moscapsule

class GonnaMeetNotificationClient {

    let incomingMessages: Variable<(String, String)?> = Variable(nil)

    lazy var mqttClient: MQTTClient = {
        let mqttConfig = MQTTConfig(clientId: UUID().uuidString, host: "broker.hivemq.com", port: 1883, keepAlive: 60)
        mqttConfig.onMessageCallback = { [weak self] (message: MQTTMessage) in
            if let payload = message.payloadString {
                self?.incomingMessages.value = (message.topic, payload)
            }
        }
        return MQTT.newConnection(mqttConfig)
    }()
    
    private func subscribe(to topic: String, qos: Int32 = 2) -> Observable<String> {
        return trySubscribe(to: topic, qos: qos)
            .flatMap { _ in self.incomingMessages.asObservable() }
            .filter { message in
                guard let (messageTopic, _) = message else { return false }
                return messageTopic == topic }
            .map { message in message! }
            .map { (topic, payload) in payload }
    }
    
    private func trySubscribe(to topic: String, qos: Int32 = 2) -> Observable<Int> {
        return Observable.create({ observer in
            let cancel = Disposables.create {
                self.mqttClient.unsubscribe(topic)
            }
            self.mqttClient.subscribe(topic, qos: qos, requestCompletion: { (result, messageId) in
                if !cancel.isDisposed {
                    if result == .mosq_success {
                        observer.onNext(messageId)
                        observer.onCompleted()
                    } else {
                        observer.onError(GonnaMeetError.cannotSubscribe)
                    }
                }
            })
            return cancel
        })
    }
    
}
