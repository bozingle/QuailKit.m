clc;clear;close all
%% Initialization
% Microphone Locations
mLoc = [33.421955 -100.885673 0 40;...
    33.421947 -100.886211 0 40;...
    33.421496 -100.886201 0 40;...
    33.421505 -100.885663 0 40];
% Speaker Location
sLoc=[33.42173 -100.88557];

Template = load('Template_291');
Template = Template.Template_291;
F=0:10:4000;Thresh = 0.296;Distance = 0.725;DoublePass = false;
window_size = 0.03; scale=0.08; overlap=0.8; freqs=[0,4000,10];doublepass=false;
%% Read All Mics Recordings
[audioA,Fs]=audioread('D:\data\11-29\Mics\SM304506_0+1_20191129_060000.wav');
% [audioB,~]=audioread('D:\data\11-29\Mics\SM304513_0+1_20191129_060000.wav');
% [audioC,~]=audioread('D:\data\11-29\Mics\SM304516_0+1_20191129_060000.wav');
% [audioD,~]=audioread('D:\data\11-29\Mics\SM304517_0+1_20191129_060000.wav');

%% Obtain Spectrograms
window = Fs*window_size;
[sA, ~, tA] = spectrogram(audioA(:,1), window ,round(overlap*window), F, Fs);
[B,~,~] = spectrogram(audioA(:,2), window ,round(overlap*window), F, Fs);
sA=db(abs(sA)+abs(B));
% [sB, ~, tB] = spectrogram(audioB(:,1), window ,round(overlap*window), F, Fs);
% [B,~,~] = spectrogram(audioB(:,2), window ,round(overlap*window), F, Fs);
% sB=db(abs(sB)+abs(B));
% [sC, ~, tC] = spectrogram(audioC(:,1), window ,round(overlap*window), F, Fs);
% [B,~,~] = spectrogram(audioC(:,2), window ,round(overlap*window), F, Fs);
% sC=db(abs(sC)+abs(B));
% [sD, ~, tD] = spectrogram(audioD(:,1), window ,round(overlap*window), F, Fs);
% [B,~,~] = spectrogram(audioD(:,2), window ,round(overlap*window), F, Fs);
% sD=db(abs(sD)+abs(B));
clear B;

%% Detect Calls
[CallsA,~,~] = SH_FindCalls(sA,tA,F,Template,Thresh,Distance,DoublePass,[]);
% [CallsB,~,~] = SH_FindCalls(sB,tB,F,Template,Thresh,Distance,DoublePass,[]);
% [CallsC,~,~] = SH_FindCalls(sC,tC,F,Template,Thresh,Distance,DoublePass,[]);
% [CallsD,~,~] = SH_FindCalls(sD,tD,F,Template,Thresh,Distance,DoublePass,[]);
mADETStart=CallsA(:,1);
% mBDETStart=CallsB(:,1);
% mCDETStart=CallsC(:,1);
% mDDETStart=CallsD(:,1);

%% Read Annotation File
[mAANNStart, mBANNStart, mCANNStart, mDANNStart] = getData("11_00_annotation", 1, 'start');

%% Find Matched Calls
[lagMatrix, matchedMatrixDETStart] = findMatches(mADETStart, mBDETStart, mCDETStart, mDDETStart);
[~,matchedMatrixANNStart] = findMatches(mAANNStart, mBANNStart, mCANNStart, mDANNStart);

%% Localize Calls
Num_Calls=size(matchedMatrixDETStart,2);
estimatedLocs = zeros(Num_Calls,4);
for i = 1:Num_Calls
    mLoc(:,3) = lagMatrix(:, i);
    if (sum(lagMatrix(:, i)==0)<2)
        [location] = HT_Localizer(mLoc);
        if (~isempty(location))
            estimatedLocs(i,:) = location(1,:);
        end
    end
end
MSELat = (1/(numel(estimatedLocs(:,1))))*sum((sLoc(1) - estimatedLocs(:,1)).^2);
MSELong = (1/(numel(estimatedLocs(:,1))))*sum((sLoc(2) - estimatedLocs(:,2)).^2);

%% Functions
function [mA, mB, mC, mD] = getData(filename, sheet, set)

    %Excel for ease
    xLData = xlsread(filename+".xlsx", sheet);
    
    if (strcmp(set, 'end'))
        i = 1;
    else
        i = 0;
    end
    
    mA = removeNaNSpots(xLData(:,1+i));
    mB = removeNaNSpots(xLData(:,2+i));
    mC = removeNaNSpots(xLData(:,3+i));
    mD = removeNaNSpots(xLData(:,4+i));
    
end

    function mA = removeNaNSpots(mA)
    nanSpots = find(isnan(mA) == 1);
    for i=1:length(nanSpots)
        mA(nanSpots(1)) = [];
    end
end

function [lagMatrix, matchedMatrix] = findMatches(mA,mB,mC, mD)

    maxTDistance=0.2;
    matchedMatrix = [];
    i = 1;

    while (i <= length(mA) && i <= length(mB) && i <= length(mC) && i <= length(mD))
        A=mA(i);
        if sum(abs(mB-A)<maxTDistance)>0 && sum(abs(mC-A)<maxTDistance)>0 && sum(abs(mD-A)<maxTDistance)>0
            B=min(mB(abs(mB-A)<maxTDistance));
            C=min(mC(abs(mC-A)<maxTDistance));
            D=min(mD(abs(mD-A)<maxTDistance));
            columnN = [A; B; C; D];
            matchedMatrix(:,i) = columnN;
            lagMatrix(:,i) = columnN - min(columnN);
        end

        i = i+1;
    end
end


function [TP, FP, FN] = compareData(DET, ANN)
    %find TP
    TP = 0;
    FN = 0;
    FP = 0;
    for incJ = 1:length(ANN)
        mTable = abs(DET-ANN(incJ));
        ref = min(mTable);
        if ref < 0.3
            TP = TP + 1;
        end
    end

    FP = length(DET) - TP;
    FN = length(ANN) - TP;
end
