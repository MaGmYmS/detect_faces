import cv2


def detect_faces(image_path):
    # Загружаем каскадный классификатор для обнаружения лиц
    face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

    # Загружаем изображение
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)  # Преобразуем изображение в оттенки серого

    # Обнаруживаем лица
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)

    # Проверяем, нашлись ли лица
    if len(faces) == 0:
        print("Лица не обнаружены.")
    else:
        print(f"Обнаружено {len(faces)} лиц.")
        for (x, y, w, h) in faces:
            print(f"Лицо обнаружено на координатах: x={x}, y={y}, ширина={w}, высота={h}")

    return faces


# Пример использования
image_path = 'images.jpg'  # Замените на путь
detect_faces(image_path)
