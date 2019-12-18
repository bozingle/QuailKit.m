function varargout=HTdataAccess(handles,mode,varargin)
if nargin>3
    if ~any(strcmpi(mode,{'read','write','query'}))
        error('Wrong mode!');
    end
end
switch mode
    case 'prepare'
        handles=Prepare(handles);
        if nargout==0
            guidata(handles.Fig,handles);
        else
            varargout{1}=handles;
        end        
    case 'read'
        if length(varargin) > 0
            handles=Read(handles,varargin(1));
        else
            handles=Read(handles);
        end
        if nargout==0
            guidata(handles.Fig,handles);
        else
            varargout{1}=handles;
        end
    case 'write'
        Write(handles);
    case 'query'
        if nargout>0
            varargout{1}=Query(varargin{1},varargin{2});
        else
            Query(varargin{1},[],AudioNum);
        end
end

function Write(handles)
    handles.Path.Spectrograms = fullfile(handles.Path.Recordings, handles.RecordingSelected,"Spectrogram");
    mkdir(handles.Path.Spectrograms);
    Mics=handles.MicDataList{2,2};
    activeMics=find([Mics{:,2}]);
    for k=activeMics
        S=handles.Data.S(:,:,k);
        F=handles.Data.F;
        t=handles.Data.t(k,:);
        micName = split(string(Mics{k,3}),".");
        micName = micName(1);
        save(fullfile(handles.Path.Spectrograms,micName+".mat"),'S','F','t');
    end

function handles=Prepare(handles)
handles.MicDataList{2,2} = Query(handles);
Mics=handles.MicDataList{2,2};
if size(Mics,1) > 1
    set(handles.AudioName1,'String',Mics{1,3})
    set(handles.AudioName2,'String',Mics{2,3})
    set(handles.AudioName3,'String',Mics{3,3})
    set(handles.AudioName4,'String',Mics{4,3})
    
    filename= fullfile(handles.Path.Recordings,convertCharsToStrings(handles.RecordingSelected),"Mics",Mics{1,3});
    info=audioinfo(filename);
    l=info.TotalSamples;
    for k=2:size(Mics,1)
        filename= fullfile(handles.Path.Recordings,convertCharsToStrings(handles.RecordingSelected),"Mics",Mics{k,3});
        info=audioinfo(filename);
        l=min(l,info.TotalSamples);
        fs=info.SampleRate;
    end
    
    namespl = split(convertCharsToStrings(Mics{1,3}),["__","_","$","."]) %Mics{1,3}
    date = namespl(3)+" "+namespl(4);
    handles.Data.Date=datetime(date,'InputFormat','yyyyMMdd HHmmss');
    handles.Data.LoadRate = 120; % samples / 2 minutes
    ts=timeseries(zeros(l,size(Mics,1)));
    ts.TimeInfo.Units='seconds';
    handles.Data.fs=fs;
    handles.Data.TS=setuniformtime(ts,'StartTime',0,...
        'Interval',1/handles.Data.fs);
    handles.Data.TS.TimeInfo.StartDate=handles.Data.Date;
    handles.Data.Edges=1:10*handles.Data.fs:length(handles.Data.TS.Time);
    % if handles.Data.Edges(end)~=length(handles.Data.TS.Time)
    %     handles.Data.Edges=[handles.Data.Edges,length(handles.Data.TS.Time)];
    % end
    handles.Data.Bins=discretize(handles.Data.TS.Time,handles.Data.Edges);
end

if size(Mics,1) > 1

  handles.MicDataList{2,2} = Query(handles);
  Mics=handles.MicDataList{2,2};
  set(handles.AudioName1,'String',Mics{1,3})
  set(handles.AudioName2,'String',Mics{2,3})
  set(handles.AudioName3,'String',Mics{3,3})
  set(handles.AudioName4,'String',Mics{4,3})

  filename= fullfile(handles.Path.Recordings,convertCharsToStrings(handles.RecordingSelected),"Mics",Mics{1,3});
  info=audioinfo(filename);
  l=info.TotalSamples;
  for k=2:size(Mics,1)
      filename= fullfile(handles.Path.Recordings,convertCharsToStrings(handles.RecordingSelected),"Mics",Mics{k,3});
      info=audioinfo(filename);
      l=min(l,info.TotalSamples);
      fs=info.SampleRate;
 end
else
    l = 0;
end

namespl = split(convertCharsToStrings(Mics{1,3}),["__","_","$","."]) %Mics{1,3}
date = namespl(3)+" "+namespl(4);
handles.Data.Date=datetime(date,'InputFormat','yyyyMMdd HHmmss');
handles.Data.NumChannels = info.NumChannels;
ts=timeseries(zeros(fs*handles.Data.LoadRate,size(Mics,1)*info.NumChannels));
ts.TimeInfo.Units='seconds';
handles.Data.q = 0;
handles.Data.fs=fs;
handles.Data.TS=setuniformtime(ts,'StartTime',0,...
    'Interval',1/handles.Data.fs);
handles.Data.TS.TimeInfo.StartDate=handles.Data.Date;
handles.Data.Edges=1:10*handles.Data.fs:length(handles.Data.TS.Time);
% if handles.Data.Edges(end)~=length(handles.Data.TS.Time)
%     handles.Data.Edges=[handles.Data.Edges,length(handles.Data.TS.Time)];
% end
handles.Data.Bins=discretize(handles.Data.TS.Time,handles.Data.Edges);

function handles=Read(handles,varargin)
Mics=handles.MicDataList{2,2};
activeMics=find([Mics{:,2}]);
t = handles.Data.q;

if length(varargin) > 0
   t = varargin(1); 
end

handles.Data.TS=setuniformtime(handles.Data.TS,'StartTime',0,'Interval',1/handles.Data.fs);
handles.Data.TS.Time = handles.Data.TS.Time+(handles.Data.LoadRate*t)-10*(t ~= 0);

if (t == 0)
    handles.Data.interval = [1 handles.Data.LoadRate*handles.Data.fs];
else
    handles.Data.interval = handles.Data.interval(2) + [0 (handles.Data.LoadRate)*handles.Data.fs];
    clear handles.Data.S; clear handles.Data.t; clear handles.AudioFilePlay; clear handles.Data.TS.Data;
    clear handles.channel2Spec;
end

for k=activeMics
    filename= fullfile(handles.Path.Recordings,convertCharsToStrings(handles.RecordingSelected),"Mics",Mics{k,3}); %Mics{k,3}
    
    %t indicates which x minute interval to load.
    %[start end] -- in samples
    [raw,handles.Data.fs]=audioread(filename,handles.Data.interval);
    
    %handles.Data.TS.Data(1:size(raw,1),k)=zscore(raw(:,handles.AudioChannel)); 
    
    Fn = handles.Data.fs/2;
    Wp = 1000/Fn;
    Ws = 3000/Fn;
    raw = bandpass(raw,[Wp,Ws]);
%     Rp =1; 
%     Rs =150;
%     [n,Ws] = cheb2ord(Wp,Ws,Rp,Rs);
%     [z,p,j] = cheby2(n,Rs,[Wp,Ws],'bandpass');
%     [soslp,glp] = zp2sos(z,p,j);
%     raw = filtfilt(soslp,glp,raw);
    handles.Data.TS.Data(:,(handles.Data.NumChannels*(k-1)+1):handles.Data.NumChannels*k)=raw(1:handles.Data.LoadRate*handles.Data.fs,:); 
    
    handles.AudioFilePlay(:,k) = raw(1:handles.Data.LoadRate*handles.Data.fs,1);
    for i = 2:handles.Data.NumChannels
        handles.AudioFilePlay(:,k) = handles.AudioFilePlay(:,k) + raw(1:handles.Data.LoadRate*handles.Data.fs,i);
    end
end
handles.Data.Max=max(max(abs(handles.Data.TS.Data)));
for k=activeMics
    set(handles.Graphics.Plot(1,k,1),...
        'XData',decimate(decimate(decimate(handles.Data.TS.Time,10,'fir'),10,'fir'),10,'fir'),...
        'YData',zscore(decimate(decimate(decimate(zscore(handles.Data.TS.Data(:,k)),10,'fir'),10,'fir'),10,'fir')));
    temp=handles.Data.TS.TimeInfo.StartDate;
    D=datetime(year(temp),month(temp),day(temp),...
        hour(temp),minute(temp),second(temp)+handles.Data.TS.Time(1:300*handles.Data.fs:end));
    set(handles.Graphics.Axis(1,k),...
        'XTick',handles.Data.TS.Time(1):300:handles.Data.TS.Time(end),...
        'YTick',-10*ceil(handles.Data.Max/10):10:10*ceil(handles.Data.Max/10),...
        'XTickLabel',string(D,'HH:mm:ss'));
    D=datetime(year(temp),month(temp),day(temp),...
        hour(temp),minute(temp),second(temp)+handles.Data.TS.Time(1:handles.Data.fs:end));
    set(handles.Graphics.Axis(2,k),...
        'XTick',handles.Data.TS.Time(1):handles.Data.TS.Time(end),...
        'XTickLabel',string(D,'HH:mm:ss'));
    set(handles.Graphics.Patch(1,k,1),...
        'YData',2*handles.Data.Max*[-1,-1,1,1]);
end

function temp = Query(handles)
temp = {};

recordDir = fullfile(handles.Path.Recordings, handles.RecordingSelected);
mics = dir(fullfile(recordDir,"Mics"));

numMics = size(mics);
numMics = numMics(1);
j = 1
for i = 1:numMics
    micName = split(convertCharsToStrings(mics(i).name), "__");
    micName = micName(1);
    ext = split(micName, '.');
    ext = ext(end)
    if micName ~= '.' && micName ~= '..' && ext ~= 'txt'
        ind = find(ismember(handles.MicData(:,3),micName));
        temp{j,1} = handles.MicData(i,3)
        temp{j,2} = 1
        temp{j,3} = convertCharsToStrings(mics(i).name)
        j = j + 1
    end
end
