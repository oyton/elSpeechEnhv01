% VERIYLE ILGILI GIRDILER
% Noise Periyotlari
% BB01_04_electrolarynxSpeech.wav 
% yalin el sesi
% 9.0 - 11.7s & 20.6 - 23.6s
[sub01data,fs01] = wavread(...
'./BB01_04_electrolarynxSpeech.wav');
noiSub01Markers = [9.0 11.7; 20.6 23.6]; 
% [gurultubasi1 gurultusonu1; gurultubasi2 gurultusonu2]
% MO01_04_electrolarynxDpeech.wav 
% yalin el sesi
% 9.20 - 9.60s & 16.9 - 17.3s
[sub02data,fs02] = wavread(...
'./MO01_04_electrolarynxSpeech.wav');
noiSub02Markers = [9.2 9.6; 16.9 17.3]; 
% [gurultubasi1 gurultusonu1; gurultubasi2 gurultusonu2]

% kullanici girdileri
winDuration = 0.030; % pencere uzunlugu s
winOverPercent = 75; % pencere ortusme yuzde
dataInPro.rawData = sub01data;
dataInPro.fs = fs01;
dataInPro.preProLPFilterFile = 'LPfilt01.mat'; %FIR Filtre AG
dataInPro.preProHPfilterFile = 'HPfilt01.mat'; %FIR Filtre YG
dataInPro.windowType = 1; % 1 Hamming Pencerelemesi (sadece Hamming)
dataInPro.noiseMarker = noiSub01Markers;

% onisleme
% GIRDI:
%   {1:isaret dizisi (1D),2:ornekleme frekansi,
%       3:AGF dosya, 4:YGF dosya, 5:pencere uzunlugu, 6:pencere tipi,
%       7:ortusme orani}
% CIKTI:
%   {1:Filtrelenmis->Pencerelenmis Isaret(zaman uzayi), 2:1 yapisinda zaman
%       bilgisi, 3: fft(1), 4:filtrelenmis isaret}
[dataInPro.winT, dataInPro.times, dataInPro.winF, dataInPro.filtered] =...
    preProcess(dataInPro.rawData, dataInPro.fs,...
    dataInPro.preProLPFilterFile, dataInPro.preProHPfilterFile,...
    winDuration, dataInPro.windowType, winOverPercent);
dataInPro.winTsize = size(dataInPro.winT,1);
dataInPro.winFsize = size(dataInPro.winF,1);
% gurultu kestirimi
dataInPro.noiseEstF = zeros(dataInPro.winFsize,1);

% yalin EL sesi barindiran pencere numaralari
dataInPro.noiseWindowNos = [];
for i =1:size(dataInPro.noiseMarker,1);
dataInPro.noiseWindowNos = [dataInPro.noiseWindowNos ...
    find((dataInPro.noiseMarker(i,1)<dataInPro.times(1,:))...
    .*(dataInPro.noiseMarker(i,2)>dataInPro.times(1,:))>0)]; 
end

% ciktilari ilk kullanima hazirlamak
dataInPro.method01.outWinF = zeros(size(dataInPro.winF));
dataInPro.method02.outWinF = zeros(size(dataInPro.winF));

% pencere bazinda isleme: yontem1 ve yontem2 icin
for win = 1:size(dataInPro.winF,2)
    %gurultuyse, kestirimi yap
    if ismember(win, dataInPro.noiseWindowNos)
        dataInPro.noiseEstF = noiseEst(dataInPro.noiseEstF,...
            dataInPro.winF(:,win));
    end
    
    dataInPro.method01.outWinF(:,win) = method01AmpSubt(...
        dataInPro.winF(:,win), dataInPro.noiseEstF);
    dataInPro.method02.outWinF(:,win) = method02PowSubt(...
        dataInPro.winF(:,win), dataInPro.noiseEstF);
end

% method 1 ciktisi Spektral Genlik Cikarimi, zaman uzayina donus
dataInPro.method01.outWinT = ifft(dataInPro.method01.outWinF);
dataInPro.method01.outT = real(matrix2array(dataInPro.method01.outWinT,...
    dataInPro.winTsize/2 , dataInPro.winTsize*(100-winOverPercent)/100));

% method 2 ciktisi Spektral Guc Cikarimi, zaman uzayina donus
dataInPro.method02.outWinT = ifft(dataInPro.method02.outWinF);
dataInPro.method02.outT = real(matrix2array(dataInPro.method02.outWinT,...
    dataInPro.winTsize/2 , dataInPro.winTsize*(100-winOverPercent)/100));



% method 3 Asiri Cikarma Kullanaral Spektral Cikarma
% gurultu bilgisi sifirlama
dataInPro.noiseEstF = zeros(size(dataInPro.noiseEstF));
% ciktinin ilk kullanima hazirlanmasi
dataInPro.method03.outWinF = zeros(size(dataInPro.winF));

% pencere bazinda isleme
for win = 1:size(dataInPro.winF,2)
    if ismember(win, dataInPro.noiseWindowNos)
        dataInPro.noiseEstF = noiseEst(dataInPro.noiseEstF, dataInPro.winF(:,win));
    end
    [dataInPro.method03.outWinF(:,win), postSNRs(win),...
        numBigInds(win), numElseInds(win)]= method03SpecSubOver(...
        dataInPro.winF(:,win), dataInPro.noiseEstF);
    
end
dataInPro.method03.outWinT = ifft(dataInPro.method03.outWinF);
dataInPro.method03.outT = real(matrix2array(dataInPro.method03.outWinT,...
    dataInPro.winTsize/2, dataInPro.winTsize*(100-winOverPercent)/100));

% method 4 dogrusal olmayan spektral cikarma 
% degisken ilk degerlemesi
dataInPro.noiseEstF = zeros(size(dataInPro.noiseEstF));
dataInPro.method04.outWinF = zeros(size(dataInPro.winF));
sizeOfaWindow = size(dataInPro.noiseEstF,1);

% yontem degiskenleri
mux = 0.5;
mud = 0.5;
betas = 0.1;
gammas = 1;
Nomega = zeros(sizeOfaWindow);
Noind = 0;
NomegaData = zeros(size(dataInPro.noiseEstF,1),40);
XuFa = zeros(sizeOfaWindow,2);
DuFa = zeros(sizeOfaWindow,2);
sonindex = 1;

for win = 2:size(dataInPro.winF,2)
    
    indexs = mod(win,2)+1;
    indexsB = mod(win+1,2)+1;
    % gurultu ?
    if ismember(win, dataInPro.noiseWindowNos)
        % en yuksek gurultu guncellemesi
        Noind = mod(Noind, 41)+1; % N icinde dolasmak icin indis
        dataInPro.noiseEstF = noiseEst(dataInPro.noiseEstF, ...
            dataInPro.winF(:,win)); % gurultu kestirimi
        NomegaData(:,Noind) = dataInPro.noiseEstF(:); % gurultu kestirimi 
        % atamasi
        
        DuFa(:,indexs) = mud*abs(DuFa(:,indexsB)) +...
            (1-mud)*abs(dataInPro.noiseEstF); % gurultu kestirimi yumusatma
        sonindex = indexs;
    end
    
    Nomega = max(NomegaData, [], 2); % en yuksek gurultu 
    XuFa(:,indexs) = mux*abs(XuFa(:,indexsB)) + ...
        (1-mux)*abs(dataInPro.winF(:,win)); %! iyilestirilmis isaret yumusatma
    
    roF = abs(XuFa(:,indexs))./abs(DuFa(:,sonindex)); % posterior IGO etki katsayisi
    
    alphaF = 1./(1+gammas*roF);
    
    dataInPro.method04.outWinF(:,win) = method04NonLinSS(...
        dataInPro.winF(:,win), XuFa(:,indexs), Nomega, alphaF,...
        betas, DuFa(:,sonindex)); 
    
    
end 
dataInPro.method04.outWinT = ifft(dataInPro.method04.outWinF);
dataInPro.method04.outT = real(matrix2array(dataInPro.method04.outWinT,...
    dataInPro.winTsize/2, dataInPro.winTsize*(100-winOverPercent)/100));

% yontem 5 coklu bant spektral cikarma

% degisken ilk degerleme
dataInPro.noiseEstF = zeros(size(dataInPro.noiseEstF));
dataInPro.method05.outWinF = zeros(size(dataInPro.winF));

% yontem degiskenleri
sizeOfaWindow = size(dataInPro.noiseEstF,1);
sizeOfAll = size(dataInPro.winF);

% yontem girdileri inputs
%   frekans bantlari, satir tabanli, baslangic bitis frekanslari
bands = [0 500; 
    500 4000; 
    4000 12000; 
    12000 24000];
%   spektral taban katsayisi
betam = 0.002;
%   agirlikli spektral ortalama alma uzunlugu
M = 2;
%   spektral agirliklar
Wi = [0.09 0.25 0.32 0.25 0.09];
%   bantici cikarma kontrolu saglayan delta
deltaifrs = [0 1000;
    1000 dataInPro.fs/2-2000;
    dataInPro.fs/2-2000 dataInPro.fs/2];
%   bantlara karsilik gelen delta katsayilari
deltaigain = [1.0 2.5 1.5];
%   alpha IGO araliklari
alphaiSNRs = [-inf -5; -5 20;20 inf];
%   alphai = alpha degerleri islev icinde.

%   frekans belirtecleri
frs = linspace(0,dataInPro.fs/2,sizeOfaWindow/2+1);
srf = -1*fliplr(frs);
frs = [frs srf(2:end-1)]';

for win = 1:sizeOfAll(2)
    % gurlutu penceresi?
    if ismember(win, dataInPro.noiseWindowNos)
        dataInPro.noiseEstF = noiseEst(dataInPro.noiseEstF, ...
            dataInPro.winF(:,win));
    end
    % agirlikli ortalama alinacak pencereler
    blockInds = win-M:win+M;
    % kenar kontrolleri
    inds = find((blockInds>=1) .* (blockInds<=sizeOfAll(2)));
    % agirlikli spektral ortalama
    XuFa = sum(repmat(Wi(inds),sizeOfaWindow,1).*...
        dataInPro.winF(:,blockInds(inds)),2);
    
    
    [dataInPro.method05.outWinF(:,win), SNrs(:,win)] = method05MultiSS(...
        dataInPro.winF(:,win), dataInPro.noiseEstF, XuFa, frs, ...
        bands, betam, alphaiSNRs, deltaifrs, deltaigain);
end

dataInPro.method05.outWinT = ifft(dataInPro.method05.outWinF);
dataInPro.method05.outT = real(matrix2array(dataInPro.method05.outWinT,...
    dataInPro.winTsize/2, dataInPro.winTsize*(100-winOverPercent)/100));

% yontem 6 algisal ozelllikli cikarma
% degisken ilk degerlemesi
dataInPro.noiseEstF = zeros(size(dataInPro.noiseEstF));
dataInPro.method06.outWinF = zeros(size(dataInPro.winF));

% yontem degiskenleri 
sizeOfaWindow = size(dataInPro.noiseEstF,1);
sizeOfAll = size(dataInPro.winF);
% dogrusal ongorum kodlamasi kutup sayisi
p = 24;
% P(z) pay sigma
sigma1 = 1;
% P(z) payda sigma
sigma2 = 0.8;

% alpha-beta uc degerleri
alphamin = 1;
alphamax = 6;
betamin = 0;
betamax = 0.02;

for win = 1:sizeOfAll(2)
    % gurultu?
    if ismember(win, dataInPro.noiseWindowNos)
        dataInPro.noiseEstF = noiseEst(dataInPro.noiseEstF, dataInPro.winF(:,win));
    end
    [dataInPro.method06.outWinF(:,win), alphas06(:,win), betas06(:,win)] = ...
        method06PerceptSS(dataInPro.winT(:,win), dataInPro.winF(:,win), ...
        dataInPro.noiseEstF, p, sigma1, sigma2, alphamin, alphamax, ...
        betamin, betamax);
end

dataInPro.method06.outWinT = ifft(dataInPro.method06.outWinF);
dataInPro.method06.outT = real(matrix2array(dataInPro.method06.outWinT,...
dataInPro.winTsize/2, dataInPro.winTsize*(100-winOverPercent)/100));
