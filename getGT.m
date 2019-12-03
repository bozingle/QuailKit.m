function GT = getGT(handles, k)
   GT = [];
   micFileName = split(handles.Two_Pop.UserData{2,2}{k,3}, '.');
   micFileName = micFileName(1);
   if exist(fullfile(handles.Path.Recordings,handles.RecordingSelected,"GT",handles.RecordingSelected+".xlsx"))
       gtData = xlsread(fullfile(handles.Path.Recordings,handles.RecordingSelected,"GT",handles.RecordingSelected+".xlsx"),k);
       gtData2 = gtData(:,2);
       GT = gtData(find((gtData2 > (handles.Data.j-1)*10) == (gtData2 < handles.Data.j*10)==1),2:end);       
   elseif exist(fullfile(handles.Path.Recordings,handles.RecordingSelected,"GT",micFileName+".Table.1.selections.txt")) == 2
       gtData = table2cell(readtable(fullfile(handles.Path.Recordings,handles.RecordingSelected,"GT",micFileName+".Table.1.selections.txt")));
       gtData2 = cell2mat(gtData(:,4));
       GT = cell2mat(gtData(find((gtData2 > (handles.Data.j-1)*10) == (gtData2 < handles.Data.j*10)==1),4:end));
   end
   if ~isempty(GT)
       GT(:,3) = handles.UserData.Freq(1);
       GT(:,4) = handles.UserData.Freq(2);
   end
end