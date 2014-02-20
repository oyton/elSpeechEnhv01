function [ enhF, alphas, betas ] = method06PerceptSS( winT, winF, noiF,...
    lpcP, sig1, sig2, alphamin, alphamax, betamin, betamax )
%METHOD06PERCEPTSS 
% Girdiler:
%   wintT: EL isareti (zaman) 
%   winF: EL isareti (frekans) 
%   noiF: Gurultu kestirimi
%   lpcP: dogrusal ongorum kodlamasi kutup sayisi
%   sig1: P(z) pay carpani
%   sig2: P(z) payda carpani
%   alphamin: alpha alt sinir
%   alphamax: alpha ust sinir
%   betamin: beta alt sinir 
%   betamax: beta ust sinir

    % zaman isaretinden DOK katsayilari
    [a,q] = lpc(winT,lpcP);
    % sigma carpanlari
    sigma1 = ones(lpcP+1,1);
    sigma2 = ones(lpcP+1,1);
    % pay ve payda ifadeleri
    sigma1(2:end) = a(2:end).*(sig1.^sigma1(2:end)');
    sigma2(2:end) = a(2:end).*(sig2.^sigma2(2:end)');
    % P(z) pay ve payda
    numerator = [sigma1(1); -sigma1(2:end)];
    denominator = [sigma2(1); -sigma2(2:end)];
    % P(z)'den frekans uzayina gecis
    [h,w] = freqz(numerator, denominator, length(winT)/2+1);
    % fft frekanslariyla uyusturma
    pwfc = [h(1:end); flipud(h(2:end-1))];
    % T(omega) sinirlarini belirleme
    Tmax = max(pwfc);
    Tmin = min(pwfc);
    % alpha beta ifadeleri
    alphas = ((Tmax-pwfc)/(Tmax-Tmin))*alphamax +...
        ((pwfc-Tmin)/(Tmax-Tmin))*alphamin;
    betas = ((Tmax-pwfc)/(Tmax-Tmin))*betamax +...
        ((pwfc-Tmin)/(Tmax-Tmin))*betamin;
    
    
    Y2f = abs(winF.*conj(winF));
    D2f = abs(noiF.*conj(noiF));
    X2f = zeros(size(Y2f));
    bigInds = find(Y2f>(alphas+betas).*D2f);
    elseInds = find(Y2f<=(alphas+betas).*D2f);
    
    alphabeta = alphas(bigInds)+betas(bigInds);
    X2f(bigInds) = Y2f(bigInds)-alphabeta.*D2f(bigInds);
    X2f(elseInds) = betas(elseInds).*D2f(elseInds);
    % faz bilgisi ekleme
    enhF = sqrt(X2f).*exp(1i*angle(winF));
     
    

    

end

