# Relative Time of Arrival
This folder contains code that implements the model fitting relative time of arrival (RTOA) based method. Function file `getModel.m` is a function that generates a model and stores it in a local directory. `estDOAmodel.m` is a script that runs the method on a file, and compares the result with the correct one. Below is an explanation of the functions of these files.

## Model
`getModel.m` takes in some inputs and generates the model. The model is essentially a giant lookup table, stored in MATLAB as a 4D-double. This function can by run with it's default settings with 
```
getModel([],[],[]);
```
Doing so will generate a file in the current directory called `model.mat`. It contains 4 variables that will be loaded into your workspace either by double clicking it our using
```
load('model.mat');
```
The 4 variables are as follows:

 * theta - an array of azimuth values.
 * phi   - an array of elevation values.
 * D     - an array of distances.
 * model - a 4D-double.

model(:,t,p,d) contains a 7x1 vector of the expected relative time of arrivals (time difference of arrival at microphone i+1, compared to microphone 1), for a source at position theta(t), phi(p), D(d).

## Method
The method simply estimates the RTOA for the file provided by finding the lag that gives the maximum in the cross-correlation function. THIS PART COULD BE IMPROVED DRASTICALLY. It has near 0 noise tolerance (other than uncorrelated sensor noise). The estimated times are then compared to every possible vector in the model, by default using choosing minimum squared error. The model vector that returns the smallest error is selected as the estimate source position.

## Usage
When using the script for the first time, it will automatically run the model creation function with the default settings and save it. If you wish to modify it and add more or less points in the model you can do so by modifying the line
```
recalcModel = 0;
```
