
%%
% find periodicities on onset curve
function periodicity = get_periodicity(onsets, p)

[fBins, ~]=size(onsets);

buf = buffer(onsets(1,:),p.opWin, p.opWin-p.opHop,'nodelay');

%perform BPM specific dft on first bin
temp = fourierTempogram(buf,p);
[periodicities,frames]=size(temp);

periodicity=zeros(fBins, frames*periodicities);

periodicity(1,:)=reshape(temp,1,frames*periodicities);

%perform BPM specific dft on rest
for i=(2:fBins),
    buf = buffer(onsets(i,:),p.opWin, p.opWin-p.opHop, 'nodelay');
    temp =...
        (fourierTempogram(buf,p));
    
    periodicity(i,:)=reshape(temp,1,frames*periodicities);
end

end

%%
function tempi=fourierTempogram(onsets, p)
%window signal
%onsetsWin = prepSignal(onsets, winLength, h, false, false);
winSig=windowSignal(onsets);

%winSig = log(winSig + 0.00000000001);

%N = size(onsets,2);
N = round(p.zeroPad * p.fs);

%create frequency matrix

fftNovelty = fft(winSig, N)/N;

%take absolute value
magSpectrum = abs(fftNovelty(1:round(end/2+1),:));
 
%filterBank 
%logFilters = calcLogFilterbank(bins,fs,N);
len = size(magSpectrum,1);

logFilters = logfmap(len, p.lowPeriod, p.hiPeriod, p.fs, p.numPeriods); 

temp = ones((size(magSpectrum)));

% matrix multiply
tempi = (magSpectrum' * logFilters')';


end



%%
function winSig=windowSignal(onsets)

[m,n] = size(onsets);
win = window(@hanning, m);
win = repmat(win,1,n);

%window signal
winSig = onsets.*win;
end
