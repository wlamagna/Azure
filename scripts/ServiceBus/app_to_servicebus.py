from flask import Flask, request
from azure.servicebus import ServiceBusClient, ServiceBusMessage
app = Flask(__name__)

CONNECTION_STR = "Endpoint=sb://respect.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=<SOMEKE>"
QUEUE_NAME = "anumber"

@app.route('/')


def hello():
    anumber = 0
    try:
        anumber = request.args.get('anumber')
    except:
        return "<h1>Value a number was not set</h1>"

    # Create a Service Bus client
    with ServiceBusClient.from_connection_string(CONNECTION_STR) as client:
        # Get a sender object for the queue
        with client.get_queue_sender(queue_name=QUEUE_NAME) as sender:
            # 1. Send a single message
            single_message = ServiceBusMessage(anumber)
            sender.send_messages(single_message)
    return f'<h1>Hello from Docker Number given was: {anumber}!</h1>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
