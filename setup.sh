#!/bin/bash

# Make the script executable with the following command:
# chmod +x setup.sh
# Run the script with arguments, example:
# ./setup.sh --beta 0.1 --lambda_dpop 40.0 --lambda_kl 0.2 --lr 5e-6

# Display help information if requested
if [[ "$1" == "--help" ]]; then
  echo "Usage: ./setup.sh [options]"
  echo ""
  echo "This script sets up the environment and runs the DPO training with specified parameters."
  echo ""
  echo "Options:"
  echo "  DPO Loss Parameters:"
  echo "    --beta VALUE         Beta value for DPO loss (default: from config.py)"
  echo "    --lambda_dpop VALUE  Lambda DPOP value (default: from config.py)"
  echo "    --lambda_kl VALUE    Lambda KL value (default: from config.py)"
  echo ""
  echo "  Method Selection:"
  echo "    --method NUMBER      Method choice (1=dpo, 2=dpop, 3=dpokl, 4=dpopkl) (default: 2)"
  echo ""
  echo "  Training Parameters:"
  echo "    --lr VALUE           Learning rate (default: from config.py)"
  echo "    --batch_size VALUE   Batch size (default: from config.py)"
  echo "    --grad_accum VALUE   Gradient accumulation steps (default: from config.py)"
  echo "    --epochs VALUE       Number of epochs (default: from config.py)"
  echo "    --weight_decay VALUE Weight decay (default: from config.py)"
  echo "    --max_length VALUE   Maximum input length (default: from config.py)"
  echo "    --max_new_tokens VAL Maximum tokens to generate (default: from config.py)"
  echo ""
  echo "  Generation Parameters:"
  echo "    --temp VALUE         Temperature for generation (default: from config.py)"
  echo "    --top_p VALUE        Top-p sampling parameter (default: from config.py)"
  echo ""
  echo "  Data Parameters:"
  echo "    --data TYPE          Data type (content, structure, mixed, preference) (default: content)"
  echo ""
  echo "  Evaluation Parameters:"
  echo "    --eval_freq VALUE    Evaluation frequency (default: from config.py)"
  echo "    --eval_patience VAL  Early stopping patience (default: from config.py)"
  echo ""
  echo "Example:"
  echo "  ./setup.sh --beta 0.2 --lambda_dpop 30.0 --method 2 --data mixed"
  exit 0
fi

# Stop execution on any error
set -e

# Update package lists
echo "Updating package lists..."
apt-get update

# Install Python virtual environment package and nano
echo "Installing python3.10-venv and nano..."
apt-get install -y python3.10-venv nano

# Create a virtual environment if it doesn't exist
VENV_DIR="env"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
else
    echo "Virtual environment already exists."
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip and install Hugging Face CLI
echo "Installing Hugging Face CLI..."
pip install -U "huggingface_hub[cli]"

# Log into Hugging Face CLI
echo "Please log into Hugging Face CLI (Press Enter when ready)"
huggingface-cli login

# Check if `requirements.txt` exists and install dependencies
REQUIREMENTS_FILE="requirements.txt"
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "No requirements.txt found. Skipping dependency installation."
fi

# Pass all arguments directly to the Python script
echo "Running training with provided parameters..."
PYTHONPATH=$(pwd) python -m src.main "$@"

echo "Training complete."