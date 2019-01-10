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
        filepath
        TAList
    end
    
    methods
        function obj = JR_Data(recording)
            obj.filepath = ""+erase(recording,".wav");%Location where the processed file should be.
            if exist(obj.filepath)
                fileObj = load(obj.filepath+"\processed"+erase(recording,".wav")+".mat");
                obj = fileObj.obj;
            else
                [obj,raw]=obj.read(recording);
                obj.scale=0.8;
                obj.audio = obj.process(raw);
                obj = obj.sp();
                save(obj.filepath+"\processed"+erase(recording,".wav")+".mat", "obj");
            end
        end
        
        function [obj,raw]=read(obj,recording)
            filepath = "..\..\..\Quail Call - Recordings\"+recording; %"..\..\..\Quail Call - Recordings\"+
            [raw,obj.fs]=audioread(filepath);
        end
        
        function obj=process(obj,raw)
            obj.audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function [obj]=sp(obj)
            mkdir(obj.filepath);
            f  = 0:10:10000;
            mult = 250;%125 for 10s intervals
            first = round(0.1*obj.scale*obj.fs);
            last = length(obj.audio.audio);
            obj.progress = 0;
            obj.TAList = [];
            for (i = first*mult:first*mult:last)
                
                [s,~,t1] = spectrogram(obj.audio.audio((i-first*mult+1):i),first,...
                    round(0.8*0.1*obj.scale*obj.fs),f,obj.fs);
                
                s = db(abs(s'));
                iter = i/(first*mult);
                t1 = t1' + (iter - 1)*20;
                sLength = length(s(1,:));
                spgramA = t1; 
                spgramA(:,2:sLength+1) = s;
                indc = length(s(:,1))*iter;
                indpr = indc - length(s(:,1))+1;
                
                spgramTA = tall(spgramA);
                mkdir(obj.filepath+"\TA"+t1(end));
                write(obj.filepath+"\TA"+t1(end)+"\TallA"+iter+"_*.mat",spgramTA,'FileType', 'mat');
                obj.TAList(iter) = t1(end);
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/last)*10000)/100;
            end
            disp("Complete!");
        end
        
        function A = get(obj, first, last)
            TASelectMax = abs(obj.TAList - last);
            minTA = min(TASelectMax);
            TASelectMax = find(TASelectMax == minTA);
            TASelectMin = abs(obj.TAList - first);
            minTA = min(TASelectMin);
            TASelectMin = find(TASelectMin == minTA);
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
