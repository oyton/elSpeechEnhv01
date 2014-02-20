function [ enhF, postSNR, numBigInds, numElseInds ] = method03SpecSubOver( winF, noiF )
% method03SpecSubOver
% Girdi
%   winF: gurultulu isaretin bir penceresi (f uzayi)
%   noiF: bir pencerelik gurultu kestirimi (f uzayi)
% Cikti
%   enhF: iyilestirilmis isaretin bir penceresi (f uzayi)
%   postSNR: posterior SNR
%   


% kullanici tanimli parametreler
alpha0 = 4;
betaHsnr = 0.02;
betaLsnr = 0.06;

% cikti ilk kullanima hazirlama
enhF2 = zeros(size(winF));
% posterior SNR hesaplama
postSNR = 10*log10(abs(winF'*conj(winF))/abs(noiF'*conj(noiF)));

postSNRLowLimit = -5;
postSNRHighLimit = 20;

% alpha, beta belirleme
if (postSNRLowLimit < postSNR) && ( postSNR < postSNRHighLimit)
    alphas = alpha0-(3.0/20)*postSNR; % !                                     % -----------> should depend on alpha0
    if postSNR > 0 % !
        betas = betaHsnr;
    else
        betas = betaLsnr;
    end
    
else
    alphas = 0; %
    betas = 0; % 
end

winF2 = winF.*conj(winF);
noiF2 = noiF.*conj(noiF);

% durumlara gore cikarmalar
bigInds = find(winF2>(alphas+betas)*noiF2);
elseInds = find(winF2<=(alphas+betas)*noiF2);
numBigInds = length(bigInds);
numElseInds = length(elseInds);
enhF2(bigInds) = winF2(bigInds)-alphas*noiF2(bigInds);
enhF2(elseInds) = betas*noiF2(elseInds);

enhF = sqrt(enhF2).*exp(1i*angle(winF));

end

