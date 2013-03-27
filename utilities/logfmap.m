function M = logfmap(I,begBPM,endBPM, fs, numBins, cent)
% [M,N] = logfmap(I,L,H)
%     Return a maxtrix for premultiplying spectrograms to map
%     the rows into a log frequency space.
%     Output map covers bins L to H of input
%     L must be larger than 1, since the lowest bin of the FFT
%     (corresponding to 0 Hz) cannot be represented on a 
%     log frequency axis.  Including bins close to 1 makes 
%     the number of output rows exponentially larger.
%     N returns the recovery matrix such that N*M is approximately I
%     (for dimensions L to H).
%     
% 2004-05-21 dpwe@ee.columbia.edu

% Convert base-1 indexing to base-0

%%%
%modified by Tlacael Esparza
%%%

if nargin < 6
   cent = false; 
end

winLen = (I-1)*2;

if cent,
    freqs = zeros(numBins,1);
    freqs(1)=begBPM;%103.6105;

    %find center  frequencys for 85 filters
    for i=2:numBins
        freqs(i)=freqs(i-1)*pow2(103.6/1200);
    end

    %convert to bin numbers
    div = fs / (winLen);
    ibin = freqs/div;


else
    b = log2(begBPM);
    e = log2(numBins*begBPM);
    
    freqs = pow2(linspace(b,e,numBins))/60;

    %freqs = logspace(b,e,numBins)/60;

    %convert to bin numbers
    div = fs / (winLen);
    ibin = freqs/div;
end


M = zeros(numBins,I);

for i = 1:numBins
  % Where do we sample this output bin?
  % Idea is to make them 1:1 at top, and progressively denser below
  % i.e. i = max -> bin = topbin, i = max-1 -> bin = topbin-1, 
  % but general form is bin = A exp (i/B)
%  M(i,round(ibin(i))) = 1;
  tt = pi*([0:(I-1)]-ibin(i));
  M(i,:) = (sin(tt)+eps)./(tt+eps);
end

