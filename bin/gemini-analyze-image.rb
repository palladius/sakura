#!/usr/bin/env ruby

# uses https://github.com/gbaptista/gemini-ai
# Note: Vision doesnt work with API!

debug = $DEBUG

#ric_require 'gemini-ai'
require 'gemini-ai' rescue `gem install gemini-ai`

DefaultPrompt = 'Please describe this image.'
image_file = File.expand_path(ARGV[0]) rescue 'app/assets/images/RiccardoGoogleJakarta.jpeg' # ricc testing

if ARGV.size == 0
  # usage
  puts("Usage: $0 <FILE_NAME.JPG> [optional different prompt than just what is this]")
  exit 42
end

prompt = ARGV.size > 1  ?
  ARGV.drop(1).join(' ') : # more than 1 argment - here's your prompt
  DefaultPrompt # no args - default prompt

GEMINI_API_KEY = ENV.fetch 'GEMINI_API_KEY', ''
GCP_REGION = ENV.fetch 'GCP_REGION', 'us-central1'
PROJECT_ID = ENV.fetch 'PROJECT_ID', 'ror-goldie'

# verbose debug
if debug
  puts("♊"* 40)
  puts("♊ Using Gemini to describe this image:")
  puts("  🖼️ image file:         #{image_file}")
  puts("  🔐 GOOGLE_API_KEY.len: #{GEMINI_API_KEY.size}")
  puts("  ☁️ PROJECT_ID:          #{PROJECT_ID}")
  puts("  ☁️ GCP_REGION:          #{GCP_REGION}")
  puts("  ☁️ Prompt:              #{prompt}")
  puts("♊"* 40)
end


raise "ENV[GOOGLE_API_KEY] non datur!" if GEMINI_API_KEY.size < 20 # mine is 39
raise "Invalid file: #{image_file}!" unless File.exist? image_file

client = Gemini.new(
  credentials: {
    service: 'vertex-ai-api',
    region: GCP_REGION, # 'us-east4'
    project_id: PROJECT_ID
  },
  # doesnt work with Vision
  # credentials: {
  #   service: 'generative-language-api',
  #   api_key: GEMINI_API_KEY,
  #   version: 'v1beta',
  # },
  options: {
    model: 'gemini-pro-vision',
    server_sent_events: true,
  }
)

require 'base64'

result = client.stream_generate_content(
  { contents: [
    { role: 'user', parts: [
      { text: prompt },
      { inline_data: {
        mime_type: 'image/jpeg',
        data: Base64.strict_encode64(File.read(image_file))
      } }
    ] }
  ] }
)

def bfj2str(result)
  result.map{|blurb| blurb['candidates'][0]['content']['parts'][0]['text']}
end

#puts(result)
puts(bfj2str(result))
