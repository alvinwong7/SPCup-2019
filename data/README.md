# Data
## Creating Test Data
1. Download data.zip from http://tiny.cc/3hm66y and extract it into this folder
2. Run motorInit.m
> It creates the folder `individual_motors_cut` which contains motor recordings
3. Run `createData.m` with your desired settings
> `createData.m` will create a new folder `new_data/`, which can have flight_real, broadband_simulated, broadband_real, and/or speech folders after data creation

## Types of Data
### Development Data
* dev_static: contains three 2 seconds clean recordings of a static loudspeaker emitting white noise (broadband source)
* dev_flight: contains three 4 seconds clean recordings of a static loudspeaker emitting white noise (broadband source) made while the UAV was moved around in a room with its __motors switched-off__
* individual_motor_recordings: contains 21 8-channel .wav files at 44.1kHz corresponding to audio recordings of each of the 4 individual propellers of the UAV at different speeds (angular velocity)

### Simulated Data
> Simulated from `createData.m`
* flight_real: dev_flight data with added motor noise
* broadband_simulated: simulated static broadband source with added motor noise
* broadband_real: dev_static data with added motor noise
* speech: simulated static speech source with added motor noise

### Task Data
* static_task: 300 8-channel audio recordings at 44.1kHz and of roughly 2 seconds each are provided in the form of wav files. Each were obtained by summing a clean recording of a static loudspeaker emitting speech from an unknown (azimuth, elevation) direction in the array's frame, and a recording of UAV noise of the same length in various flight conditions and using various signal-to-noise ratios
* flight_task: 36 8-channel audio recordings at 44.1kHz lasting precisely 4 seconds each are provided in the form of wav files. The sources are either a loudspeaker emitting white noise (broadband) or speech. All recordings were made during flight with the 8-microphone array attached to a Mikrocoptor UAV. The flights were performed in a large room with moderate reverberation level
 
