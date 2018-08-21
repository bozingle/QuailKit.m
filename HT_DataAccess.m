function varargout=HT_DataAccess(handles,mode,varargin)
if nargin>2
    if ~any(strcmpi(mode,{'read','write','query'}))
        error('Wrong mode!');
    end
end
switch mode
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
        varargout{1}=Query(varargin{:});
end

function handles=Read(handles)
Mics=handles.Two_Pop.UserData{2,2};
activeMics=find([Mics{:,2}]);
flag=true;
for k=activeMics
    filename=[handles.Path.Recordings,handles.Data.Name,'.',Mics{k,1},'.wav'];
    [raw,handles.Data.fs]=audioread(filename);
    temp=Query(['[',Mics{k,1},'_Annotated]'],'ID',handles.Data.Name);
    if temp{1}
        handles.UserData.AnnMode=1;
        handles.Two_List.UserData=load([handles.Path.Annotations,handles.Data.Name,'.',...
            Mics{k,1},'.mat']);
    else
        handles.UserData.AnnMode=0;
        handles.Two_List.UserData=[];
    end
    data2=zscore(raw);
    if flag
        data=data2;
        flag=false;
    else
        L=min(size(data,1),size(data2,1));
        data=[data(1:L,:),data2(1:L,:)];
    end
end
ts=timeseries(data);
ts.TimeInfo.Units='seconds';
handles.Data.TS=setuniformtime(ts,'StartTime',0,...
    'Interval',1/handles.Data.fs);
handles.Data.TS.TimeInfo.StartDate=...
    datetime(char(Query('Date','ID',handles.Data.Name)));
handles.Data.Edges=1:10*handles.Data.fs:length(handles.Data.TS.Time);
if handles.Data.Edges(end)~=length(handles.Data.TS.Time)
    handles.Data.Edges=[handles.Data.Edges,length(handles.Data.TS.Time)];
end
handles.Data.Bins=discretize(handles.Data.TS.Time,handles.Data.Edges);
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
    S=handles.Data.S;
    F=handles.Data.F;
    t=handles.Data.t;
    mkdir([handles.Path.Spectrograms],...
        handles.Data.Name);
    save([handles.Path.Spectrograms,...
        handles.Data.Name,'/',...
        handles.Data.Name,'.',handles.Data.Mic,...
        num2str(handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)),...
        '_%07.2f'),'.mat'],'S','F','t');
end

function data=Query(varargin)
prefs = setdbprefs('DataReturnFormat');
setdbprefs('DataReturnFormat','cellarray')
conn = database('Quail','','');
switch nargin
    case 1
        curs = exec(conn,['SELECT ',varargin{1},' FROM Recordings']);
    case 3
        curs = exec(conn,['SELECT ',varargin{1},...
            ' FROM Recordings WHERE ',varargin{2},' = ''',...
            varargin{3},'''']);
    otherwise
        error('Wrong number of query inputs!');
end
curs = fetch(curs);
data = curs.Data;
close(curs)
close(conn)
setdbprefs('DataReturnFormat',prefs)