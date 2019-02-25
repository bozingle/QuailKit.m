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
        audiofs
        scale
        progress
        spgramfs
        filepath
        finalTimeAudio
        finalTimeSpgram
    end
    
    methods
        function obj = JR_Data(recording)
            obj.filepath = ""+erase(recording,".wav");%Location where the processed file should be.
            if exist(obj.filepath)
                fileObj = load(obj.filepath+"\processed"+erase(recording,".wav")+".mat");
                obj = fileObj.obj;
            else
                obj.finalTimeSpgram = 0;
                obj.scale = 0.8;
                [obj,raw]=obj.read(recording);
                
                audio = obj.process(raw);
                
                obj = obj.sp(audio);
                obj = obj.formatAudio(audio);
                save(obj.filepath+"\processed"+erase(recording,".wav")+".mat", "obj");
            end
        end
        
        function [obj,raw]=read(obj,recording)
            filepath = "..\..\..\Quail Call - Recordings\"+recording; %"..\..\..\Quail Call - Recordings\"+
            [raw,obj.audiofs]=audioread(filepath);
        end
        
        function audio = process(obj,raw)
            audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function obj = formatAudio(obj, audio)
            audio = audio';
            audio(:,2) = audio;
            obj.finalTimeAudio = (length(audio)/obj.audiofs)
            audio(:,1) = ((1/obj.audiofs):(1/obj.audiofs):obj.finalTimeAudio)';
            h5create(obj.filepath+"\audio.hdf5", '/Dataset1', [length(audio(:,1)) length(audio(1,:))]);
            h5write(obj.filepath+"\audio.hdf5", '/Dataset1', audio);
        end
        
        function obj = sp(obj, audio)
            mkdir(obj.filepath);
            obj.spgramfs = (round(0.8*0.1*obj.scale*obj.audiofs));
            f  = 0:10:10000;
            seconds = 40;%Time interval
            mult = seconds*round(10/obj.scale);%multiplier needed to get 40s intervals
            first = round(0.1*obj.scale*obj.audiofs);
            last = length(audio);
            obj.progress = 0;
            disp("Processing spectrogram");
            for (i = first*mult:first*mult:last)
                [s,~,t] = spectrogram(audio((i-first*mult+1):i),first,...
                    obj.spgramfs,f,obj.audiofs);
                s = db(abs(s'));
                iter = i/(first*mult);
                t = t' + obj.finalTimeSpgram;
                if iter == 1
                    sLength = length(s(1,:));
                    spgramA = [0];
                    spgramA(1,2:sLength+1) = f;
                end
                spgramA(2:length(t)+1,1) = t; 
                spgramA(2:length(t)+1,2:sLength+1) = s;
                if ~exist(obj.filepath+"\spgram.hdf5")
                    h5create(obj.filepath+"\spgram.hdf5", '/Dataset1', [inf length(spgramA(1,:))], 'ChunkSize', [length(spgramA(:,1)) length(spgramA(1,:))]);
                end
                Size = h5info(obj.filepath+"\spgram.hdf5", '/Dataset1');
                Size = Size.Dataspace.Size;
                h5write(obj.filepath+"\spgram.hdf5", '/Dataset1', spgramA,[Size(1)+1 1], [length(spgramA(:,1)) length(spgramA(1,:))]);
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/last)*10000)/100;
                obj.finalTimeSpgram = t(end);
            end
            disp("Complete!");
        end
        
        function [s,t] = get(obj, first, last, propertyType)
            
            startIn = 0;
            endIn = 0;
            if propertyType == "spgram"
                Size = h5info(obj.filepath+"\spgram.hdf5", '/Dataset1');
                Size = Size.Dataspace.Size;
                T = (1/obj.spgramfs):(1/obj.spgramfs):last;
                startIn = find(T >= first);
                endIn = length(T) - startIn(1)
                startIn = startIn(1)
                
                spgram = h5read(obj.filepath+"\spgram.hdf5", '/Dataset1', [startIn 1], [endIn Size(2)]);
                t = spgram(:,1);
                s = spgram(:,2:end);
            elseif propertyType == "audio"
                Size = h5info(obj.filepath+"\audio.hdf5", '/Dataset1');
                Size = Size.Dataspace.Size;
                T = (1/obj.spgramfs):obj.audiofs:last;
                startIn = find(T == 0);
                endIn = length(T);
                audio = h5read(obj.filepath+"\audio.hdf5", '/Dataset1', [startIn 1], [endIn Size(2)]);
                t = audio(:,1);
                s = audio(:,2:end);
            else
                error("Incorrect propertyType:"+newline+char(9)+"The propertyType "+propertyType+" does not correspond with the existing ones: spgram and audio.");
            end
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
