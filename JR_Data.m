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
                obj = objFile.oclassdef JR_Data
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
            filepath = "";%Location where the processed file should be.
            if exist(filepath+"processed"+erase(recording,".wav")+".mat")
                objFile = load(filepath+"processed"+erase(recording,".wav")+".mat");
                obj = objFile.obj;
            else
                [obj,raw]=obj.read(recording);
                obj.scale=0.8;
                obj.audio = obj.process(raw);
                obj.spgram = obj.sp(filepath);
                %save(filepath+"processed"+erase(recording,".wav")+".mat", "obj");
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
            %end
        end
        
        function [obj,raw]=read(obj,recording)
            filepath = "..\..\..\Quail Call - Recordings\"+recording; %"..\..\..\Quail Call - Recordings\"+
            [raw,obj.fs]=audioread(filepath);
        end
        
        function obj=process(obj,raw)
            obj.audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function [obj,t]=sp(obj,filepath)
            f  = 0:10:10000;
            mult = 125;
            first = round(0.1*obj.scale*obj.fs);
            last = length(obj.audio.audio);
            obj.progress = 0;
            for (i = first*mult:first*mult:last)
                
                [s,~,t1] = spectrogram(obj.audio.audio((i-first*mult+1):i),round(0.1*obj.scale*obj.fs),...
                    round(0.8*0.1*obj.scale*obj.fs),f,obj.fs);
                
                s = db(abs(s'));
                iter = i/(first*mult);
                indc = length(s(:,1))*iter;
                indpr = indc - length(s(:,1)) + 1;
                
                %obj.spgram(indpr:indc, :) = tall(s);
                %t(indpr:indc) = tall(t1' + (iter - 1)*10);
                t1 = t1' + (iter - 1)*10;
                
                obj.progress = round((i/last)*10000)/100;
            end
            
            %t=t-t(1)+obj.start;
            
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

