import UIKit
import RxSwift
import Moscapsule

class RxMqttClient {

    let connected: Variable<Bool> = Variable(false)
    let incomingMessages: Variable<(String, String)?> = Variable(nil)
    var subscriptions: [String: Observable<String>] = [:]

    var mqttClient: MQTTClient! = nil
    
    init() {
        let mqttConfig = MQTTConfig(clientId: UUID().uuidString, host: "broker.hivemq.com", port: 1883, keepAlive: 60)
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
        if let subscription = subscriptions[topic] {
            return subscription
        } else {
            let subscription = createSubscription(to: topic, qos: qos)
            subscriptions[topic] = subscription
            return subscription
        }
    }

    private func createSubscription(to topic: String, qos: Int32) -> Observable<String> {
        return connect()
            .flatMap { self.trySubscribe(to: topic, qos: qos) }
            .flatMap { _ in self.incomingMessages.asObservable() }
            .filter { message in
                guard let (messageTopic, _) = message else { return false }
                return messageTopic == topic }
            .map { message in message! }
            .map { (topic, payload) in payload }
            .share()
    }
    
    private func connect() -> Observable<Void> {
        return self.connected.asObservable().filter { $0 }.map { _ in }
    }
    
    private func trySubscribe(to topic: String, qos: Int32 = 2) -> Observable<Int> {
        return Observable.create({ observer in
            let cancel = Disposables.create { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.subscriptions.removeValue(forKey: topic)
                strongSelf.mqttClient.unsubscribe(topic)
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
