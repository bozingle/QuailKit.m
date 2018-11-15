function varargout=HT_DataAccess(handles,mode,varargin)
if nargin>2
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
        handles=Read(handles);
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
            Query(varargin{1},[]);
        end
end

function handles=Prepare(handles)
temp=Query(...
    ['SELECT [Recorder], [Name] ',...
     'FROM Recordings ',...
     'WHERE [Started On] = #', handles.Data.Date,'#'],'cellarray');
handles.Two_Pop.UserData{2,2}=cell({});
for i = 1:size(temp,1)
    handles.Two_Pop.UserData{2,2}{i,1}=uint64(temp{i,1});
    handles.Two_Pop.UserData{2,2}{i,2}=false;
    handles.Two_Pop.UserData{2,2}{i,3}=temp{i,2}(1:14);
end
Mics=handles.Two_Pop.UserData{2,2};
l=0;
for k=1:size(Mics,1)
    filename=[handles.Path.Recordings,Mics{k,3}];
    info=audioinfo(filename);
    l=max(l,info.TotalSamples);
    fs=info.SampleRate;
end
ts=timeseries(zeros(l,size(Mics,1)));
ts.TimeInfo.Units='seconds';
handles.Data.fs=fs;
handles.Data.TS=setuniformtime(ts,'StartTime',0,...
    'Interval',1/handles.Data.fs);
handles.Data.TS.TimeInfo.StartDate=datetime(handles.Data.Date);
handles.Data.Edges=1:10*handles.Data.fs:length(handles.Data.TS.Time);
if handles.Data.Edges(end)~=length(handles.Data.TS.Time)
    handles.Data.Edges=[handles.Data.Edges,length(handles.Data.TS.Time)];
end
handles.Data.Bins=discretize(handles.Data.TS.Time,handles.Data.Edges);

function handles=Read(handles)
Mics=handles.Two_Pop.UserData{2,2};
activeMics=find([Mics{:,2}]);
for k=activeMics
    filename=[handles.Path.Recordings,Mics{k,3}];
    [raw,handles.Data.fs]=audioread(filename);
    handles.Data.TS.Data(1:size(raw,1),k)=zscore(raw(:,1));
end
handles.Data.Max=max(max(abs(handles.Data.TS.Data)));
for k=activeMics
    set(handles.Graphics.Plot(1,k,1),...
        'XData',decimate(decimate(decimate(handles.Data.TS.Time,10,'fir'),10,'fir'),10,'fir'),...
        'YData',zscore(decimate(decimate(decimate(handles.Data.TS.Data(:,k),10,'fir'),10,'fir'),10,'fir')));
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

function Write(handles)
if handles.Mode.UserData==1
    Mics=handles.Two_Pop.UserData{2,2};
    activeMics=find([Mics{:,2}]);
    for k=activeMics
        S=handles.Data.S(:,:,k);
        F=handles.Data.F;
        t=handles.Data.t(k,:);
        mkdir([handles.Path.Spectrograms],...
            sprintf('%010d',Mics{k,3}));
        save([handles.Path.Spectrograms,...
            sprintf('%010d',Mics{k,3}),'/',...
            sprintf('%010d',Mics{k,3}),...
            num2str(handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)),...
            '_%07.2f'),'.mat'],'S','F','t');
    end
end

function varargout=Query(SQL,format)
conn = database('Quail','','');
if isempty(format)
    try
        execute(conn,SQL);
    catch
        warning('Some error happened while wrtiting to database!');
    end
else
    varargout{1} = fetch(conn,SQL,'DataReturnFormat',format);
end
close(conn);