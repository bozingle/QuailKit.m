function varargout=HT_Compute(handles)
handles.Data.Audio=audioplayer(handles.Data.TS.Data(handles.Data.Edges(handles.Data.j):...
    handles.Data.Edges(handles.Data.j+1),1),handles.Data.fs); %workaround
handles.Data.Audio.TimerFcn={@TimerFcn, handles};
handles.Data.Audio.TimerPeriod=0.05;
handles.Data.F=handles.UserData.Freq(1):10:handles.UserData.Freq(2);
n=round(0.1*handles.Four_List.UserData{handles.Four_Pop.Value}{2,4}*handles.Data.fs);
Mics=handles.Two_Pop.UserData{2,2};
activeMics=find([Mics{:,2}]);
for k=activeMics
        if handles.Five_Pop.Value>1
            Template=importdata('Template_291.mat');
            SH_FindCalls(...
                handles.Data.TS.Data(handles.Data.Edges(handles.Data.j):...
                handles.Data.Edges(handles.Data.j+1),k),...
                handles.Data.F,handles.Data.fs,...
                handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)),n,Template,...
                handles.Five_List.UserData{3,2},...
                handles.Five_List.UserData{2,2},...
                handles.Five_List.UserData{4,2},...
                [handles.Graphics.Surf(2,k,1),handles.Graphics.Surf(2,k,2),handles.Graphics.Plot(3,k,1),...
                handles.Graphics.Plot(3,k,1),handles.Graphics.Scatter(3,k,2),handles.Graphics.Line(3,k)]);
            set(handles.Graphics.Axis(3,k).Children,'Visible','on');
        elseif handles.Four_Pop.Value>1
            flag=false;
            if handles.Mode.UserData==2
                try
                    temp=load([handles.Path.Results,'Spectrograms/',...
                        handles.Data.Name,'/',handles.Data.Name,...
                        num2str(handles.Data.TS.Time(handles.Data.Edges(handles.Data.j),:,k),...
                        '_%07.2f'),'.mat'],'F','S','t(k,:)');
                    handles.Data.F=temp.F;
                    handles.Data.S(:,:,k)=temp.S;
                    handles.Data.t(k,:)=temp.t(k,:);
                catch
                    warning('Nothing to load. Computing...');
                    flag=true;
                end
            end
            if flag || handles.Mode.UserData<2
                [handles.Data.S(:,:,k),handles.Data.t(k,:)]=HT_Spectrogram(...
                    handles.Data.TS.Data(handles.Data.Edges(handles.Data.j):...
                    handles.Data.Edges(handles.Data.j+1),k),n,handles.Data.F,handles.Data.fs,...
                    handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)),...
                    handles.Graphics.Surf(2,k,1));
            end
        else
            handles=HT_GUI(handles,'layout');
        end
        AnnSet=handles.Two_Pop.UserData{3,2}{[handles.Two_Pop.UserData{3,2}{:,2}],1};
        if ~strcmp(AnnSet,'Off')
            Ann=handles.Two_List.UserData.(AnnSet)(and(...
                handles.Two_List.UserData.(AnnSet)(:,1)>=handles.Data.t(k,1),...
                handles.Two_List.UserData.(AnnSet)(:,2)<=handles.Data.t(k,end)),:);
        else
            Ann=[];
        end
        HT_BBPlot(handles.Data.t(k,:),handles.Data.F,handles.Data.S(:,:,k),Ann,handles.Graphics.Surf(2,k,2),[0,0,0],...
            handles.Five_Pop.Value==1);
end
handles=HT_GUI(handles,'view','flag',false);
HT_DataAccess(handles,'write');
if nargout==0
    guidata(handles.Fig,handles);
else
    varargout{1}=handles;
end

function TimerFcn(audio,~,handles)
set(handles.Graphics.Line(1:2),'XData',handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)+...
    audio.CurrentSample*[1,1]));
guidata(handles.Fig,handles);