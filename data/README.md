# Data
## Development Data
 * dev_static: contains three 2 seconds clean recordings of a static loudspeaker emitting white noise (broadband source).
 * dev_flight: contains three 4 seconds clean recordings of a static loudspeaker emitting white noise (broadband source) made while the UAV was moved around in a room with its __motors switched-off__.
 * individual_motor_recordings: contains 21 8-channel .wav files at 44.1kHz corresponding to audio recordings of each of the 4 individual propellers of the UAV at different speeds (angular velocity).

## Test Data
 * static_task: 300 8-channel audio recordings at 44.1kHz and of roughly 2 seconds each are provided in the form of wav files. Each were obtained by summing a clean recording of a static loudspeaker emitting speech from an unknown (azimuth, elevation) direction in the array's frame, and a recording of UAV noise of the same length in various flight conditions and using various signal-to-noise ratios.
 * flight_task: 36 8-channel audio recordings at 44.1kHz lasting precisely 4 seconds each are provided in the form of wav files. The sources are either a loudspeaker emitting white noise (broadband) or speech. All recordings were made during flight with the 8-microphone array attached to a Mikrocoptor UAV. The flights were performed in a large room with moderate reverberation level.
 
 ## Creating Test Data
  * Run motorInit.m first.
  * Run createData.m with desired settings.
