import cv2
import os
import subprocess
import shutil

class PanelCleaner:
	def process_files(socketio):
		for root, dirs, files in os.walk(os.path.abspath('cleaner/raw')):
			for _dir in dirs:
				input_path = os.path.join(root, _dir)
				output_path = input_path.replace('raw', 'mask', 1)

				if has_images(input_path):
					print(f'clean: {input_path}, output: {output_path}')
					process = subprocess.Popen(f'pcleaner-cli clean {input_path} -m --output_dir={output_path}'.split(), stdout=subprocess.PIPE)
					while True:
						output = process.stdout.readline().decode()
						if output == '' and process.poll() is not None:
							break
						self.socketio.emit('log', {'message': output})
					# process.wait()

		Image.transform_images_recursively('cleaner/mask')
		shutil.make_archive("mask", "zip", "cleaner/mask")
		shutil.move('mask.zip', '/content/drive/MyDrive/mask.zip')
		socketio.emit('download_mask', {})

def has_images(directory):
    for file in os.listdir(directory):
        if file.lower().endswith(('.png', '.jpg', '.jpeg')):
            return True
    return False

class Image:
	def transform_image(path):
		im = cv2.imread(path, -1)

		non_transparent_mask = im[:, :, 3] != 0
		im[non_transparent_mask] = (255, 255, 255, 255)
		im[~non_transparent_mask] = (0, 0, 0, 255)

		im = cv2.cvtColor(im, cv2.COLOR_BGRA2BGR)

		if os.path.exists(path):
  			os.remove(path)
		path = path.replace('_mask', '').replace('.png', '.jpg')

		cv2.imwrite(path, im)

	def transform_images_recursively(path):
		for root, dirs, files in os.walk(path):
			for file in files:
				full_path = os.path.join(root, file)
				Image.transform_image(full_path)