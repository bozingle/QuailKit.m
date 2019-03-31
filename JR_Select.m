function handles = JR_Select(handles, selection)
    handles.Data.Audio=audioplayer(handles.Data.TS.Data(...
    handles.Data.Edges(handles.Data.j):...
    handles.Data.Edges(handles.Data.j+1),selection),handles.Data.fs);
    handles.Data.Audio.TimerFcn={@TimerFcn, handles};
    handles.Data.Audio.TimerPeriod=0.05;
    handles.Data.F=handles.UserData.Freq(1):10:handles.UserData.Freq(2);
end