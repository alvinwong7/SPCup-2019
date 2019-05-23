# Data
## Creating Test Data
1. Download speech.rar from https://drive.google.com/open?id=1AnYhh--sVDIuCbP62wvKiuLobyE5XFa2, and extract it in a folder named *clean_speech_mono*. The folder hieararchy should look like dev_static --> speech --> Speaker1-10.
2. Make sure you have the individual_motors_recordings folder in the data/ folder.
3. Run motorInit.m, it should create a new folder called individual_motors_cut.
4. Run createData.m with desired settings.
5. createData.m will create a new folder *new_data*, which can have broadband_simulated, broadband, and speech folders after data creation.

## File Hierarchy
After completing step 3 of the previous section, the folder hierarchy should be as follows:
* data/
  * clean_speech_mono/
    * speech/
  * dev_flight/
    * audio/
    * `SPCUP19_dev_flight.mat`
  * dev_static/
    * audio/
    * `SPCUP19_dev_static.mat`
  * flight_task/
    * audio/
    * `flight_motor_speed.mat`
  * individual_motors_cut
  * individual_motors_recordings
  * static_task
    * audio/
    * `static_motor_speed.mat`

## Development Data
* dev_static: contains three 2 seconds clean recordings of a static loudspeaker emitting white noise (broadband source).
* dev_flight: contains three 4 seconds clean recordings of a static loudspeaker emitting white noise (broadband source) made while the UAV was moved around in a room with its __motors switched-off__.
* individual_motor_recordings: contains 21 8-channel .wav files at 44.1kHz corresponding to audio recordings of each of the 4 individual propellers of the UAV at different speeds (angular velocity).

## Test Data
* static_task: 300 8-channel audio recordings at 44.1kHz and of roughly 2 seconds each are provided in the form of wav files. Each were obtained by summing a clean recording of a static loudspeaker emitting speech from an unknown (azimuth, elevation) direction in the array's frame, and a recording of UAV noise of the same length in various flight conditions and using various signal-to-noise ratios.
* flight_task: 36 8-channel audio recordings at 44.1kHz lasting precisely 4 seconds each are provided in the form of wav files. The sources are either a loudspeaker emitting white noise (broadband) or speech. All recordings were made during flight with the 8-microphone array attached to a Mikrocoptor UAV. The flights were performed in a large room with moderate reverberation level.
 
