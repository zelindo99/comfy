FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

WORKDIR /workspace

# System deps
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    git \
    ffmpeg \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment (using python3.10)
RUN python3 -m venv /opt/venv

# Activate venv for all subsequent commands
ENV PATH="/opt/venv/bin:${PATH}"

# Upgrade pip inside venv
RUN pip install --upgrade pip wheel setuptools

# Install PyTorch (CUDA 12.1)
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install RunPod serverless SDK
RUN pip install runpod

# Install ComfyUI deps
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Worker files
COPY handler.py /handler.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV COMFY_HOME=/runpod-volume/comfyui

CMD ["/entrypoint.sh"]
