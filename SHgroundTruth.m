function Locs = GroundTruth(M,Annotation,File,t)
    % Find the ground truth
    idx = find(Annotation(:,1)>(File-1)*10&Annotation(:,1)<(File)*10);
    Time = Annotation(idx,1);
    Temp = abs(t-Time);
    [~,idxX] = min(Temp,[],2);
    X = zeros(size(idxX));
    Y = zeros(size(idxX));
    for i=1:numel(idxX)
        TempIDX = idxX(i)-30:idxX(i)+30;
        TempIDX = TempIDX(TempIDX>0);
        TempIDX = TempIDX(TempIDX<=size(M,2));
        Temp = M(1:end,TempIDX);
        [~,idx] = max(Temp(:));
        [row,col] = ind2sub(size(M),idx);
        X(i) = row;
        Y(i) = col+TempIDX(1)-1;
    end
    Locs = sub2ind(size(M),X,Y);
end

