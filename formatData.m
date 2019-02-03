function results = formatData(Date, SorE)
addpath(genpath(pwd));
%Get the Data
[channels,posTemp] = getData(Date,SorE);

%Refine the data
[lagMatrix,refinedMatrix] = findRefinedMatrix(channels);

[lagMatrix,refinedMatrix] = removeEchoes(lagMatrix, refinedMatrix);

mRef = [];
for i = 1: length(posTemp)
    mRef = [mRef;posTemp{i,1}(1:2) 0 posTemp{i,1}(3)];
end
results = [];
for i = 1:length(lagMatrix(1,:))
    mRef(:,3) = lagMatrix(:, i);
    location = HT_Localizer(mRef);
    results(i,:) = location(1:2);
end


end

%find lag matrix
function [finalChannels,posTemp] = getData(date,SorE)

    finalChannels = {};
    posTemp = {};
    DataStart = HT_DataAccess([],'query',...
                        "SELECT Recorders.[Recorder ID], [Detection(s)]."+SorE+" "+...
"FROM Recorders INNER JOIN ([Detection(s)] INNER JOIN Recordings ON [Detection(s)].[Recording ID] = Recordings.[Recording ID]) ON Recorders.[Recorder ID] = Recordings.[Recorder ID]"+...
"WHERE ((([Detection(s)].Created)>#"+date+"#))"+...
    "ORDER BY Recorders.[Recorder ID], [Detection(s)]."+SorE+";",'numeric');
%SELECT Recorders.[Recorder ID], [Detection(s)].Start
%FROM Recorders INNER JOIN ([Detection(s)] INNER JOIN Recordings ON [Detection(s)].[Recording ID] = Recordings.[Recording ID]) ON Recorders.[Recorder ID] = Recordings.[Recorder ID]
%WHERE ((([Detection(s)].Created)>#1/2/2019#))
%ORDER BY Recorders.[Recorder ID], [Detection(s)].Start;
    DataposTemp = HT_DataAccess([],'query',...
                            "SELECT Recorders.[Recorder ID], Statuses.LAT, Statuses.LON, Statuses.[TEMP(C)]"+...
    "FROM (Recorders INNER JOIN ([Detection(s)] INNER JOIN Recordings ON [Detection(s)].[Recording ID] = Recordings.[Recording ID]) ON Recorders.[Recorder ID] = Recordings.[Recorder ID]) INNER JOIN Statuses ON Recorders.[Recorder ID] = Statuses.[Recorder ID]"+...
    "WHERE ((([Detection(s)].Created)>#"+date+"#))"+...
    "ORDER BY Recorders.[Recorder ID], [Detection(s)]."+SorE+";",'numeric');

%SELECT Recorders.[Recorder ID], Statuses.LAT, Statuses.LON, Statuses.[TEMP(C)]
%FROM (Recorders INNER JOIN ([Detection(s)] INNER JOIN Recordings ON [Detection(s)].[Recording ID] = Recordings.[Recording ID]) ON Recorders.[Recorder ID] = Recordings.[Recorder ID]) INNER JOIN Statuses ON Recorders.[Recorder ID] = Statuses.[Recorder ID]
%WHERE ((([Detection(s)].Created)>#1/2/2019#))
%ORDER BY Recorders.[Recorder ID], [Detection(s)].Start;

    i = 1
    while(length(DataStart(:,1))>0)
        idx = find(DataStart(:,1) == DataStart(1,1));
        finalChannels{i,1} = DataStart(idx,2);
        DataStart(idx,:) = [];
        idx = find(DataposTemp(:,1) == DataposTemp(1,1));
        posTemp{i,1} = DataposTemp(idx,2:end);
        posTemp{i,1} = mean(posTemp{i,1});
        DataposTemp(idx, :) = [];
        i = i + 1;
    end
end

%Refine the matrices from the files into lag matrices
%what we want the output to be for current time values.
function [lagMatrix,refinedMatrix] = findRefinedMatrix(channels)

    %Maximum distance in time from the reference point.

    maxTDistance = 0.3;
    numChannels = length(channels);
    lengths = [];
    for j = 1:numChannels
        lengths(j) = length(channels{j,1});
    end
    
    lagMatrix = [];
    refinedMatrix = [];
    
    %Initialize i as 1 so that it will reference the first column in each
    %of the provided matrices.

    i = 1;

    %The loop considers if the dataset was incomplete.
    while ((sum([0 ~= lengths])/numChannels) >=1)
        columnN = [];
        for j = 1:numChannels
            try
            columnN(j) = channels{j,1}(1);
            catch
                disp("Stopped");
            end
        end
        columnN = columnN';
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

            rowNums = find(columnN < max(columnN));
            %rowNums = find(tTable == 0);
            %Depending on which row numbers were chosen by the find
            %function, delete those row positions.
            for j=1:length(rowNums)
                channels{rowNums(j),1}(1) = [];
            end
            for j = 1:numChannels
                lengths(j) = length(channels{j,1});
            end
        else

            %If everything was fine with the column, append the columnN to
            %the refined matrix, then increment i.
            lagMatrix(:,i) = columnN - ref;
            refinedMatrix(:,i) = columnN;
            
            for j = 1:numChannels
                channels{j,1}(1) = [];
            end
            i = i + 1;
        end
    end
end

function [lagMatrix,refinedMatrix] = removeEchoes(lMatrix, rMatrix)
deltaRThresh = 0.7;
i=1;
while( i <length(lMatrix))
    if abs(rMatrix(1,i) - rMatrix(1,i+1)) < deltaRThresh
        rMatrix(:,i+1) = [];
        lMatrix(:,i+1) = [];
    else
        i=i+1;
    end
end
lagMatrix = lMatrix;
refinedMatrix = rMatrix;
end
