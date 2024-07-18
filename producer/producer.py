import time
from confluent_kafka import Producer

# Wait for Kafka to be ready
time.sleep(10)

conf = {'bootstrap.servers': "kafka:9092"}
producer = Producer(conf)

def delivery_report(err, msg):
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))

while True:
    producer.produce('test-topic', key='key', value='hello from producer', callback=delivery_report)
    producer.poll(0)
    time.sleep(1)  # Sleep for 1 second before producing the next message

producer.flush()