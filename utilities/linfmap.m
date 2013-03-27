function M = logfmap(origBins, numBins)
% [M,N] = linfmap(I,L,H)

% 2004-05-21 dpwe@ee.columbia.edu

% Convert base-1 indexing to base-0

%%%
%modified by Tlacael Esparza
%%%

ibin = linspace(1,origBins,numBins);

M = zeros(numBins,origBins);

for i = 1:numBins
  tt = pi*([0:(origBins-1)]-ibin(i));
  M(i,:) = (sin(tt)+eps)./(tt+eps);
end

