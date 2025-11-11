# Azure Speech Service Text to Speech Sample
# based on https://ai.azure.com/resource/playground/speech/texttospeech?wsid=/subscriptions/02e0ac63-28ae-47cc-8aaa-1b447b7a80d3/resourceGroups/mrrp-aifoundry-rg/providers/Microsoft.CognitiveServices/accounts/mrrp-aifoundry/projects/mrrp-proj1&tid=63ce651b-d1c9-4ea5-8980-33a04e2157f0#voicegallery
# Mark Riordan  2025-11-10
'''
  For more samples please visit https://github.com/Azure-Samples/cognitive-services-speech-sdk
'''

import azure.cognitiveservices.speech as speechsdk
import sys

if len(sys.argv) < 2:
    print("Error: filename required", file=sys.stderr)
    sys.exit(1)

filename = sys.argv[1]

# Creates an instance of a speech config with specified subscription key and service region.
speech_key = ""  # Need to populate this with Azure Speech service key
service_region = "westus2"

speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
# Note: the voice setting will not overwrite the voice element in input SSML.
speech_config.speech_synthesis_voice_name = "en-US-SerenaMultilingualNeural"

with open(filename, 'r') as f:
    text = f.read()

# use the default speaker as audio output.
speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config)

result = speech_synthesizer.speak_text_async(text).get()
# Check result
if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
    print("Speech synthesized for text [{}]".format(text))
elif result.reason == speechsdk.ResultReason.Canceled:
    cancellation_details = result.cancellation_details
    print("Speech synthesis canceled: {}".format(cancellation_details.reason))
    if cancellation_details.reason == speechsdk.CancellationReason.Error:
        print("Error details: {}".format(cancellation_details.error_details))
    