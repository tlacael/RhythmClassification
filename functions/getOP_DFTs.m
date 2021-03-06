function [OPs, DFTs] = getOP_DFTs(periodicity,p, yesPlot)
%opWin, opHop, fs, norm, fCoeff, pCoeff,numPeriods, yesPlot)



%get DFTs and OPs
[DFTs, OPs, ~] =getDFTs(periodicity,p);


end


%%
function [DFTs, OPs, periodicity]=getDFTs(periodicity, p)

[freqs, segs]=size(periodicity);


if p.norm,
    filename = 'Pohl_method/normalize.mat';
    try
        
        data=load(filename);
        nOPs= data.nOPs;
        %disp('Loaded normalize.mat');
    catch err
        nOPs = sendNoisePohl(p.params);
        %nOPs = normalizeOP(nOPs);
        save(filename, 'nOPs');
        
    end
    [m,n] = size(nOPs);
    
    if m~=freqs || n ~= p.numPeriods,
        nOPs = sendNoisePohl(p.params);
        %nOPs = normalizeOP(nOPs);
        save(filename, 'nOPs');
     
    end
    
    %nOPs = normalizeOP(nOPs)+1;
    %nOPs = 1- nOPs;%.^2;
    
    %nOPs=repmat(mean(nOPs),38,1);
end


OPs=zeros(freqs,p.numPeriods);
OPsSum=zeros(1,p.numPeriods);

len=floor(segs/p.numPeriods);
if len ==0, 
    len=1;
end
%set params for DCT
OCoeff=zeros(p.fCoeff,(len)*p.pCoeff);
DFTs=zeros(p.DFT_FCoeff, p.DFT_PCoeff);
DFTsSum=zeros(1, p.numPeriods);

DFTvec = zeros(len, p.pCoeff*p.fCoeff);

offset1=1;


%calculate DFTs 
for i=1:len,
    curFrame = periodicity(:,offset1:offset1+p.numPeriods-1);
    %curFrame = normalizeOP(curFrame);
    
    if p.norm,
        %curFrame=normalizeOP(curFrame);
        %curFrame=normalizeOP(curFrame);
        %nOPs = normalizeOP(nOPs);
        %curFrame = normalizeOP(curFrame);
        %nOPs = filter(ones(1,3)/3,1,nOPs);
        %curFrame=filter(ones(1,3)/3,1,curFrame);
        curFrame = curFrame - (nOPs);
        
        %win=4 gets 84.8854%
        %win=5 gets 85.5211%
        %win=6 gets 85.1003%
        %win=7 gets 84.5272%
        %curFrame = curFrame.* nOPs;
        
        %curFrame = sqrt(curFrame);
        %curFrame = curFrame./repmat(max(curFrame,[],1),freqs,1);
    end
    if p.smoothOn,
        curFrame=filter(ones(1,5)/5,1,curFrame(end:-1:1,:));
        curFrame = curFrame(end:-1:1,:);
    end
    OPs = OPs + curFrame;
    OPsSum = OPsSum + sum(curFrame);
    
    temp=fft2(curFrame);
    
    %
    
    
        %dct2(curFrame, p.fCoeff,p.pCoeff);
    temp=abs(temp(1:p.DFT_FCoeff,1:p.DFT_PCoeff));
    
    tempSum = abs(fft(sum(curFrame)));   

    DFTs = DFTs + temp;
    DFTsSum= DFTsSum+tempSum;

    offset1=offset1+p.numPeriods;
    
end

%covDFTs = cov(DFTvec);
%covDFTs = covDFTs(:);


OPs = OPs / len;
OPs = OPsSum/len;


DFTs = DFTs / len;

DFTs = DFTsSum / len;

end


%%

function periodicity = get_periodicity(onsets, p)

[fBins, len]=size(onsets);

buf = buffer(onsets(1,:),p.opWin, p.opWin-p.opHop,'nodelay');

temp = fourierTempogram2(buf,p);
[periodicities,frames]=size(temp);

periodicity=zeros(fBins, frames*periodicities);

periodicity(1,:)=reshape(temp,1,frames*periodicities);

for i=(2:fBins),
    buf = buffer(onsets(i,:),p.opWin, p.opWin-p.opHop, 'nodelay');
    temp =...
        (fourierTempogram2(buf,p));
    
    periodicity(i,:)=reshape(temp,1,frames*periodicities);
end

end

%%
function tempi=fourierTempogram2(onsets, p)
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

logFilters = logfmap(len, 40, 800, p.fs, p.numPeriods); 

%plot(melFilters);

%tempi = magSpectrum;
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

%%
function OP= normalizeOP(OP)
temp = OP-min(min(OP));
OP = temp/max(max(temp));
end
