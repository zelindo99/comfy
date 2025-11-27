FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

WORKDIR /workspace

# Install Python + pip + dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-distutils \
    python3-venv \
    git \
    ffmpeg \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Ensure pip and python commands exist
RUN ln -s /usr/bin/python3 /usr/bin/python || true
RUN ln -s /usr/bin/pip3 /usr/bin/pip || true

# Install PyTorch (CUDA 12.1)
RUN pip install --no-cache-dir torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121

# Install RunPod serverless SDK
RUN pip install --no-cache-dir runpod

# Install ComfyUI python deps
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Worker files
COPY handler.py /handler.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV COMFY_HOME=/runpod-volume/comfyui

CMD ["/entrypoint.sh"]
