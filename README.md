# IEEE Signal Processing Cup 2019

This is a code repository for the 2019 IEEE Signal Processing Cup on the topic "Search and Rescue with Drone-Embedded Sound Source Localization" by our team Shout COOEE! who achieved 2nd place in the competition.

The main task of the competition is to accurately estimate the direction of a sound source (azimuth, elevation) using recordings from an 8-channel cube-shaped microphone array embedded in a flying UAV. This task is particularly challenging because of the high amount of acoustic noise produced by the UAV, resulting in negative signal-to-noise ratios (SNR). The noise consists of harmonic components related to the propellers speed as well as stationary structural noise and sometimes wind noise due to the UAV's movements and propellers rotations. Another difficulty comes from the fact that a UAV is constantly moving, sometimes with rapid changes of direcitons, resulting in complex relative source trajectories in the microphone array's reference frame. Please refer to the pdf `SPCup2019_syllabus` for more information about the competition.

For an in-depth understanding of our system please refer to our paper submission provided in the repository `SPCup_Report`.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* MATLAB
 
### Installation
1. Download or clone this repository to your local machine using `https://github.com/alvinwong7/sp-cup.git`
2. Follow the readme instructions in `data/`
3. Run `data/createData.m` with your desired settings to simulate data

## Running the Tests

* Run `evaluation/runEval.m` using one of the method functions in `evaluation/methods/*/` and one of the following test types: flight_real, speech (static), broadband_simulation (static) or broadband_real (static) (these are the only test files we were given or were able to simulate)
> `data/createData.m` needs to be run beforehand (preferably with multiple SNRs) to simulate the data that `evaluation/runEval.m` uses to measure performance

This should create a graph showing the accuracy of the estimated azimuth and elevation of the UAV across multiple signal-to-noise ratios (if multiple were simulated).

## Team
 * Antoni Dimitriadis
 * Alvin Wong
 * Ethan Oo
 * Jennifer Wu
 * Prasanth Parasu
 * Nors Cheng
 * Hayden Ooi
 * Kevin Yu
 
## Acknowledgements
Special thanks to Dr. Vidhyasaharan Sethu for supervising our team.
