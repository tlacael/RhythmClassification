%Function calculates Onset Patterns and Onset Coefficients as describred
% by Pohl in 'On Rhythm and General Rhythmic Similarity'
%usage:
% function [OPs, OCs, params, OP_DFT] = pohl_method(filename, norm,plotAll)
% inputs:   filename - Location of wav audio file
%           normOn - True or False switches on/off filter correction
%           plotsAll - True turns plotting of log-dft, onsets, OPs and OCs 
% outputs:
%           OPs - freq-bins X periodicity bins size matrix showing track
%                   summary of OPs.
%           OCs - freq-coeff X periodicity coeff size matrix showing OCs
%                   summary for track.\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [OPs, OCs, params, OP_DFT] = pohl_main(filename,norm, plotAll)


%% check args, add paths and load audio
if nargin<2,
    plotAll = true;
end


if plotAll,
    yesPlot=true;
    yesPlot2=true;

else
    yesPlot=false;
    yesPlot2=false;
end

addpath('Pohl_method/functions/');
addpath('Pohl_method/utilities/');
addpath('Pohl_method/plot/');


try
    [x,fs]=loadAudio(filename);
catch 
    disp('not a wav file')
    return
end

 
%close all;

%normalize
x = x/max(x);

 
%% set paramaters

% onset analysis params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
winLen=1024;
hopTime = 0.0155; %15.5 secs hopsize;
meanWinTime = 0.25;%0.250;%25;%window for mean subtraction in onset detection, secs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hopsize=ceil(hopTime*fs);


% OP analysis params 
%at onset FS of 44.0664, 128 aWin is 2.97 secs
onsetFS = fs/hopsize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opWinTime = 2.63;%2.63;%2.63;%2.63; %seconds
zeroPad = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opWin=round(opWinTime*onsetFS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opHopTime=0.25; %seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opHop=round(opHopTime*onsetFS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DCT params
fCoeff = 1;
pCoeff = 20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numFreqs = 85;
numFreqsReduced=38;
numPeriods = 25;
bottomFreq = 100;

logType=2;

DFT_FCoeff=38;
DFT_PCoeff=25;
lowPeriod=40;
hiPeriod=800;
smoothOn=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% store in struct
params.onset.fs = fs;
params.onset.winLen = winLen;
params.onset.hopTime = hopTime;
params.onset.hopsize = hopsize;
params.onset.meanWinTime = meanWinTime;
params.onset.numFreqs = numFreqs;
params.onset.numFreqsReduced = numFreqsReduced;
params.onset.logType = logType;
params.onset.bottomFreq = bottomFreq;


params.period.fs = onsetFS;
params.period.opWinTime = opWinTime;
params.period.zeroPad = zeroPad;
params.period.opWin = opWin;
params.period.opHopTime = opHopTime;
params.period.opHop = opHop;
params.period.fCoeff = fCoeff;
params.period.pCoeff = pCoeff;
params.period.numPeriods = numPeriods;
params.period.norm = norm;
params.period.params= params;
params.period.bottomFreq = bottomFreq;
params.period.numFreqs = numFreqs;

params.period.DFT_FCoeff=DFT_FCoeff;
params.period.DFT_PCoeff=DFT_PCoeff;
params.period.lowPeriod=lowPeriod;
params.period.hiPeriod=hiPeriod;
params.period.smoothOn=smoothOn;

%% calculate onsets
%display('Calculating onsets...');
[onsets, MBSpec] = MB_Onsets(x, params.onset, yesPlot);


%% calculate periodicity
%display('Calculating periodicities...');
%ger periodicities
periodicity = get_periodicity(onsets, params.period);
%% calculate periodicity

%% calculate OCs
[OPs, OCs] = getOPsAndOCs(periodicity,params.period, yesPlot2);
%% calculate DFTs 
[OPsSum, OP_DFT] = getOP_DFTs(periodicity,params.period, yesPlot2);

%%
%PLOT

if yesPlot,
   makePlotsOnsets(MBSpec,onsets, params.onset); 
end



%plot
if yesPlot,
   makePlotsOPsOCs(OCs, OPs, params.period);
end



%plot
if yesPlot,
   
   makePlotsDFT(OPsSum,OP_DFT, params.period);
end



end

