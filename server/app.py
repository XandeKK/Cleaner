import os
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

@socketio.on('panel_cleaner')
def handle_panel_cleaner(data):
    if os.path.exists('cleaner'):
        shutil.rmtree('cleaner')
    os.makedirs('cleaner')
    os.makedirs('cleaner/raw')
    os.makedirs('cleaner/mask')

    with zipfile.ZipFile(os.path.join('/content/drive/MyDrive', data.filename), 'r') as zip_ref:
        zip_ref.extractall('cleaner/raw')

    t = threading.Thread(target=PanelCleaner.process_files, args=(socketio,))
    t.start()
    socketio.emit('message', {'message': 'PanelCleaner started.'})

@socketio.on('redraw')
def redraw():
    with zipfile.ZipFile('/content/drive/MyDrive/mask.zip', 'r') as zip_ref:
        zip_ref.extractall('cleaner/mask')

    t = threading.Thread(target=Iopaint.inpainting, args=(socketio,))
    t.start()
    socketio.emit('message', {'message': 'Redraw started.'})

if __name__ == "__main__":
    socketio.run(app)