function formatData()
addpath(genpath(pwd));
%Get the Data
[mADETStart, mBDETStart, mCDETStart, mDDETStart] = getData("QuailDetections",1, 'start');
%[mADETEND, mBDETEND, mCDETEND, mDDETEND] = getData("QuailDetections",1, 'end');
[mAANNStart, mBANNStart, mCANNStart, mDANNStart] = getData("QuailDetections", 2, 'start');
%[mAANNEND, mBANNEND, mCANNEND, mDANNEND] = getData("QuailDetections", 2, 'start');



%Refine the data
[lagMatrix, refinedMatrixDETStart] = findRefinedMatrix(mADETStart, mBDETStart, mCDETStart(2:end), mDDETStart);
%     [refinedMatrixANNStart] = findRefinedMatrix(mAANNStart, mBANNStart, mCANNStart, mDANNStart);

noEchoesADETStart = removeEchoesSimple(refinedMatrixDETStart(1,:));
noEchoesBDETStart = removeEchoesSimple(refinedMatrixDETStart(2,:));
noEchoesCDETStart = removeEchoesSimple(refinedMatrixDETStart(3,:));
noEchoesDDETStart = removeEchoesSimple(refinedMatrixDETStart(4,:));
%[lagMatrixDETStart, refinedMatrixDETStart] = removeEchoes(lagMatrixDETStart, refinedMatrixDETStart);

%The refined and lag matrix is represented as the following:
%1st row contains the A elements
%2nd row contains the B elements
%3rd row contains the C elements

%compare refined matrices of annotations and detections
[TPStart, TNStart, FPStart, FNStart] = compareData( noEchoesDDETStart, mDANNStart);
%[refinedTPEnd, refinedTNEnd, refinedFPEnd, refinedFNEnd] = compareData(refinedMatrixDETEnd, refinedMatrixANNEnd)
%compare annotations to detections
mRef = [33.40738 -101.49181 0 40;...
        33.40739 -101.49127 0 40;...
        33.40694 -101.49126 0 40;...
        33.40693 -101.49180 0 40];
results = [];
for i = 1:length(refinedMatrixDETStart(1,:))
    mRef(:,3) = lagMatrix(:, i);
    [location] = HT_Localizer(mRef);
    results(i,:) = location(1,:);
end
MSELat = (1/61)*sum((33.40678 - results(:,1)).^2);
MSELong = (1/61)*sum((-101.49168 - results(:,2)).^2);
%compare results of both
end

%find lag matrix
function [mA, mB, mC, mD] = getData(filename, sheet, set)

%Excel for ease
xLData = xlsread(filename+".xlsx", sheet);
if (strcmp(set, 'end'))
    i = 1;
else
    i = 0;
end
mA = removeNaNSpots(xLData(:,1+i));
mB = removeNaNSpots(xLData(:,3+i));
mC = removeNaNSpots(xLData(:,5+i));
mD = removeNaNSpots(xLData(:,7+i));

%For Database(Not working)
%conn = database("Quail", "", "");
%load files(currently temp matrices.)
%mA = databaseImportOptions(conn, ['SELECT Annotations.[Start Time], Annotations.[End Time]'...
%    'FROM Annotations'...
%    'WHERE (((Annotations.[Channel ID])=17) AND ((Annotations.[Created By]) Is Null))'...
%    'ORDER BY Annotations.[Start Time], Annotations.[End Time];'])
%mB = HT_DataAccess([], "query",...
%    ['SELECT Annotations.[Start Time], Annotations.[End Time], Annotations.[Channel ID]'...
%    'FROM Annotations'...
%    'WHERE (((Annotations.[Channel ID])=19) AND ((Annotations.[Created By]) Is Null) AND ((Annotations.DateTime)=#10/4/2018 11:30:0#))'...
%    'ORDER BY Annotations.[Start Time], Annotations.[End Time];'],'cellarray');
%mC = HT_DataAccess([], "query",...
%    ['SELECT Annotations.[Start Time], Annotations.[End Time], Annotations.[Channel ID]'...
%    'FROM Annotations'...
%    'WHERE (((Annotations.[Channel ID])=21) AND ((Annotations.[Created By]) Is Null) AND ((Annotations.DateTime)=#10/4/2018 11:30:0#))'...
%    'ORDER BY Annotations.[Start Time], Annotations.[End Time];'],'cellarray');
%mD = HT_DataAccess([], "query",...
%    ['SELECT Annotations.[Start Time], Annotations.[End Time], Annotations.[Channel ID]'...
%    'FROM Annotations'...
%    'WHERE (((Annotations.[Channel ID])=23) AND ((Annotations.[Created By]) Is Null) AND ((Annotations.DateTime)=#10/4/2018 11:30:0#))'...
%    'ORDER BY Annotations.[Start Time], Annotations.[End Time];'],'cellarray');


%Refine the matrix (remove timestamps that do not correspond with the
%other recordings by


end

%Refine the matrices from the files into lag matrices
%what we want the output to be for current time values.
function [lagMatrix, refinedMatrix] = findRefinedMatrix(mA,mB,mC, mD)

%Maximum distance in time from the reference point.

maxTDistance = 0.6;

%Define refinedMatrix as empty for now

refinedMatrix = [];

%Initialize i as 1 so that it will reference the first column in each
%of the provided matrices.

i = 1;

%The loop considers if the dataset was incomplete.
while (i <= length(mA) && i <= length(mB) && i <= length(mC) && i <= length(mD))
    
    
    columnN = [mA(i); mB(i); mC(i); mD(i)];
    
    %Find reference point of columnN
    
    ref = min(columnN);
    
    %Find a "truth table" named tTable that says where the condition
    %was met.
    
    tTable = columnN - ref > maxTDistance;
    
    
    %Average the truth values (0 and 1)
    
    avgMaxT = mean(tTable);
    
    %If the avg > 0 that means that the condition was met by at least
    %one of the values met the condition.
    if (avgMaxT > 0)
        
        %Find the row numbers of the smallest values
        
        %                rowNums = find(columnN < max(columnN));
        rowNums = find(tTable == 0);
        %Depending on which row numbers were chosen by the find
        %function, delete those row positions.
        
        if (find(rowNums == 1))
            mA(i) = [];
        end
        if (find(rowNums == 2))
            mB(i) = [];
        end
        if (find(rowNums == 3))
            mC(i) = [];
        end
        if (find(rowNums == 4))
            mD(i) = [];
        end
    else
        
        %If everything was fine with the column, append the columnN to
        %the refined matrix, then increment i.
        
        
        refinedMatrix(:,i) = columnN;
        lagMatrix(:,i) = columnN - ref;
        %                 lagMatrix(:,i) = columnN - ref;
        i = i+1;
    end
end
end

%Remove NaNs at the end of the matrix provided.
function mA = removeNaNSpots(mA)
nanSpots = find(isnan(mA) == 1);
for i=1:length(nanSpots)
    mA(nanSpots(1)) = [];
end
end

function [TP, TN, FP, FN] = compareData(DET, ANN)
%find TP
TP = 0;
TN = 0;
FN = 0;
FP = 0;
for incJ = 1:length(ANN)
    mTable = abs(DET-ANN(incJ));
    ref = min(mTable);
    %         disp("ref: "+ref);
    %         disp("ANN: "+ANN(incJ));
    %         disp("DET: "+DET(find(mTable == ref)));
    if ref < 0.2
        TP = TP + 1;
    end
end

FP = length(DET) - TP;
FN = length(ANN) - TP;
end

function [lagMatrix, refinedMatrix] = removeEchoes(lMatrix, rMatrix)
deltaRThresh = 0.4;
for i = 1:(length(lMatrix(1,:))/2 - 1)
    deltaR =  mean(abs(rMatrix(:,i+1) - rMatrix(:, i)));
    if deltaR < deltaRThresh
        lMatrix(:,i+1) = [];
        rMatrix(:,i+1) = [];
    end
end
lagMatrix = lMatrix;
refinedMatrix = rMatrix;
end

function [noEchoes] = removeEchoesSimple(DET)
i=1;
while( i <length(DET))
    if abs(DET(i) - DET(i+1)) < 0.7
        DET(i+1) = [];
    else
        i=i+1;
    end
end
noEchoes = DET;
end