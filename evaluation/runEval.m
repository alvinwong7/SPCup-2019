%% runEval.m -- Script to run the evaluation with desired test function
% Running this from the evaluation directory should evaluate the DOA
% estimation function passed into evaluate as a function handle. The
% function format for the method variable is:
% Inputs:
% - data    - N by 8 matrix of a single file to run a DOA estimate on
% - Fs      - Sample rate of file
% - args    - Cell array containing all additional arguments required for
%             the method.
% Outputs:
% - DOA     - 1 by 2 vector containing the single estimate of azimuth and
%             elevation. DOA = [az, el];

clear variables;
close all;

% Set method equal to the handle of the function you wish to evaluate
methodName = 'baseline2';
% The different testTypes are:
%   - flight_real
%   - speech
%   - broadband_simulated
%   - broadband_real
testType = 'speech';
method = str2func(methodName);
submission = 0;

if contains(methodName,'baseline')
    args{1} = testType;
else
    args = 0;
end

addpath(genpath(fileparts(pwd)));
if ~testing
    submission;
else
    evaluate(method,args,testType);
end
