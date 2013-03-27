
function noiseOP = sendNoisePohl(p)

fs=44100;

b = log10(40);
e = log10(800);
p.fs=44100;

f = logspace(b,e,p.period.numPeriods)/60;             % Sinusoid frequencies

sinTime = 10;
              
t = (0:p.fs*sinTime-1)/p.fs;          % 10 seconds worth of samples
             

xn = 0.5*sin(2*pi*f'*t);
nse = randn(size(t));
nse = 0.1*nse/max(nse);


[m,n]=size(xn);

nseMat=repmat(nse,m,1);

xn = xn+nseMat;
%xn = nseMat;
win = window(@hamming, p.fs*sinTime);

winMat = repmat(win,1,m);

xn = xn'.*winMat;


p.period.norm=false;

p.period.params = p;



xn=xn(:);
filename='Pohl_method/temp.wav';
wavwrite(xn*0.8, fs,filename);
[noiseOP, ~]=pohl_main(filename,false,false);


%{
%xn=xn(:)*0.85;
nOPs=zeros(p.onset.numFreqsReduced,p.period.numPeriods);
nOPs2=zeros(p.onset.numFreqsReduced,p.period.numPeriods);


offset=1;
for i=1:25,
    filename='Latin-Rhythms/Pohl/temp.wav';
    wavwrite(xn(:,i)*0.8, fs,filename);
    [noiseOP, oc]=pohl_method(filename,false,false);
    nOPs(:,i)= sum(noiseOP,2).^2;
    nOPs2(:,i)= mean(mean(noiseOP)).^2;
end

noiseOP=nOPs2;
%}

%{
p.onset.fs=fs;

smoothed = smooth(xn,p.onset);

[noiseOP, ~] = getOPsAndOCs(smoothed,p.period, false);
%}


end

%% function finds onsets for 85 bands
function MBOnsetsReduced=smooth(x, p) 
%get params

%get log spectrogram
MBSpec = MB_spec((x ),p);

%log 1
if p.logType==1, 
    u=100000;
    MBSpec = log(u*MBSpec + 1)/log(u+1);
%log 2
elseif p.logType ==2,
    MBSpec = log(MBSpec + eps);  
else
    MBSpec = MBSpec;
end
%MBOnsetsReduced = MBOnsets;% reduceBins(MBOnsets); 
%[~,~, MBOnsets] = audio_to_noveltyCurve(x, p.fs, p);
%p.numFreqs = size(MBOnsets,1);
MBOnsetsReduced = reduceBins(MBSpec, p.numFreqs, p.numFreqsReduced); 

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

ibin = linspace(1,origBins,numBins);

M = zeros(numBins,origBins);

for i = 1:numBins
  tt = pi*([1:(origBins)]-ibin(i));
  M(i,:) = (sin(tt)+eps)./(tt+eps);
end


MBSpecReduced = (MBSpec' * M')';

end


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
begHz = 110;
len = p.winLen/2+1;
centFilters = logfmap(len,begHz,[], p.fs, p.numFreqs, true);


%mbFilters = calcFilterbank(numBins, fs, N);


%plot(melFilters);

MBSpec = (magSpectrum' * centFilters')';
end

