classdef JR_Data
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        audio
        spgram
    end
    
    methods
        function obj = JR_Data(recording)
            %if processed data available on disk
                %read file
                %obj.audio = file.audio
                %obj.spgram = file.spgram
            %else
                %obj.audio = obj.process(raw);
                %obj.spgram = obj.sp(obj.audio);
                %file.audio = obj.audio
                %file.spgram = obj.spgram
                %write file
        end
        
        function [raw,fs]=read(recording)
            filepath=[app.state.path.recordings,recording];
            [raw,fs]=audioread(filepath);
        end
        
        function audio = process(raw)
            audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function [spgram,t]=sp(audio,fs,t0)
            f  = 0:10:10000;
            n=0.3;
            [spgram,~,t] = spectrogram(audio,n,round(0.8*n),f,fs);
            %interpolate s so the s's length would be the same as x's
            spgram=db(abs(spgram));
            t=t-t(1)+t0;
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
