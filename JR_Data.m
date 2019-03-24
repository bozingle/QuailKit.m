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
        scale
        datetime
        progress
        audiofs
        spgramfs
        filepath
        finalTimeAudio
        finalTimeSpgram
    end
    
    methods
        function obj = JR_Data(audiopath, filepath, varargin)
            obj.filepath = filepath;
            if exist(obj.filepath)
                attVals = h5readatt(obj.filepath, '/c1/spgram', 'props');
                obj.spgramfs = attVals(1);
                obj.finalTimeSpgram = attVals(2);
                obj.scale = attVals(5);
                attVals = h5readatt(obj.filepath, '/c1/audio', 'audiofs');
                obj.audiofs = attVals(1);
                attVals = h5readatt(obj.filepath, '/', 'props');
                obj.datetime = attVals;
            else
                obj.datetime = "";
                obj.finalTimeSpgram = 0;
                obj.scale = varargin{1,3};
                [obj,raw]=obj.read(audiopath);
                audio = obj.process(raw);
                for i = 1:length(audio(1,:))
                    obj = obj.sp(audio(:,i), varargin{1,1}, varargin{1,2},i);
                    h5create(obj.filepath, "/c"+string(num2str(i))+"/raw", [length(raw(:,1)) 1]);
                    h5write(obj.filepath, "/c"+string(num2str(i))+"/raw", raw(:,i));
                    obj = obj.formatAudio(audio(:,i)',i);
                end
                h5writeatt(obj.filepath, "/", 'props', obj.datetime);
                
                
            end
        end
        
        function [obj,raw]=read(obj,audiopath)
            [raw,obj.audiofs]=audioread(audiopath);
        end
        
        function audio = process(obj,raw)
            audio=zscore(raw);
        end
        
        function obj = formatAudio(obj, audio,i)
            audio = audio';
            h5create(obj.filepath, "/c"+string(num2str(i))+"/audio", [length(audio(:,1)) length(audio(1,:))]);
            h5writeatt(obj.filepath, "/c"+string(num2str(i))+"/audio", "audiofs", obj.audiofs);
            h5write(obj.filepath, "/c"+string(num2str(i))+"/audio", audio);
        end
        
        function obj = sp(obj, audio, seconds, f,index)
            noverlap = (round(0.8*0.1*obj.scale*obj.audiofs));
            mult = seconds*obj.audiofs;%multiplier needed to get 40s intervals
            window = round(0.1*obj.scale*obj.audiofs);
            audioLength = length(audio);
            obj.progress = 0;
            disp("Processing spectrogram");
            Size = [];
            exists = 0;
            for i = mult:mult:audioLength
                [s,~,t] = spectrogram(audio((i-mult+1):i),window,...
                    noverlap,f,obj.audiofs);
                spgramA = db(abs(s'));
                if ~exists
                    obj.spgramfs = 1/abs(t(1) - t(2));
                    h5create(obj.filepath, "/c"+string(num2str(index))+"/spgram", [inf length(spgramA(1,:))], 'ChunkSize', [length(spgramA(:,1)) length(spgramA(1,:))]);
                    exists = 1;
                end
                Size = h5info(obj.filepath, "/c"+string(num2str(index))+"/spgram");
                Size = Size.Dataspace.Size;
                h5write(obj.filepath,"/c"+string(num2str(index))+"/spgram", spgramA,[Size(1)+1 1], [length(spgramA(:,1)) length(spgramA(1,:))]);
                Size(1) = Size(1) + length(spgramA(:,1));
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/audioLength)*10000)/100;
                obj.finalTimeSpgram = t(end);
            end
            h5writeatt(obj.filepath, "/c"+string(num2str(index))+"/spgram", 'props', [obj.spgramfs obj.finalTimeSpgram f(1) f(end) obj.scale]);
            
            disp("Complete!");
        end
        
        function [s,f, t] = get(obj, first, last, propertyType,channel)
            propertyType = string(propertyType);
            startIn = 0;
            endIn = 0;
            s = [];
            t = [];
            testStr = char(propertyType);
            amountOfDS = h5info(obj.filepath, "/c"+channel+"/");
            amountOfDS = length(amountOfDS.Datasets);
            if testStr == "spgram" && str2num(channel) <= amountOfDS
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                
                attVals = h5readatt(obj.filepath, "/c"+channel+"/"+propertyType, 'props');
                obj.spgramfs = attVals(1);
                obj.finalTimeSpgram = attVals(2);
                obj.scale = attVals(5);
                
                startIn = first*obj.spgramfs + 1;
                endIn = last*obj.spgramfs-startIn+1;
                
                attVals = h5readatt(obj.filepath, "/c"+channel+"/"+propertyType, 'props');
                fStart = attVals(3);
                fEnd = attVals(4);
                
                step = (fEnd-fStart)/1000;
                spgram = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn Size(2)]);
                
                f = fStart:step:fEnd;
                t = (first:1/obj.spgramfs:last)';
                t = t(1:length(spgram(:,1)));
                s = spgram;
            elseif propertyType == "audio"
                f = [];
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                startIn = first*obj.audiofs + 1;
                endIn = last*obj.audiofs-startIn+1;
                audio = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn 1]);
                t = (first:1/obj.audiofs:last)';
                t = t(1:length(audio(:,1)));
                s = audio;
            else
                error("Incorrect propertyType:"+newline+char(9)+"The propertyType "+propertyType+" does not correspond with the existing ones: spgram(+Number of spectrogram that exists in the dataset) and audio.");
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
