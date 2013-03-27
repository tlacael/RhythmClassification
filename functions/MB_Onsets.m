%% function finds onsets for 85 bands
function [MBOnsetsReduced, MBSpec] = MB_Onsets(x, p, yesPlot, onsetType) 

if nargin < 4
    onsetType = 1;
end

%calcualte samples coresponding to mean window time
meanWin = floor(p.meanWinTime*p.fs/p.hopsize);

%get log spectrogram
MBSpec = MB_spec(x,p);

%get onsets
if onsetType==1,
    MBOnsets = find_Onsets(MBSpec, meanWin);
elseif onsetType ==2, 
    MBOnsets = noveltyCurve_grosch(MBSpec, meanWin);
end
 


%log 1
if p.logType==1, 
    u=2;
    MBOnsets = log(u*MBOnsets + 1)/log(u+1);
%log 2
elseif p.logType ==2,
    MBOnsets = log(MBOnsets + eps);  
else
    MBOnsets = MBOnsets;
end


%reduce number of frequency bins
MBOnsetsReduced = reduceBins(MBOnsets,p.numFreqs, p.numFreqsReduced); 



end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to calculate 85 band spectrum                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MBSpec = MB_spec(x,p)% fs, winLen, hop, numBins)
% Function does mel ceptral analysis
%

%pad signal
%pad = zeros(1,winLen/2);
overlap = p.winLen - p.hopsize;



xPad = x;%[pad x' pad];
xTime = buffer(xPad, p.winLen, overlap, 'nodelay');

%create window matrix with same dim as xTime
win = window(@hamming, p.winLen);

[~,numSegs] = size(xTime);
WinMat = repmat(win, 1,numSegs);

%window signal
xTime = xTime.*WinMat;

%Take fft of signal
spectrum = fft(xTime, p.winLen)/p.winLen;

%numBins = 85;

%take absolute value

magSpectrum = abs(spectrum(1:end/2+1,:));
 

%filterBank 
len = p.winLen/2+1;
centOn=true;
centFilters = logfmap(len,p.bottomFreq,[], p.fs, p.numFreqs, centOn);
  
%applot filter
MBSpec = (magSpectrum' * centFilters')';
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MBOnsets=find_Onsets(MBSpec, MeanWin)


MBOnsets=MBSpec;
for i=1:size(MBSpec,1),
    MBOnsets(i,:)=subtractMean(MBSpec(i,:),MeanWin);
end

%half-wave rectify
MBOnsets = halfRec(MBOnsets);

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MBSpecReduced = reduceBins(MBSpec, origBins, numBins)
% [M,N] = linfmap(I,L,H)

% 2004-05-21 dpwe@ee.columbia.edu

% Convert base-1 indexing to base-0

%%%
%modified by Tlacael Esparza
%%%

%MBSpecReduced =filter(ones(1,5)/5,1,MBSpecReduced(end:-1:1,:));
%{
[~,length]=size(MBSpec);
padZeros = zeros(1,length);

temp1 = MBSpec(2:end,:);
temp1 = [padZeros;temp1];

temp2 = MBSpec(1:end-1,:);
temp2 = [temp2;padZeros];

MBSpec = (MBSpec + temp1+temp2);
%}
ibin = linspace(1,origBins,numBins);

M = zeros(numBins,origBins);

for i = 1:numBins
  tt = pi*([1:(origBins)]-ibin(i));
  M(i,:) = (sin(tt)+eps)./(tt+eps);
end


MBSpecReduced = (MBSpec' * M')';

end






%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = subtractMean(sig, winLen)

runMean = filter(ones(1,winLen)/winLen,1,sig);
output = sig - runMean;

end


%%
function MBSpecReduced = reduceBinsNaive(MBSpec, origBins, numBins)

p=numBins;
q=origBins;

MBSpecReduced=resample(MBSpec,p,q);

end

