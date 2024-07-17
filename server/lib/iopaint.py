import subprocess
import os
import shutil
from PIL import Image

class Iopaint:
	def inpainting(socketio):
		for root, dirs, files in os.walk('cleaner/raw'):
			for _dir in dirs:
				input_path = os.path.join(root, _dir)
				mask_path = input_path.replace('raw', 'mask', 1)
				output_path = input_path.replace('raw', 'output', 1).replace('raw', 'cleaned', 1)

				os.makedirs(output_path, exist_ok=True)

				if has_images(input_path):
					print(f'inpaiting: {input_path}, output: {output_path}')
					process = subprocess.Popen(f'iopaint run --device cuda --image {input_path} --mask {mask_path} --output {output_path}'.split())
					process.wait()
		
		convert_png_to_jpg('cleaner/output')
		if os.path.exists('result.zip'):
			os.remove('result.zip')
		shutil.make_archive("result", "zip", "cleaner/output")
		socketio.emit('download_cleaned', {})


def convert_png_to_jpg(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.png'):
                png_path = os.path.join(root, file)
                jpg_path = png_path.replace('.png', '.jpg')

                with Image.open(png_path) as img:
                    rgb_img = img.convert('RGB')
                    rgb_img.save(jpg_path, 'JPEG')
                
                os.remove(png_path)

def has_images(directory):
    for file in os.listdir(directory):
        if file.lower().endswith(('.png', '.jpg', '.jpeg')):
            return True
    return False
