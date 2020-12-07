import darknet
import cv2
import numpy


def image_detection(image_path, network, class_names, class_colors, thresh):
    width = darknet.network_width(network)
    height = darknet.network_height(network)
    darknet_image = darknet.make_image(width, height, 3)

    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image_resized = cv2.resize(image_rgb, (width, height),
                               interpolation=cv2.INTER_LINEAR)

    darknet.copy_image_from_bytes(darknet_image, image_resized.tobytes())
    detections = darknet.detect_image(network, class_names, darknet_image, thresh=thresh)
    darknet.free_image(darknet_image)
    image = darknet.draw_boxes(detections, image_resized, class_colors)
    return cv2.cvtColor(image, cv2.COLOR_BGR2RGB), detections

def output_detections(detections, coordinates=False):
    message=[]
    for label, confidence, bbox in detections:
        x, y, w, h = bbox
        if coordinates:
            message.append("{}: {}%    (left_x: {:.0f}   top_y:  {:.0f}   width:   {:.0f}   height:  {:.0f})".format(label, confidence, x, y, w, h))
        else:
            message.append("{}: {}%".format(label, confidence))
    return '.'.join(str(x) for x in message)


def main():
    network, class_names, class_colors = darknet.load_network(
        "cfg/yolov4-tiny.cfg",
        "cfg/coco.data",
        "weights/yolov4-tiny.weights",
        batch_size=1
    )
    
    image_name = "../dog.jpg"
    image, detections = image_detection(
            image_name, network, class_names, class_colors, 0.1
            )
    #print(detections)
    print(output_detections(detections, True))
    cv2.imwrite('result.jpg', image)

if __name__ == "__main__":
    main()
