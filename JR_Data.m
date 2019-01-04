classdef JR_Data
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        audio
        start
        fs
        spgram
        scale
        progress
    end
    
    methods
        function obj = JR_Data(recording)
            if exist("processed"+erase(recording,".wav")+".mat")
                objFile = load("processed"+erase(recording,".wav")+".mat");
                obj = objFile.obj;
            else
                [obj,raw]=obj.read(recording);
                obj.scale=0.8;
                obj.process(raw);
                obj.sp();
                obj.audio = tall(obj.audio');
                obj.spgram = tall(obj.spgram');
                save("processed"+erase(recording,".wav")+".mat", "obj");
            end
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
            filepath="C:\Users\Tom\Texas Tech University\Quail Call - Shared\data\recordings\"+recording+".wav";
            [raw,obj.fs]=audioread(filepath);
        end
        
        function obj=process(obj,raw)
            obj.audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function [obj,t]=sp(obj)
            f  = 0:10:10000;
            [s,~,t] = spectrogram(obj.audio,round(0.1*obj.scale*obj.fs),...
                round(0.8*0.1*obj.scale*obj.fs),f,obj.fs);
            obj.spgram=db(abs(s'));
            t=t-t(1)+obj.start;
            t = tall(t');
        end
        
        function display(obj,graphics,interval)
           % set(graphics.axis_audio,...
           %     'XData', obj.audio.,...
           %     'YData', obj.audio.)
           % set(graphics.axis_spectrogram,...
           %     'XData', obj.spectrogram.,...
           %     'YData', obj.spectrogram.,...
           %     'ZData', obj.spectrogram.)
        end
    end
end
