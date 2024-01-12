import datetime
import os

from flask import Flask, jsonify

ENV = os.environ['ENV']
HOST = os.getenv('HOST', '0.0.0.0')
PORT = os.getenv('PORT', '8080')

application = Flask(__name__)


@application.route('/', methods=['GET'])
def root():
    return ('Alive!'), 200


@application.route('/healthcheck', methods=['GET'])
def health():
    return jsonify({
        'status': 'up',
        'datetime': datetime.datetime.now(),
        'test': 'tf-module-ecs-application'}), 200


if __name__ == '__main__':
    application.run(host=HOST, port=PORT, debug=False)
