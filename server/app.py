import os
import time
from flask import Flask, request, jsonify, send_file
from flask_socketio import SocketIO, emit
from werkzeug.utils import secure_filename
import zipfile
import shutil
from lib.panel_cleaner import PanelCleaner
from lib.iopaint import Iopaint
import threading

UPLOAD_FOLDER = '.'

app = Flask(__name__)
socketio = SocketIO(app)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def wait_for_file(file_path, check_interval=5):
    while not os.path.exists(file_path):
        time.sleep(check_interval)

@socketio.on('panel_cleaner')
def handle_panel_cleaner(data):
    if os.path.exists('cleaner'):
        shutil.rmtree('cleaner')
    os.makedirs('cleaner')
    os.makedirs('cleaner/raw')
    os.makedirs('cleaner/mask')

    raw_zip_path = '/content/drive/MyDrive/raw.zip'

    wait_for_file(raw_zip_path)

    with zipfile.ZipFile(raw_zip_path, 'r') as zip_ref:
        zip_ref.extractall('cleaner/raw')

    t = threading.Thread(target=PanelCleaner.process_files, args=(socketio,))
    t.start()
    socketio.emit('log', {'message': 'PanelCleaner started.'})

@socketio.on('redraw')
def redraw():
    mask_zip_path = '/content/drive/MyDrive/mask.zip'

    wait_for_file(mask_zip_path)

    with zipfile.ZipFile(mask_zip_path, 'r') as zip_ref:
        zip_ref.extractall('cleaner/mask')

    t = threading.Thread(target=Iopaint.inpainting, args=(socketio,))
    t.start()
    socketio.emit('log', {'message': 'Redraw started.'})

@socketio.on('ping')
def ping():
    socketio.emit('ping', {'message': 'pong.'})

if __name__ == "__main__":
    socketio.run(app)
