function varargout=HT_Spectrogram(varargin)
if nargin==0
    varargout{1}={...
        'Title','Spectrogram';...
        'Scale',0.3};
else
    x=varargin{1};
    x2=varargin{2};
    n=varargin{3};
    f=varargin{4};
    fs=varargin{5};
    t0=varargin{6};
    [s1,~,t] = spectrogram(x,n,round(0.8*n),f,fs);
    [s2,~,t] = spectrogram(x2,n,round(0.8*n),f,fs);
    s = abs(s1)+ abs(s2);
    s=db(s);
    t=t-t(1)+t0;
    varargout{1}=s;
    varargout{2}=t;
    if nargin>5 && ~isempty(varargin{7})
        set(varargin{7},...
            'XData',t,...
            'YData',f,...
            'ZData',s);
    end
end
end
