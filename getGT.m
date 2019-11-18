function GT = getGT(handles, k)
   GT = [];
   gtData = xlsread(fullfile(handles.Path.Recordings,handles.RecordingSelected,"GT",handles.RecordingSelected+".xlsx"),k);
   gtData2 = gtData(:,2);
   GT = gtData(find((gtData2 > (handles.Data.j-1)*10) == (gtData2 < handles.Data.j*10)==1),2:end);
   GT(:,3) = handles.UserData.Freq(1);
   GT(:,4) = handles.UserData.Freq(2);
end