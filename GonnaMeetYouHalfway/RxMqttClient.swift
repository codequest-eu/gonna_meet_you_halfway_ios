import UIKit
import RxSwift
import Moscapsule

class RxMqttClient {

    let connected: Variable<Bool> = Variable(false)
    let incomingMessages: Variable<(String, String)?> = Variable(nil)

    var mqttClient: MQTTClient! = nil
    
    init() {
        let mqttConfig = MQTTConfig(clientId: UUID().uuidString, host: "139.59.150.73", port: 1883, keepAlive: 60)
		mqttConfig.mqttAuthOpts = MQTTAuthOpts(username: "half-way-codequest", password: "password1")
		mqttConfig.cleanSession = false
        mqttConfig.onMessageCallback = { [weak self] (message: MQTTMessage) in
            if let payload = message.payloadString {
                self?.incomingMessages.value = (message.topic, payload)
            }
        }
        mqttConfig.onConnectCallback = { [weak self] _ in
            self?.connected.value = true
        }
        mqttConfig.onDisconnectCallback = { [weak self] _ in
            self?.connected.value = false
        }
        mqttClient = MQTT.newConnection(mqttConfig)
    }
    
    func publish(to topic: String, message: String, qos: Int32 = 2, retain: Bool = true) {
        mqttClient.publish(string: message, topic: topic, qos: qos, retain: retain)
    }
    
    func subscribe(to topic: String, qos: Int32 = 2) -> Observable<String> {
        return connect()
            .flatMap { self.trySubscribe(to: topic, qos: qos) }
            .flatMap { _ in self.incomingMessages.asObservable() }
            .filter { message in
                guard let (messageTopic, _) = message else { return false }
                return messageTopic == topic }
            .map { message in message! }
            .map { (topic, payload) in payload }
    }
    
    private func connect() -> Observable<Void> {
        return self.connected.asObservable().filter { $0 }.map { _ in }
    }
    
    private func trySubscribe(to topic: String, qos: Int32 = 2) -> Observable<Int> {
        return Observable.create({ observer in
            let cancel = Disposables.create {
                self.mqttClient.unsubscribe(topic)
            }
            self.mqttClient.subscribe(topic, qos: qos) { (result, messageId) in
                if !cancel.isDisposed {
                    if result == .mosq_success {
                        observer.onNext(messageId)
                    } else {
                        observer.onError(GonnaMeetError.cannotSubscribe(result: result))
                    }
                }
            }
            return cancel
        })
    }
    
}
