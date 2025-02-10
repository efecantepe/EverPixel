from flask import Flask, render_template , request , jsonify
from PIL import Image
import os , io , sys
import numpy as np 
import cv2
import base64


app = Flask(__name__)

@app.route('/filter', methods=['POST'])
def upload_image():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image part in the request'}), 400

        file = request.files['image']
        filter_type = request.form.get("filterType")

        print("#################################")
        print(filter_type)
        print("#################################")

        if file.filename == '':
            return jsonify({'error': 'No selected file'}), 400

        file_content = file.read()
        npimg = np.frombuffer(file_content, np.uint8)
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)
        filtered_image = convert_image(img, filter_type)

        img = Image.fromarray(filtered_image.astype("uint8"))
        rawBytes = io.BytesIO()
        img.save(rawBytes, "JPEG")
        rawBytes.seek(0)
        img_base64 = base64.b64encode(rawBytes.read()).decode('utf-8')  

        return jsonify({'image': img_base64})  

    except Exception as e:
        return jsonify({'error': str(e)}), 500

def convert_image(image, filter_type):
    if filter_type == "G":
        return convert_gray(image)
    elif filter_type == "B":
        return convert_blur(image)
    elif filter_type == "S":
        return convert_sharpen(image)
    elif filter_type == "E":
        return convert_edge(image)
    else:
        raise ValueError("Invalid filter type")

def convert_gray(image):
    return cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

def convert_blur(image, ksize=(5, 5)):
    return cv2.GaussianBlur(image, ksize, 0)

def convert_sharpen(image):
    kernel = np.array([[0, -1, 0],
                       [-1, 5, -1],
                       [0, -1, 0]])
    return cv2.filter2D(image, -1, kernel)

def convert_edge(image):
    return cv2.Canny(image, 100, 200)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
