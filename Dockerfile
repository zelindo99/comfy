FROM runpod/pytorch:3.10-2.1.2-cuda12.1-runtime

# Use a neutral, safe working directory
WORKDIR /workspace

# System deps needed by ComfyUI
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install RunPod serverless SDK
RUN pip install --no-cache-dir runpod

# Copy ComfyUI requirements into the image
# IMPORTANT: this must be the same file from your /runpod-volume/comfyui installation
COPY requirements-comfyui.txt /tmp/requirements.txt

# Install ComfyUI dependencies at build time (fast serverless startup)
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy handler
COPY handler.py /handler.py

# ComfyUI will be loaded from /runpod-volume/comfyui at runtime
ENV COMFY_HOME=/runpod-volume/comfyui

# Run serverless handler immediately
CMD ["runpod-serverless"]
