function [ updatedNoiseSpectrum ] = noiseEst( noiseEst, noisyDataWindowF )
% INPUTs
% noiseEst ; previous estimation of noise spectrum
% noisyDataWindowF; new windows marked as noise
% OUTPUTs
% updatedNoiseSpectrum; new noise estimation 

    updatedNoiseSpectrum = (noiseEst + noisyDataWindowF)/2;

end

