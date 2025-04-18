#!/usr/bin/env python

'''
install: pipx install google-generativeai python-dotenv coloring

On mac:
* pipx install google-generativeai --include-deps

#pyyaml
#IPython
'''

import argparse
import sys
import google.generativeai as genai
import os
from dotenv import load_dotenv
from coloring import *  # Assuming you have a coloring.py file.  If not, remove this.

# # Define ANSI color codes (if coloring.py is not available)
# RED = "\033[31m"
# GREEN = "\033[32m"
# YELLOW = "\033[33m"
# BLUE = "\033[34m"
# RESET = "\033[0m"

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-sobenme-pro")
OUTPUT_DIR = os.getenv("OUTPUT_DIR", "out/")
#GOOGLE_LOGO: str =  red("GOO") + blue("GLE")
GOOGLE_LOGO: str = blue('G') + red("o") + yellow("o") + blue("g") + green("l") + red("e")
GOOGLE_LOGO_EMOJI = "🔷🔴🟨💚 "

def colorize_text(text, color_code):
    """Adds ANSI escape codes for color to the text."""
    return f"\033[{color_code}m{text}\033[0m"

def get_text_from_file(filename):
    """Reads text from a file."""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {filename}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error reading file {filename}: {e}", file=sys.stderr)
        return None


def generate_content_with_gemini(text, api_key):
    """Generates content using the Gemini API."""
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel(GEMINI_MODEL)  # Use 'gemini-pro'
        response = model.generate_content(text)
        return response.text
    except Exception as e:
        print(f"Error during generation: {e}", file=sys.stderr)
        if "API key not valid" in str(e):
            print("Make sure your API key is correct and set in the .env file.", file=sys.stderr)
        elif "blocked" in str(e).lower() or "safety" in str(e).lower():
            print("The request was blocked due to safety settings.  Adjust your prompt if necessary.", file=sys.stderr)
        elif "exceeded" in str(e).lower():
            print("You have exceeded your quota. Please check your Gemini API usage.", file=sys.stderr)
        return None



def main():
    """Parses arguments, reads input, interacts with Gemini, and prints/saves output."""

    parser = argparse.ArgumentParser(
        description="Process text with Gemini and save/display output.",
        formatter_class=argparse.RawTextHelpFormatter,
        epilog="""\
Examples:
  1. Process text from a file and save to the default output file:
     python main.py -i input.txt

  2. Process text from STDIN and save to a specific file:
     cat input.txt | python main.py -o my_output.md

  3. Process text and display colored output to the terminal (and save to default file):
     echo "Hello, Gemini!" | python main.py

  4. Process text from STDIN with user input (Ctrl+D to end):
      python main.py

  5. Save output to a specific file:
     python main.py -i input.txt -o results.txt

Environment Variables:
  - GEMINI_API_KEY: Your Gemini API key.  Must be set in a .env file.

Output:
  - Output is ALWAYS saved to a file (default: .tmp-gemini-output.md).
  - Output is colorized in orange if sent to a terminal.
  - Errors are printed to stderr.
"""
    )
    parser.add_argument('--input', '-i', type=str, help="Path to the input file.")
    parser.add_argument('--output', '-o', type=str, help="Path to the output file (optional).")
    args = parser.parse_args()

    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY not found in .env file.", file=sys.stderr)
        sys.exit(1)

    # Determine output file path
    output_file = args.output if args.output else ".tmp-gemini-output.md"

    if args.input:
        input_text = get_text_from_file(args.input)
        if input_text is None:
            sys.exit(1)
    else:
        try:
            input_text = sys.stdin.read()
        except Exception as e:
            print(f"Error during reading from stdin: {e}", file=sys.stderr)
            sys.exit(1)

    if not input_text.strip():
        print("Error: No input text provided.", file=sys.stderr)
        sys.exit(1)

    generated_text = generate_content_with_gemini(input_text, api_key)

    if generated_text:
        # Save to file (always)
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(generated_text)
            print(f"Output saved to: {output_file}", file=sys.stderr) # Indicate file saving
        except Exception as e:
            print(f"Error writing to output file {output_file}: {e}", file=sys.stderr)
            sys.exit(1)

        # Display to terminal (with color if applicable)
        if sys.stdout.isatty():
            colored_text = colorize_text(generated_text, 33)
            print(colored_text)
        else:
            print(generated_text)  # Already saved to file, so no need to print again if not a tty


if __name__ == "__main__":
    main()
