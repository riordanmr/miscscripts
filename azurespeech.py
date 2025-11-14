# Read a text file and produce an MP3 audio file containing the spoken text.
# Based on this Azure Speech Service Text to Speech sample:
# https://ai.azure.com/resource/playground/speech/texttospeech?wsid=/subscriptions/02e0ac63-28ae-47cc-8aaa-1b447b7a80d3/resourceGroups/mrrp-aifoundry-rg/providers/Microsoft.CognitiveServices/accounts/mrrp-aifoundry/projects/mrrp-proj1&tid=63ce651b-d1c9-4ea5-8980-33a04e2157f0#voicegallery
# Mark Riordan  2025-11-10
'''
  For more samples please visit https://github.com/Azure-Samples/cognitive-services-speech-sdk
'''

import azure.cognitiveservices.speech as speechsdk
import sys
import argparse
import os

class Settings:
    def __init__(self, input_file, speech_key, voice_name):
        self.input_file = input_file
        self.speech_key = speech_key
        self.voice_name = voice_name

# Parse command line arguments. Return a Settings object, or None on error.
def parse_command_line():
    """
    Parse command line arguments.
    Returns: (Settings object or None, error message string)
    """
    parser = argparse.ArgumentParser(description='Azure Speech Service Text to Speech')
    parser.add_argument('-i', '--input', required=True, help='Input text file')
    parser.add_argument('-k', '--key', required=True, help='Azure Speech service key')
    parser.add_argument('-v', '--voice', default='en-US-SerenaMultilingualNeural', 
                        help='Voice name (default: en-US-SerenaMultilingualNeural)')
    
    try:
        args = parser.parse_args()
        settings = Settings(args.input, args.key, args.voice)
        return settings
    except SystemExit:
        # argparse already printed the error message and usage to stderr
        return None

# Parse command line
settings = parse_command_line()
if settings is None:
    # argparse already printed the usage information
    sys.exit(1)

# Creates an instance of a speech config with specified subscription key and service region.
service_region = "westus2"

speech_config = speechsdk.SpeechConfig(subscription=settings.speech_key, region=service_region)
# Note: the voice setting will not overwrite the voice element in input SSML.
speech_config.speech_synthesis_voice_name = settings.voice_name

# Set output format to MP3
speech_config.set_speech_synthesis_output_format(
    speechsdk.SpeechSynthesisOutputFormat.Audio16Khz32KBitRateMonoMp3
)

with open(settings.input_file, 'r') as f:
    text = f.read()

# Generate output filename: change extension to .mp3
output_file = os.path.splitext(settings.input_file)[0] + '.mp3'

# Configure audio output to file
audio_config = speechsdk.audio.AudioOutputConfig(filename=output_file)
speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

result = speech_synthesizer.speak_text_async(text).get()
# Check result
if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
    print("Speech synthesized to file: {}".format(output_file))
elif result.reason == speechsdk.ResultReason.Canceled:
    cancellation_details = result.cancellation_details
    print("Speech synthesis canceled: {}".format(cancellation_details.reason))
    if cancellation_details.reason == speechsdk.CancellationReason.Error:
        print("Error details: {}".format(cancellation_details.error_details))
    