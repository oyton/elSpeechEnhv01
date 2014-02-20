function [ enhancedWindowF ] = method02PowSubt( noisyWindowF, noiseEstF )
%METHOD02POWSUBT Summary of this function goes here
% INPUTs
% noisyWindowsF : a window of noisy signal
% noiseEstF : estimated noise spectrum
% OUTPUT
% enhancedWindowsF : enhanced window! a window, vector

    tempF = noisyWindowF.*conj(noisyWindowF)-noiseEstF.*conj(noiseEstF);
    tempF(find(tempF<0)) = 0;
    enhancedWindowF = (tempF.^0.5).*exp(1i*angle(noisyWindowF));

end

