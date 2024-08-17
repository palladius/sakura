#!/usr/bin/env python3
'''Generated with AI. use with caution.

Usage: virtualenv

## INSTALL

Mac:

* brew install virtualenv, or:
* python3 -m venv .venv
* . .venv/
* pip3 install requests
* pip install --upgrade google-auth
* pip install google-api-python-client
* pip install -q -U google-generativeai  # newest API

'''

import os
import google.generativeai as genai
import requests
import sys
#from google.oauth2 import service_account
import googleapiclient.discovery
import google.auth

DefaultModel = 'gemini-1.5-pro'
#DefaultProject = 'ric-cccwiki'
GEMINI_API_KEY = os.getenv('PALM_API_KEY') # os.environ["GEMINI_API_KEY"]
#ServiceAccountPath = os.getenv('GEMINI_SERVICE_ACCOUNT', None) # 'ENV SA non datur')

# def gemini_api_endpoint(region='us-central1', project_id=DefaultProject, model_id=DefaultModel):
#     '''Ref: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/inference'''
#     # https://${LOCATION}-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/${LOCATION}/publishers/google/models/${MODEL_ID}:generateContent \
#     return f"https://{region}-aiplatform.googleapis.com/v1/projects/{project_id}/locations/{region}/publishers/google/models/{model_id}:generateContent"



# def analyze_code_with_gemini_old(code_content):
#     """
#     Sends the provided code content to the Gemini API for analysis.

#     Args:
#         code_content (str): The code to be analyzed.

#     Returns:
#         str: The response from the Gemini API containing the analysis.
#     """

#     # Replace with your actual Gemini API endpoint and key
#     api_endpoint = "YOUR_GEMINI_API_ENDPOINT"
#     api_key = "YOUR_GEMINI_API_KEY"

#     headers = {
#         "Authorization": f"Bearer {api_key}",
#         "Content-Type": "application/json"
#     }

#     data = {
#         "prompt": f"Analyze the following code and explain what it does:\n\n`\n{code_content}\n`",
#         # Add other relevant parameters as needed (e.g., model, max_tokens)
#     }

#     response = requests.post(api_endpoint, headers=headers, json=data)
#     response.raise_for_status()  # Raise an exception for error responses

#     return response.json()["text"]  # Assuming the response format


def analyze_code_with_gemini(code_content):
    '''Copied from file.'''

    model = genai.GenerativeModel("gemini-1.5-flash")
    #prompt = f"""Analyze the following code and explain what it does in maximum 3 sentencesplus add a sentence at the end explaining if this file seems OBSOLETE (meaning - better to throw it all away) and why):\n\n`\n{code_content}\n`"""
    #prompt = f"Analyze the following code and explain what it does in 1 sentence. If you find any bug, please highlight it in one bullet point per bug):\n\n`\n{code_content}\n`"
    prompt = f"Analyze the following code and explain what it does in maximum 2 sentence:\n\n`\n{code_content}\n`"
    # TODO catch errors and visualize the rest of JSON if error arrives.
    # one error was:
    # ValueError: Invalid operation: The `response.text` quick accessor requires the response to contain a valid `Part`, but none were returned. Please check the `candidate.safety_ratings` to determine if the response was blocked.
    response = model.generate_content(prompt)
    #print(response.text)
    return response.text

def yellow(s):
    return f"\033[33m{s}\033[0m"

def analyze_local_code_directory(directory_path):
    """
    Reads all code files in the specified directory and analyzes them using the Gemini API.

    Args:
        directory_path (str): The path to the directory containing the code files.
    """

    print(f"Analyzing code in '{directory_path}'..")
    for root, _, files in os.walk(directory_path):
        for file in files:
            if file.endswith(('.py', '.js', '.java', '.c', '.cpp', '.cs', '.rb', '.sh', 'Dockerfile', '.yaml')):  # Add more extensions as needed
                print(f"🧐 Analyzing file '{file}' 🧐")
                file_path = os.path.join(root, file)
                with open(file_path, 'r') as f:
                    code_content = f.read()

                analysis = analyze_code_with_gemini(code_content)
                #print(f"🐣 Analysis for {file_path}:\n{analysis}\n")
                print(f"🐣 Analysis for {file_path}:\n{yellow(analysis)}\n")


def main():
    genai.configure(api_key=GEMINI_API_KEY)
    print(f"[DEB] GEMINI_API_KEY={GEMINI_API_KEY}")

    if len(sys.argv) < 2:
        print("Error: Please provide the path to the code directory as an argument.")
        print("Usage: python gemini_analyze_code.py ~/path/to/your/code")
        print("  eg, gemini_analyze_code.py ~/git/sakura/lib/recipes/")
        sys.exit(1)

    code_directory = os.path.expanduser(sys.argv[1])
    if not os.path.isdir(code_directory):
        print(f"Error: The provided path '{code_directory}' is not a valid directory.")
        sys.exit(1)

    analyze_local_code_directory(code_directory)

if __name__ == "__main__":
    main()
