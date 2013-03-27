
% PCA function
function [signals, PC,V]=pca1(data)
% PCA1: Perform PCA using covariance.
%   data - MxN matrix of unput data
%       (M dimension, N trials)
%   signals - MxN matrix of projected data
%         PC - each column is a PC
%       V - Mx1 matrix of variance

data=data';

[~,N] = size(data);

% subtract off the mean for each dimension
mn = mean(data,2);
data = data - repmat(mn,1,N);
%calculate the covariance
covariance = 1 / (N-1) * (data * data');
 %find the eigenvectors and eigenvalues
 [PC,V] = eig(covariance);
 
 %extract diagnocal of matrix as vector
 V = diag(V);
 
 %sort the variances in decreasing order
 [~, rindices] = sort(-1*V);
 V = V(rindices);
 PC = PC(:,rindices);
 
 %project the original data set
 signals = PC' * data;
 
 signals = signals';
