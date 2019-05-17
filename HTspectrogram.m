function varargout=HT_Spectrogram(varargin)
if nargin==0
    varargout{1}={...
        'Title','Spectrogram';...
        'Scale',0.3};
else
    x=varargin{1};
    n=varargin{2};
    f=varargin{3};
    fs=varargin{4};
    t0=varargin{5};
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