% filename = "C:\Users\Joel\Desktop\stuffs\RecordData\10_00\Mics\SM304472_0+1_20181219_100000.wav";
% F=1000:10:3000;Thresh = 0.296;Distance = 0.725;DoublePass = false;
% window_size = 0.03; scale=0.08; overlap=0.8; freqs=[0,4000,10];doublepass=false;
% locRate = (1.44e7)/2;
% 
% info = audioinfo(filename);
% Fs = info.SampleRate;
% window = Fs*window_size; 
% 
% a1y = Fs*300;
% a = [1 a1y];
% j = 1;
% 
% while a(2) <= info.TotalSamples
%     [Audio2, ~] = audioread(filename, a);
%     Audio2 = abs(zscore(Audio2(:,1))) + abs(zscore(Audio2(:,2)));
%     
%     b1y = Fs*10;
%     b = [1 b1y];
%     k = 1;
%     while b(2) <= size(Audio2,1)
%         figure;
%         hold on;
%         ylim([1 3]);
%         spectrogram(Audio2(b(1):b(2)), window,round(overlap*window), F, Fs,'yaxis')
%         hold off;
%         
%         if b(2) == size(Audio2,1)
%             break;
%         elseif (k+1)*b1y <= size(Audio2,1)
%             b = b1y*[k k+1];
%         else
%             b = b1y*[k size(Audio2,1)];
%         end
%         k = k + 1;
%     end
%     
%     if a(2) == info.TotalSamples
%         break;
%     elseif (j+1)*a1y <= info.TotalSamples
%         a = a1y*[j j+1];
%     else
%         a = a1y*[j info.TotalSamples];
%     end
%     j = j+1;
% end
% mLoc = [];
% for i = 1: size(summaryData,2)
%     micData = readtable(summaryData(i));
%     temp = []
%     if char(micData{1,4}) == 'N'
%         temp(1) = mean(micData{:,3});
%     else
%         temp(1) = - mean(micData{:,3});
%     end
%     if char(micData{1,6}) == 'E'
%         temp(2) =  mean(micData{:,5});
%     else
%         temp(2) = - mean(micData{:,5});
%     end
%     temp(3) = 0;
%     temp(4) =  mean(micData{:,9});
%     mLoc = [mLoc; temp];
% end

matchedMatrixDETStart = matchedMatrixOverall;
matchedMatrixDETStart(find(matchedMatrixDETStart==0)) = NaN;
lagMatrix = getLagMatrix(matchedMatrixDETStart);

Num_Calls=size(matchedMatrixDETStart,2);
tempMLoc = mLoc; 
estimatedLocs = [];

if Num_Calls > 0
    estimatedLocs = zeros(1,5);
    i = 1;
    n = 1;
    while (n < Num_Calls)
        ind = find(~isnan(lagMatrix(:,n)));
        mLoc(:,3) = lagMatrix(:, n);
        mLoc = mLoc(ind,:);
        if (sum(lagMatrix(:, i)==0)<2)
            [location] = HT_Localizer(mLoc);
            if (~isempty(location))
                estimatedLocs(i,:) = [n location(1,:)];
                i = i + 1;
            end
        end
        n = n + 1;
        mLoc = tempMLoc;
    end
end

function lagMatrix = getLagMatrix(matchedMatrix)
   lagMatrix = [];
   i = 1;
   while i <= size(matchedMatrix,2)
       minVal = min(matchedMatrix(:,i));
       lagMatrix(:,i) = matchedMatrix(:,i) - minVal;
       i = i + 1;
   end
end