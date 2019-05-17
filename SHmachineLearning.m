function [Calls,CallsIDX,M] = SH_MachineLearning(Net,S,t,F,Template,Scale,h)
    
    % Template Matching
    [r,c]=size(Template);
    Upper = find(F==1000);
    Downward = find(F==3000);
    S = S(Upper:Downward,:);
    M = normxcorr2(Template,S);
    M = M(r:size(M,1)-r+1,c:end);
    
    % Envelope and Findpeaks
    Scale = Scale * 2;
    Distance=round(Scale*numel(Template));
    [up,~] = envelope(M(:),Distance,'peak');
    [pks,~,W,prom] = findpeaks(up);
    
    % Find the index under the envelope
    if up(1)<up(2)
    idx(1) = 1;
    Temp = find(islocalmin(up)==1);
    idx(2:numel(Temp)+1) = Temp;
    else
        idx = find(islocalmin(up)==1);
    end

    if up(end)<up(numel(up)-1)
        idx(numel(idx)+1) = numel(up);
    end
    
    % Features and Calls' Location
    Features = zeros(numel(pks),4);
    LocsUp = cell(numel(pks),1);
    Locs = zeros(numel(pks),1);
    Width = zeros(numel(pks),1);
    for i=1:numel(idx)-1
        LocsUp{i} = idx(i):idx(i+1);
        Width(i) = numel(LocsUp{i});
        Variance = var(M(LocsUp{i}));
        [~,Locs(i)] = max(M(LocsUp{i}));
        Locs(i) = Locs(i) + LocsUp{i}(1) - 1;
        Features(i,:) = [pks(i),Width(i),prom(i),Variance];
    end
    
    % Just for tryout
    Features(:,4) = [];
    % Predict if it contains calls
    Predict = Net(Features');
    Locs(Predict<0.5) = [];
    Width(Predict<0.5) = [];
    
    Temp = W(Predict>=0.5);
    Width = Temp;
    Width = Width./r;
%     Width = Width./2;
    % StarT and F
    [StartF,StartT] = ind2sub(size(M),Locs);
    EndT = StartT + Width - 1;
    EndF = StartF + size(Template,1)-1;
    EndT = round(EndT);
    EndT(EndT>size(M,2)) = size(M,2);
    CallsIDX = [(StartT),(EndT),(StartF),(EndF)];
    Calls = [t(StartT)',t(EndT)',F(StartF)'+1000,F(EndF)'+1000];
end

