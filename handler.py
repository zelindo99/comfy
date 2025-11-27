import os
import json
import subprocess
import tempfile
import runpod

COMFY_PATH = "/runpod-volume/comfyui"
OUTPUT_DIR = "/runpod-volume/output"


def run_workflow(workflow_data):
    """Run a workflow JSON through ComfyUI in headless mode."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Write workflow to a temporary file
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
        json.dump(workflow_data, f, indent=2)
        workflow_path = f.name

    # Run ComfyUI headlessly
    cmd = [
        "python", f"{COMFY_PATH}/main.py",
        "--disable-auto-launch",
        "--quick-test",
        "--workflow", workflow_path,
        "--output-directory", OUTPUT_DIR
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    return {
        "stdout": result.stdout,
        "stderr": result.stderr,
        "returncode": result.returncode,
        "output_dir": OUTPUT_DIR
    }


def handler(event):
    """RunPod handler entrypoint."""
    workflow = event.get("workflow")
    if not workflow:
        return {"error": "Missing 'workflow' in request"}

    return run_workflow(workflow)


runpod.serverless.start({"handler": handler})
