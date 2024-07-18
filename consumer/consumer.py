import socket
import time
from confluent_kafka import Consumer, KafkaException, KafkaError

# Wait for Kafka to be ready
time.sleep(10)

# Test connectivity to Kafka broker
def test_kafka_connectivity():
    try:
        sock = socket.create_connection(("kafka", 9092), timeout=10)
        print("Connection to Kafka broker successful")
        sock.close()
    except Exception as e:
        print(f"Connection to Kafka broker failed: {e}")

test_kafka_connectivity()

conf = {
    'bootstrap.servers': 'kafka:9092',
    'group.id': 'test-group',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe(['test-topic'])

try:
    while True:
        msg = consumer.poll(timeout=1.0)
        if msg is None:
            print("No message received in this poll interval")
            continue

        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                print(f"End of partition reached {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")
                continue
            else:
                print(f"Error: {msg.error()}")
                break
        else:
            print(f"Message received: {msg.key()}: {msg.value()}")
            if msg.key() is not None and msg.value() is not None:
                print(f"Consumer received message: {msg.value().decode('utf-8')}")
                print(f"That producer is saying: {msg.value().decode('utf-8')}")
            else:
                print(f"Consumed invalid message: key={msg.key()}, value={msg.value()}")

except KafkaException as e:
    print(f"Kafka exception: {e}")
except Exception as e:
    print(f"General exception: {e}")
finally:
    consumer.close()