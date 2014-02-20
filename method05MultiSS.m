function [ enhF, SNRi ] = method05MultiSS( winF, noiEstF, XuFa, ...
    freqScope, bands, betam, alphaSNRs, deltaFs, deltaG )
% METHOD05MULTISS 
% Girdiler:
%   winF: EL konusma penceresi (f)
%   noiEstF: Gurultu penceresi (f)
%   XuFa: agirlikli spektral ortalama (f)
%   freqScope: fft ciktisinin frekans bilesenleri
%   bands: bantlar, genel, baslangic, bitis
%   betam: spektral taban katsayisi
%   alphaSNRs: alpha katsayisi sinirlari
%   deltaFs: delta katsayisi sinirlari
%   deltaG: delta katsayilari

sizeOfaWindow = size(winF,1);

% band belirtec vektoru, her bant icin 
bandInd = zeros(size(winF,1), size(bands,1));
for i = 1:size(bands,1)
    bandInd(:,i) = (freqScope >= bands(i,1)) .* (freqScope < bands(i,2)) + ...
        (freqScope <= -bands(i,1)) .* (freqScope > -bands(i,2));
    bandInd(:,i) = bandInd(:,i)>0;
end

% delta belirtec vektoru .* delta degeri
deltai = zeros(sizeOfaWindow, 1);
for i = 1:size(deltaFs,1)
    deltaInd(:,1) = (freqScope>=deltaFs(i,1)).*(freqScope<=deltaFs(i,2)) + ...
        (freqScope<=-deltaFs(i,1)).*(freqScope>=-deltaFs(i,2));
    gainInds = find(deltaInd(:,1)>0);
    deltai(gainInds) = deltaG(i);
end

% bant IGO hesabi
SNRi = zeros(size(bands,1),1);
for i = 1:size(bands,1)
    bwinF = XuFa.*bandInd(:,i);
    bnoiF = noiEstF.*bandInd(:,i);
    SNRi(i) = 10*log10(abs(bwinF'*conj(bwinF))/abs(bnoiF'*conj(bnoiF)));
end

% IGO'ya gore alpha carpan vektorleri olusturma
alphai = zeros(sizeOfaWindow, size(alphaSNRs,1));
for i = 1:size(bands,1)
    if alphaSNRs(1,1) <= SNRi(i) && SNRi(i) <= alphaSNRs(1,2)
        alphai(:,i) = repmat([4.75], sizeOfaWindow, 1);
    elseif alphaSNRs(2,1) <= SNRi(i) && SNRi(i) <= alphaSNRs(2,2)
        alphai(:,i) = repmat([4-3.0/20*SNRi(i)], sizeOfaWindow,1);
    elseif alphaSNRs(3,1) <= SNRi(i) && SNRi(i) <= alphaSNRs(3,2)
        alphai(:,i) = repmat([1], sizeOfaWindow,1);
    end
end

% Pencere guc bilesenleri
XuFa2 = abs(XuFa.*conj(XuFa));
% Bant bazinda pencere gucleri
xi2u = zeros(sizeOfaWindow, size(bands,1));
for i = 1:size(bands,1)
    XuFa2band = XuFa2.*bandInd(:,i);
    noiband = abs(noiEstF.*conj(noiEstF)).*bandInd(:,i);
    % alpha + delta cikarimi
    temp2 = XuFa2band - alphai(:,i).*deltai.*noiband;
    % beta eklemesi
    bigInds = find(temp2>(betam*XuFa2band));
    elseInds = find(temp2<=(betam*XuFa2band));
    temp2(elseInds) = betam*XuFa2band(elseInds);
    xi2u(:,i) = temp2 + 0.05*XuFa2band;
end

enhFa2 = sum(xi2u,2);
% faz bilgisi ekleme
enhF = sqrt(enhFa2).*exp(1i*angle(winF));

end

