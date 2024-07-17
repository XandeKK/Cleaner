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

@app.route("/images", methods=['POST'])
def upload_file():
    if os.path.exists('cleaner'):
        shutil.rmtree('cleaner')
    os.makedirs('cleaner')
    os.makedirs('cleaner/raw')
    os.makedirs('cleaner/mask')

    if 'file' not in request.files:
        return jsonify({"code": 401, "msg": "No file part"})
    file = request.files['file']

    if file.filename == '':
        return jsonify({"code": 401, "msg": "No selected file"})

    if file:
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

        with zipfile.ZipFile(filename, 'r') as zip_ref:
            zip_ref.extractall('cleaner/raw')

        t = threading.Thread(target=PanelCleaner.process_files, args=(socketio,))
        t.start()

        return jsonify({"code": 200, "msg": "Upload Success"})
    return jsonify({"code": 401, "msg": "Upload file formating error."})

@app.route("/redraw", methods=['POST'])
def redraw():
    if 'file' not in request.files:
        return jsonify({"code": 401, "msg": "No file part"})
    file = request.files['file']

    if file.filename == '':
        return jsonify({"code": 401, "msg": "No selected file"})

    if file:
        filename = secure_filename(file.filename)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

        with zipfile.ZipFile(filename, 'r') as zip_ref:
            zip_ref.extractall('cleaner/mask')

        t = threading.Thread(target=Iopaint.inpainting, args=(socketio,))
        t.start()

        return jsonify({"code": 200, "msg": "Upload Success"})
    return jsonify({"code": 401, "msg": "Upload file formating error."})

@app.route('/file')
def get_file():
    file_path = request.args.get('path')

    if file_path is not None:
        if os.path.exists(file_path):
            print(file_path)
            return send_file(file_path)
        else:
            return "File not found", 404
    else:
        return "Path is None", 400

if __name__ == "__main__":
    socketio.run(app)