function [ outputt, tt, outputf, dataFiltered ] = s01preprocess( data1d, fsdata,...
    filterLP, filterHP, winDur, winType, winOverlap )
% data1d : ham girdi, 1B
% fsdata : ornekleme frekansi
% filtre dosyalari filterHP, filterLP (.mat uzantili)
% winDur : pencere suresi
% winType : {1: 'HAMMING'} 
% winOverlap : ortusme yuzdesi
% outputt : Matris, her sutun bir pencere
% tt: Matris, zaman degerleri
% outputf : Matris, her sutun bir pencerenin fftsi 
% dataFiltered : sadece filtrelenmis veri 1B

ou = load(filterHP);
tempData = filter(ou.Num,1,data1d);
ou = load(filterLP);
dataFiltered = filter(ou.Num,1,tempData);
tempT = (0:length(dataFiltered)-1)*(1.0/fsdata); 
winNop = winDur*fsdata;

if (winType==1)
    winData = hamming(winNop);
end
 
outputt = buffer(dataFiltered, winNop, 1.0*winOverlap/100*winNop);
tt = buffer(tempT, winNop, 1.0*winOverlap/100*winNop);
outputt = outputt.*repmat(winData,1,size(outputt,2));

outputf = fft(outputt);
end