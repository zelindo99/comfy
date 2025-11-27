FROM runpod/cuda:12.1.0-runtime

# Use a neutral, safe working directory
WORKDIR /workspace

# System dependencies required by ComfyUI
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install RunPod serverless SDK
RUN pip install --no-cache-dir runpod

# Copy ComfyUI requirements into the image
# IMPORTANT: this must match your /runpod-volume/comfyui installation
COPY requirements.txt /tmp/requirements.txt

# Install ComfyUI dependencies at build time
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy serverless files
COPY handler.py /handler.py
COPY entrypoint.sh /entrypoint.sh

# Ensure entrypoint is executable
RUN chmod +x /entrypoint.sh

# ComfyUI will be loaded from the network volume at runtime
ENV COMFY_HOME=/runpod-volume/comfyui

# Start RunPod serverless runtime
CMD ["/entrypoint.sh"]
