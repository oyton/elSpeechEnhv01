function [ enhF ] = method04NonLinSS( winF, XuFa, NF,...
    alphas, betas, DuFa )
% METHOD04NONLINSS 
% Girdi:
%   winF: Pencerelenmis isaret(f)
%   XuFa: Yumusatilmis EL isareti (f)
%   NF: Son 40 penceredeki en yuksek gurultu (f)
%   alphas: Pencere icin asiri cikarim katsayisi (f)
%   betas: Pencere icin spektral taban katsayisi (f)
%   DuFa: Yumusatilmis Gurultu

% iyilestirilmis isaret baslangic degeri atama
enhFa = zeros(size(winF));
% buyuk degerlerin indisleri
bigInds = find(XuFa > (alphas.*NF + betas.*DuFa));
% kucuk degerlerin indisleri
elseInds = find(XuFa <= (alphas.*NF + betas.*DuFa));
enhFa(bigInds) = XuFa(bigInds) - alphas(bigInds).*NF(bigInds);
enhFa(elseInds) = betas*XuFa(elseInds);
% faz bilgisi ekleme
enhF = enhFa.*exp(1i*angle(winF));

end

