
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLOT
function makePlotsOnsets(MBSpec,MBOnsets,p)


timeVec = (1:size(MBSpec,2))/(p.fs/(p.hopsize));
visTime = 10;

%calc freq vec
freq = zeros(p.numFreqs,1);
freq(1)=p.bottomFreq;%103.6105;

%find center  frequencys for 85 filters
for i=2:p.numFreqs
    freq(i)=freq(i-1)*pow2(103.6/1200);
end

numTicks=8;

%plot 85 band spectrogram
figure
subplot(211);
imagesc(timeVec, (1:p.numFreqs),log(abs(MBSpec)))
title('Multiband mag spectrogram');
set(gca, 'YDir', 'normal');
ylabel('Hz');
xlabel('seconds');
set(gca,'YTick',(1:p.numFreqs/numTicks:p.numFreqs))
set(gca,'YTickLabel',freq(1:round(p.numFreqs/numTicks):p.numFreqs))
xlim([1 visTime])

%plot 38 band onsets
freqsReduced = reduceBins(freq, p.numFreqs, p.numFreqsReduced);
subplot(212);
imagesc(timeVec, (1:p.numFreqsReduced),MBOnsets)
title('Multiband onsets reduced bins');
set(gca, 'YDir', 'normal');
ylabel('Hz');
xlabel('seconds');
set(gca,'YTick',(1:p.numFreqsReduced/numTicks:p.numFreqsReduced))
set(gca,'YTickLabel',freqsReduced(1:round(p.numFreqsReduced/numTicks):p.numFreqsReduced))
xlim([1 visTime])

end

function MBSpecReduced = reduceBins(MBSpec, origBins, numBins)

ibin = linspace(1,origBins,numBins);

M = zeros(numBins,origBins);

for i = 1:numBins
  tt = pi*([1:(origBins)]-ibin(i));
  M(i,:) = (sin(tt)+eps)./(tt+eps);
end


MBSpecReduced = (MBSpec' * M')';

end
