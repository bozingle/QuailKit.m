classdef JR_Data < datastore
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        audio
        start
        fs
        spgram
        scale
    end
    
    methods
        function obj = JR_Data(recording)
            %if processed data available on disk
                %read file
                %obj.audio = file.audio
                %obj.spgram = file.spgram
            %else
                %[obj,raw]=obj.read(obj,recording)
                %obj.audio = obj.process(obj,raw);
                %obj.spgram = obj.sp(obj);
                %file.audio = obj.audio
                %file.spgram = obj.spgram
                %write file
        end
        
        function [obj,raw]=read(obj,recording)
            filepath=[app.state.path.recordings,recording];
            [raw,obj.fs]=audioread(filepath);
        end
        
        function obj=process(obj,raw)
            obj.audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function [obj,t]=sp(obj)
            f  = 0:10:10000;
            [s,~,t] = spectrogram(obj.audio,obj.scale,round(0.8*obj.scale),f,obj.fs);
            %interpolate s so the s's length would be the same as x's
            obj.spgram=db(abs(s));
            t=t-t(1)+obj.start;
        end
        
        function display(obj,graphics,interval)
            set(graphics.axis_audio,...
                'XData', obj.audio.,...
                'YData', obj.audio.)
            set(graphics.axis_spectrogram,...
                'XData', obj.spectrogram.,...
                'YData', obj.spectrogram.,...
                'ZData', obj.spectrogram.)
        end
    end
end
