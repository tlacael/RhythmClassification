
% opens wave file for analysis. uses only left channel if stereo
function [x, fs] =loadAudio(filename,start, seconds)


% read in audio
try
    [x, fs] = wavread(filename);
catch
    return
end

% make sure signal is mono

if nargin < 2
    x = x(:, 1);
    
else
    if (seconds*fs+fs*start)>= size(x,1),
        x=x(:,1);
    else
        x = x(1+start*fs:fs*seconds, 1);
    end
    
end
end