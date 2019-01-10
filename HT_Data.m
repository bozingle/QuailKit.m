classdef HT_Data
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        processed
        spectrogram
    end
    
    methods
        function obj = HT_Data(recording)
            obj.processed   = HT_Process(raw);
            obj.spectrogram = HT_Spectrogram(raw);
        end
        
        function outputArg = method1(obj,inputArg)
            outputArg = obj.Property1 + inputArg;
        end
    end
end

[handles.Data.S(:,:,k),handles.Data.t(k,:)]=HT_Spectrogram(...
handles.Data.TS.Data(handles.Data.Edges(handles.Data.j):...
handles.Data.Edges(handles.Data.j+1),k),n,...
handles.Data.F,...
handles.Data.fs,...
handles.Data.TS.Time(handles.Data.Edges(handles.Data.j)),...
handles.Graphics.Surf(2,k,1));

function varargout=HT_Spectrogram(varargin)
if nargin == 0
    varargout{1}={...
        'Title','Spectrogram';...
        'Scale',0.3};
else
    x  = varargin{1};
    n  = varargin{2};
    f  = varargin{3};
    fs = varargin{4};
    t0 = varargin{5};
    
    [s,~,t] = spectrogram(x,n,round(0.8*n),f,fs);

    s=db(abs(s));
    t=t-t(1)+t0;
    varargout{1}=s;
    varargout{2}=t;
    if nargin>5 && ~isempty(varargin{6})
        set(varargin{6},...
            'XData',t,...
            'YData',f,...
            'ZData',s);
    end
end
end