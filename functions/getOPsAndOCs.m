% Function calculates OPs and OCs for input onset curve
function [OPs, OCs] = getOPsAndOCs(periodicity,p, plotOn)
%opWin, opHop, fs, norm, fCoeff, pCoeff,numPeriods, yesPlot)


%get OCs and OPs
[OCs, OPs, ~] =getOCs(periodicity,p);




end



%%
function nOPs = loadMask(p,numFreqs)
    filename = 'Pohl_method/normalize.mat';
    try
        data=load(filename);
        nOPs= data.nOPs;
        %disp('Loaded normalize.mat');
    %recalculate if file not there
    catch err
        nOPs = sendNoisePohl(p.params);
        save(filename, 'nOPs'); 
    end
    
    [m,n] = size(nOPs);
    
    %recalculate if necessary
    if m~=numFreqs || n ~= p.numPeriods,
        nOPs = sendNoisePohl(p.params);
        save(filename, 'nOPs');
     
    end
    
    %%%process normOP
    if 0,
    %%calculate mean vector
    %nOPs=repmat(mean(nOPs),38,1);
    elseif 0,
    %%smooth mask along frequencies
    %nOPs=filter(ones(1,5)/5,1,nOPs(end:-1:1,:));
    %nOPs = nOPs(end:-1:1,:);
    elseif 0,
    %%smooth mask with gaussian kernel
    %nOPs = imfilter(nOPs(end:-1:1,:), myfilter, 'replicate');
    %nOPs = nOPs(end:-1:1,:);
    end
end

%%
function [OCs, OPs, periodicity] = getOCs(periodicity, p)

[numFreqs, segs]=size(periodicity);

%creat gaussian filter
myfilter = fspecial('gaussian',[2 3], 0.5);


% get mask for filter normilization
if p.norm,
    nOPs = loadMask(p,numFreqs);
end

%allocate
OPs=zeros(numFreqs,p.numPeriods);

len=floor(segs/p.numPeriods);
if len ==0, 
    len=1;
end

OCoeff=zeros(p.fCoeff,(len)*p.pCoeff);
OCs=zeros(p.fCoeff, p.pCoeff);

OCvec = zeros(p.fCoeff*p.pCoeff,len);

offset1=1;


%calculate OCs 
for i=1:len,
    curFrame = periodicity(:,offset1:offset1+p.numPeriods-1);
    %curFrame = normalizeOP(curFrame);
     
    if p.norm,
        
        %smooth OP before masking
        %nOPs = filter(ones(1,3)/3,1,nOPs);
        %curFrame=filter(ones(1,3)/3,1,curFrame);
        
        %apply filter norm mask
        curFrame = curFrame - nOPs;
        
        %normalize frame
        %curFrame = normalizeOP(curFrame);
        
    end
    %apply gaussian kernal filter after norm
    %curFrame = imfilter(curFrame(end:-1:1,:), myfilter, 'replicate');
    
    %apply frequency direction smoothing
    if p.smoothOn,
        curFrame=filter(ones(1,5)/5,1,curFrame(end:-1:1,:));
        curFrame = curFrame(end:-1:1,:);
    end
    
    %aggregate OPs
    OPs = OPs + curFrame;
    
    %perform 2D-DCT on current OP frame
    temp = dct2(curFrame);
    %keep specified coefficients
    temp = temp(1:p.fCoeff,1:p.pCoeff);
    OCvec(:,i)=temp(:);
    
    offset1=offset1+p.numPeriods;
end

%calculate covariance on OC vectors
covOCs = cov(OCvec');
%vectorize
covOCs = covOCs(:);

OPs = OPs / len;

%aggregate OCs with mean
OCs=mean(OCvec,2);

%combine mean and covariance for output
OCs = [OCs; covOCs];

end







%%
function OP= normalizeOP(OP)
temp = OP-min(min(OP));
OP = temp/max(max(temp));
end
