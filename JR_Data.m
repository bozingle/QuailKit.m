classdef JR_Data
    %UNTITLED3 Summary of this class goes here
    %To invoke the constructor:
    %   obj = JR_Data(fileDir+fileName+audio extension(i.e ".wav"))
    % To retrieve intervals of time from memory
    %   obj.get(first, last)
    %first and last are in seconds. Any interval works.
    %first - the start of the interval to load from memory.
    %last - the end of the interval to load from memory.
    
    
    properties
        audio
        start
        fs
        spgram
        scale
        progress
        filepath
        finalTime
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
            spgramTA = tall([]);
            for (i = first*mult:first*mult:last)
                
                [s,~,t1] = spectrogram(obj.audio.audio((i-first*mult+1):i),first,...
                    round(0.8*0.1*obj.scale*obj.fs),f,obj.fs);
                
                s = db(abs(s'));
                iter = i/(first*mult);
                t1 = t1' + (iter - 1)*20;
                sLength = length(s(1,:));
                spgramA = t1; 
                spgramA(:,2:sLength+1) = s;
                spgramTA = tall([spgramTA;tall(spgramA)]);
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/last)*10000)/100;
                obj.finalTime = t1(end);
            end
            write(obj.filepath+"\TA",spgramTA,'FileType', 'mat');
            disp("Complete!");
        end
        
        function [s,t] = get(obj, first, last)
            %Loads file with the last second closest to the last value
            ds = datastore(obj.filepath + "\TA");
            data = tall(ds);
            idx = data(:,1) <= last;
            newData = data(idx,:);
            idx = newData(:,1) >= first;
            newData = gather(newData(idx,:));
            t = newData(:,1);
            s = newData(:,2:end);
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
