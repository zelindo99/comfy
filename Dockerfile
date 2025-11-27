FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

WORKDIR /workspace

# System deps
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    ffmpeg \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install PyTorch (CUDA 12.1)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install RunPod serverless SDK
RUN pip install --no-cache-dir runpod

# Install ComfyUI Python deps
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Serverless worker files
COPY handler.py /handler.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV COMFY_HOME=/runpod-volume/comfyui

CMD ["/entrypoint.sh"]
