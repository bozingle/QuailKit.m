
% --------------------------------------------------------- Initialization

function varargout = QuailKit(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @QuailKit_OpeningFcn, ...
    'gui_OutputFcn',  @QuailKit_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function QuailKit_OpeningFcn(hObject, eventdata, handles, varargin)
addpath(genpath(pwd));
handles.Path.Recordings='../../Quail Call - Recordings/';
handles.Path.Spectrograms='../../Quail Call - Shared/data/spectrograms/';
handles.Path.Results='../../Quail Call - Shared/results/';
handles=SetValues(handles);
handles=SetAxis(handles,true);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,true);
handles=Set34(handles);
handles.Graphics.Credits=Credits(...
    handles.Graphics.Watermark,...
    handles.Graphics.Color,true);
handles.Graphics.Watermark=HT_Transition(...
    handles.Graphics.Watermark,{'YLim'},...
    [1-handles.Graphics.Watermark.Position(4),0],...
    handles.UserData.Frames,handles);
handles=Wait(handles,'off');
handles.Data.j=1;
handles=SetLayout(handles,handles.UserData.Frames);
handles.output = hObject;
guidata(hObject,handles);

function varargout = QuailKit_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% ------------------------------------------------------- Figure Callbacks

function Fig_SizeChangedFcn(hObject, eventdata, handles)
handles=SetLayout(handles,2);
guidata(handles.Fig,handles);

function Fig_KeyReleaseFcn(hObject, eventdata, handles)
handles = HT_Compute(handles);
handles=SetView(handles,false);
guidata(handles.Fig,handles);

function Fig_KeyPressFcn(hObject, eventdata, handles)
switch eventdata.Key
    case 'rightarrow'
        handles.Data.j=min(handles.Data.j+1,length(handles.Data.Bins)-1);
    case 'leftarrow'
        handles.Data.j=max(1,handles.Data.j-1);
    case 'downarrow'
        handles.Data.j=min(handles.Data.j+10,length(handles.Data.Bins)-1);
    case 'uparrow'
        handles.Data.j=max(1,handles.Data.j-10);
end
if ismember(eventdata.Key,{'rightarrow','leftarrow','downarrow','uparrow'})
    set(handles.Graphics.Axis(3).Children,...
        'Visible','off');
    set(handles.Graphics.Axis(2).Children,...
        'Visible','off');
    handles.Graphics.Patch(1).XData=handles.Data.TS.Time(...
        [handles.Data.Edges(handles.Data.j),...
        handles.Data.Edges(handles.Data.j+1),...
        handles.Data.Edges(handles.Data.j+1),...
        handles.Data.Edges(handles.Data.j)]);
    set(handles.Graphics.Axis(2),...
        'XLim',handles.Graphics.Patch(1).XData(1:2));
    guidata(hObject,handles);
end

% ---------------------------------------------------- GroupPlay Callbacks

function Clear_Callback(hObject, eventdata, handles)
handles.Data.j=1;
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

function Reset_Callback(hObject, eventdata, handles)
handles=SetAxis(handles,initialize);
handles=Wait(handles,'off');
handles.Data.j=1;
handles=SetLayout(handles,handles.UserData.Frames);
handles=HT_DataAccess(handles,'read');
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

function Skip_Callback(hObject, eventdata, handles)
hObject.UserData=1;
if handles.Data.j<length(handles.Data.Bins)-1
    handles.Data.j=handles.Data.j+1;
else
    handles.Data.j=1;
end
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

function Next_Callback(hObject, eventdata, handles)
handles.Data.j=1;
handles.One_Pop.Value=handles.One_Pop.Value+1;
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
handles=SetLayout(handles);
handles=HT_DataAccess(handles,'read');
guidata(hObject,handles);

function PlayMode_Callback(hObject, eventdata, handles)
handles.PlayMode.UserData=rem(handles.PlayMode.UserData+1,4);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
handles=SetLayout(handles);
guidata(hObject,handles);

function Mode_Callback(hObject, eventdata, handles)
handles.Mode.UserData=rem(handles.Mode.UserData+1,3);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
handles=SetLayout(handles);
guidata(hObject,handles);

function Debug_Callback(hObject, eventdata, handles)
handles.Debug.UserData=rem(handles.Debug.UserData+1,2);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
handles=SetLayout(handles);
guidata(hObject,handles);

function Previous_Callback(hObject, eventdata, handles)
if handles.One_Pop.Value>2
    handles.One_Pop.Value=handles.One_Pop.Value-1;
    handles=SetGraphics_All(handles);
    handles=SetToolbar(handles);
    handles=SetPlay(handles);
    handles=Set12(handles,false);
    handles=Set34(handles);
    handles=Wait(handles,'off');
    handles=SetLayout(handles);
    handles.Data.j=1;
    handles=HT_DataAccess(handles,'read');
    guidata(hObject,handles);    
end

function Back_Callback(hObject, eventdata, handles)
hObject.UserData=1;
if handles.Data.j>1
    handles.Data.j=handles.Data.j-1;
else
    handles.Data.j=length(handles.Data.Bins);
end
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

function QueueMode_Callback(hObject, eventdata, handles)
handles.QueueMode.UserData=rem(handles.QueueMode.UserData+1,2);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
handles=SetLayout(handles);
guidata(hObject,handles);

function Play_Callback(hObject, eventdata, handles)
if handles.Data.Audio.isplaying
    handles.Data.Audio.pause;
elseif hObject.UserData==1
    hObject.UserData=0;
else
    hObject.UserData=1;
    hObject.CData=handles.icons.Pause;
    flag=false;
    while hObject.UserData==1
        if handles.PlayMode.UserData==0
            handles.Skip.UserData=0;
            handles.Back.UserData=0;
            hObject.UserData=0;
        else
            if flag
                if handles.Data.j<length(handles.Data.Edges)-2
                    handles.Data.j=handles.Data.j+1;
                    if handles.PlayMode.UserData==1
                        hObject.UserData=0;
                    end
                elseif handles.PlayMode.UserData==3
                    handles.Data.j=1;
                elseif handles.QueueMode.Value==1
                    Next_Callback(handles.Next, eventdata, handles);
                    handles.Skip.UserData=0;
                end
                handles=HT_Compute(handles);
                handles=SetView(handles,false);
            end
        end
        if strcmp(handles.Sound.State,'on')
            handles.Data.Audio.resume;
            set(handles.Graphics.Line(1:2),'Visible','on');
            waitfor(handles.Data.Audio,'Running','off');
            set(handles.Graphics.Line(1:2),'Visible','off');
        end
        flag=true;
    end
end
hObject.UserData=0;
hObject.CData=handles.icons.Play;
guidata(hObject,handles);

% ----------------------------------------------------- Group12 Callbacks

function One_Pop_Callback(hObject, eventdata, handles)
handles=Wait(handles,'on');
handles=Set12(handles,false);
handles.One_List.Value=1;
handles=HT_DataAccess(handles,'read');
handles=HT_Compute(handles);
handles=SetView(handles,false);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
guidata(hObject,handles);

function One_List_Callback(hObject, eventdata, handles)
handles=Wait(handles,'on');
handles=Set12(handles,false);
handles=HT_DataAccess(handles,'prepare');
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
guidata(hObject,handles);

function Two_Pop_Callback(hObject, eventdata, handles)
handles.Two_List.Value = 1;
handles=Set12(handles,false);
guidata(hObject,handles);

function Two_List_Callback(hObject, eventdata, handles)
value=handles.Two_Pop.UserData{handles.Two_Pop.Value,2}{hObject.Value,2};
switch class(value)
    case 'logical'
        handles.Two_Slide.Value=double(value);
    case 'double'
        handles.Two_Slide.Value=value;
end
handles=Set12(handles,false);
guidata(hObject,handles);

function Two_Slide_Callback(hObject, eventdata, handles)
handles=Wait(handles,'on');
switch hObject.Style
    case 'slider'
        temp=hObject.Value;
    case 'checkbox'
        temp=logical(hObject.Value);
end
handles.Two_Pop.UserData{handles.Two_Pop.Value,2}...
    {handles.Two_List.Value,2}=temp;
handles=Set12(handles,false);
handles=SetLayout(handles,handles.UserData.Frames);
handles=HT_DataAccess(handles,'read');
handles=HT_Compute(handles);
handles=SetView(handles,false);
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
guidata(hObject,handles);

% ------------------------------------------------------ Group45 Callbacks

function Four_Pop_Callback(hObject, eventdata, handles)
handles = Set34(handles);
handles=HT_Compute(handles);
handles=SetView(handles,false);
handles=SetLayout(handles);
guidata(hObject,handles);

function Four_List_Callback(hObject, eventdata, handles)
handles = Set34(handles);
value=hObject.UserData{handles.Four_Pop.Value}{2,hObject.Value};
switch class(value)
    case 'logical'
        handles.Four_Slide.Value=double(value);
    case 'double'
        handles.Four_Slide.Value=value;
end
guidata(hObject,handles);

function Four_Slide_Callback(hObject, eventdata, handles)
switch hObject.Style
    case 'slider'
        temp=hObject.Value;
    case 'checkbox'
        temp=logical(hObject.Value);
end
handles.Four_List.UserData{handles.Four_Pop.Value}...
    {2,handles.Four_List.Value}=temp;
handles = Set34(handles);
handles=SetLayout(handles,handles.UserData.Frames);
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

function Five_Pop_Callback(hObject, eventdata, handles)
handles = Set34(handles);
handles=SetLayout(handles,handles.UserData.Frames);
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

function Five_List_Callback(hObject, eventdata, handles)
handles = Set34(handles);
handles=SetLayout(handles,handles.UserData.Frames);
value=hObject.UserData{hObject.Value,2};
switch class(value)
    case 'logical'
        handles.Five_Slide.Value=double(value);
    case 'double'
        handles.Five_Slide.Value=value;
end
guidata(hObject,handles);

function Five_Slide_Callback(hObject, eventdata, handles)
switch hObject.Style
    case 'slider'
        temp=hObject.Value;
    case 'checkbox'
        temp=logical(hObject.Value);
end
handles.Five_List.UserData{handles.Five_List.Value,2}=temp;
handles = Set34(handles);
handles=SetLayout(handles);
handles=HT_Compute(handles);
handles=SetView(handles,false);
guidata(hObject,handles);

% ------------------------------------------------------ Toolbar Callbacks

function HT_OffCallback(hObject, eventdata, handles)
handles=Wait(handles,'on');
handles=SetGraphics_All(handles);
handles=SetToolbar(handles);
handles=SetPlay(handles);
handles=Set12(handles,false);
handles=Set34(handles);
handles=Wait(handles,'off');
guidata(hObject,handles);

function HT_OnCallback(hObject, eventdata, handles)
handles=Wait(handles,'on');
handles.Graphics.Watermark=...
    HT_Transition(handles.Graphics.Watermark,{'YLim'},...
    [1-handles.Graphics.Watermark.Position(4),0],...
    handles.UserData.Frames,handles);
set(handles.HT,'Enable','on');
guidata(hObject,handles);

function Zoom_ClickedCallback(hObject, eventdata, handles)
hObject=Feedback(hObject);
drawnow
handles.UserData.ZoomMode=rem(handles.UserData.ZoomMode+1,4);
SetView(handles,handles.UserData.Frames);
hObject=Feedback(hObject);
guidata(hObject,handles);

function Theme_ClickedCallback(hObject, eventdata, handles)
hObject=Feedback(hObject);
drawnow
hObject.UserData=max(1,rem(hObject.UserData+1,14));
handles=SetGraphics_All(handles);
handles=SetLayout(handles,handles.UserData.Frames);
handles=SetToolbar(handles);
guidata(hObject,handles);

function Display_ClickedCallback(hObject, eventdata, handles)
hObject=Feedback(hObject);
drawnow
handles.DisplayMode=rem(handles.DisplayMode+1,4);
handles=SetLayout(handles,handles.UserData.Frames);
hObject=Feedback(hObject);
guidata(hObject,handles);

function InvertColors_ClickedCallback(hObject, eventdata, handles)
handles=SetGraphics_All(handles);
handles=SetLayout(handles,handles.UserData.Frames);
handles=SetToolbar(handles);
guidata(hObject,handles);

function Animation_ClickedCallback(hObject, eventdata, handles)
handles=SetToolbar(handles);
guidata(hObject,handles);

function Sound_ClickedCallback(hObject, eventdata, handles)
handles=SetToolbar(handles);
guidata(hObject,handles);

function Save_ClickedCallback(hObject, eventdata, handles)
hObject=Feedback(hObject);
pause(0.5);
Feedback(hObject);
guidata(hObject,handles);

function Capture_OnCallback(hObject, eventdata, handles)
handles.UserData.HiddenFig=...
    figure('Visible','off','Position',[0,0,1008,504],'Unit','normalized');
colormap(handles.UserData.HiddenFig,handles.Graphics.Colormap);
path=[handles.Path.Results,'Videos\',handles.Data.Date,'\'];
mkdir(path);
handles.UserData.Video = VideoWriter(...
    sprintf('%s%s.mp4',...
    path,[handles.Data.Date,'.',...
    num2str(handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)),...
    '_%07.2f')]));
open(handles.UserData.Video);
handles=SetToolbar(handles);
guidata(hObject,handles);

function Capture_OffCallback(hObject, eventdata, handles)
close(handles.UserData.Video);
delete(handles.UserData.HiddenFig);
handles=SetToolbar(handles);
guidata(hObject,handles);

