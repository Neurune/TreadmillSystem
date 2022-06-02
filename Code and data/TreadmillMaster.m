%% INFORMATION
% 
% The code analyzes N recording files (i.e., habituation days) of treadmill data from one mouse and computes a range of quantifications (e.g.,total locomotion distance, maximal locomotion velocity etc.) 
% The raw data files are ABF files acquired with Clampex software and a Digidata 1550B digitizer.
% 
%% Start on a fresh and add functions to path

clear all; close all ; clc; close all; 

addpath('/Users/macpro/Dropbox/RasmussenLab/Papers/Method/Code and data/functions'); %This should be the folder where the functions are located
%addpath('/Users/neurune/Dropbox/RasmussenLab/Papers/Method/Code and data/functions'); %This should be the folder where the functions are located

%% Get the ABF files (if using a different file format for treadmill data acquisition this section should be modified accordingly)

datadir = uigetdir(); %Choose folder containing abf files 
[data_all] = getABFfiles(datadir, 3); %Arguments: data directory, channel number storing treadmill signal (i.e., IN 3)

%% Convert voltage signal to locomotion velocity

[velocity] = getLocVel(data_all, 1); %Arguments: data structure and plot or not

%% Compute metrics and quantifications from velocity trace

[locomotionQuant] = getLocQuant(velocity,1.5,2,1,1); %Arguments: velocity structure, locomotion threshold (cm/s), min interval between locomotion bouts (s), minimum duration of locomotion bout (s) and plot or not 

%% Save quantifications to data dir folder

FileName = sprintf('LocAnalysis_%s.mat', datestr(now,'mm-dd-yyyy'));
save(FileName, 'locomotionQuant', 'velocity');
