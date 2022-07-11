%% INFORMATION
% 
% The code analyzes N recording files (i.e., habituation days) of treadmill data from one mouse and computes a range of quantifications (e.g., distance covered, maximal treadmill speed etc.) 
% The raw data files are ABF files acquired with Clampex software and a Digidata 1550B digitizer.
% 
%% Start on a fresh and add functions to path

clear all; close all ; clc; close all; 

%Mac format:
addpath('/Users/neurune/Dropbox/RasmussenLab/Papers/Method/Code and data/functions'); %This should be the folder where the functions are located

%Windows format:
%addpath('C:\Users\gpv514.UNICPH\Dropbox\RasmussenLab\Papers\Method\Code and data\functions\');

%% Get the ABF files (if using a different file format for treadmill data acquisition this section should be modified accordingly)

datadir = uigetdir(); %Choose folder containing abf files 
[data_all] = getABFfiles(datadir,3); %Arguments: data directory, channel number storing treadmill signal (e.g., IN 3)

%% Convert voltage signal to treadmill speed

[speed] = getLocSpeed(data_all,20,500,1); %Arguments: data structure, final sampling rate, window width for smoothing (ms) and plot or not

%% Compute metrics and quantifications from speed trace

[locomotionQuant] = getLocQuant(speed,1.5,2,1,1); %Arguments: speed structure, speed threshold (cm/s), min interval between locomotion bouts (s), minimum duration of locomotion bout (s) and plot or not 

%% Save quantifications to data dir folder

FileName = sprintf('LocAnalysis_%s.mat', datestr(now,'mm-dd-yyyy'));
save(FileName, 'locomotionQuant', 'speed');
