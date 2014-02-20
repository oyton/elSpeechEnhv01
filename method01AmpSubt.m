function [ enhancedWindowF ] = method01AmpSubt( noisyWindowF, noiseEstF )
%METHOD01AMPSUBT Summary of this function
% INPUTs
% noisyWindowsF : a window of noisy signal
% noiseEstF : estimated noise spectrum
% OUTPUT
% enhancedWindowsF : enhanced window! a window, vector

    tempF = abs(noisyWindowF)-abs(noiseEstF);
    tempF(find(tempF<0)) = 0;
    enhancedWindowF = abs(tempF).*exp(1i*angle(noisyWindowF));
end

