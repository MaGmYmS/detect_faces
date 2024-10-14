# Используем минимальный Python 3.12 образ для сборки OpenCV из исходников
FROM python:3.9-slim AS builder

# Обновляем пакеты и устанавливаем необходимые зависимости для сборки OpenCV
RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config \
    libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libjpeg-dev libpng-dev

# Переходим в рабочую директорию для сборки OpenCV
WORKDIR /opencv_build

# Клонируем репозиторий с исходниками OpenCV
RUN git clone https://github.com/opencv/opencv.git

# Клонируем репозиторий с дополнительными модулями OpenCV contrib
RUN git clone https://github.com/opencv/opencv_contrib.git

# Переходим в директорию для сборки OpenCV и создаем папку build
WORKDIR /opencv_build/opencv/build

# Запускаем сборку OpenCV с использованием CMake, добавляем дополнительные модули и отключаем примеры
RUN cmake -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF ..

# Компилируем OpenCV с использованием всех доступных процессорных ядер
RUN make -j$(nproc)

# Устанавливаем собранную версию OpenCV в систему
RUN make install

# Переходим на минимальный Python 3.12 образ для финальной сборки
FROM python:3.9-slim

# Устанавливаем минимальные системные зависимости для работы OpenCV (Для рендеринга изображений, Для поддержки GUI в OpenCV, Для работы с изображениями в формате JPEG и PNG)
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \           
    libgtk2.0-dev \             
    libjpeg-dev libpng-dev      

# Копируем установленные библиотеки OpenCV из предыдущего этапа сборки
COPY --from=builder /usr/local/ /usr/local/

# Копируем файл с Python-зависимостями в контейнер
COPY requirements.txt .

# Устанавливаем Python-зависимости из файла requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Копируем все исходные файлы приложения в контейнер
COPY . .

# Устанавливаем рабочую директорию в /app
WORKDIR /app

# Задаем команду по умолчанию для запуска приложения
CMD ["python", "main.py"]
