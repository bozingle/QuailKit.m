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
        rawfs
        startRecTime
        audio
        spgramprops
        audioprops
        freqs
        t0
        overlap
        window
        data
    end
    
    methods
        function obj = JR_Data(audiopath, filepath, varargin)
            obj.filepath = filepath;
            obj.fileSetup(audiopath, varargin{1}, varargin{2}, varargin{3},0.8,obj.filepath);
        end
        
        function fileSetup(obj, audiopath, seconds, f, scale,overlap, varargin)
            if audiopath~=""
                [obj.audio,obj.audiofs]= audioread(audiopath);

            obj.scale = scale;            
            fileStartLoc = string(varargin{1,1});
            
            for i = 1:length(obj.audio(1,:))
                disp("Processing spectrogram");
                audioLength = length(obj.audio)/obj.audiofs;
                obj.progress = 0;
                fs=obj.audiofs;
                exists = 0;
                dt=obj.scale*(1-overlap);
                w=round(seconds/dt)*dt;
                for k = w:w:audioLength
                    interval = [k-w,k];
                    samples=round(max((1-overlap)*scale*fs/2+1,interval(1)*fs-scale*fs/2+1)):round(min(size(obj.audio,1),interval(2)*fs+scale*fs/2));
                    signal = obj.audio(samples,i); % This will produce the same exact interval as the asked interval (compnesation for window size)
                    [spgramA,t,props] = HTstpsd(signal,obj.audiofs,'scale',obj.scale,'overlap',overlap,'freqs',f);
                    obj.spgramprops=props;
                    spgramA = spgramA';
                    if ~exists
                        h5create(obj.filepath, "/c"+string(num2str(i))+"/spgram", [inf length(spgramA(1,:))], 'ChunkSize', [length(spgramA(:,1)) length(spgramA(1,:))]);
                        exists = 1;
                        Start = h5info(obj.filepath, "/c"+string(num2str(i))+"/spgram");
                        Start = Start.Dataspace.Size + 1;
                        temp=fieldnames(props);
                        for kk=1:size(temp,1)
                            h5writeatt(obj.filepath, "/c"+string(num2str(i))+"/spgram", temp{kk}, props.(temp{kk}));
                        end
                    end
                    
                    h5write(obj.filepath,"/c"+string(num2str(i))+"/spgram", spgramA,[Start(1) 1], [length(spgramA(:,1)) length(spgramA(1,:))]);
                    Start(1) = Start(1) + length(spgramA(:,1));
                    disp("Progress: " + obj.progress + "%");
                    obj.progress = round((k/audioLength)*10000)/100;
                end
                disp('Complete!');
                h5create(fileStartLoc, "/c"+string(num2str(i))+"/audio", [size(obj.audio,1) 1]);
                h5writeatt(fileStartLoc, "/c"+string(num2str(i))+"/audio", 'data', 'audio');
                h5writeatt(fileStartLoc, "/c"+string(num2str(i))+"/audio", 'fs', obj.audiofs);
                h5write(fileStartLoc, "/c"+string(num2str(i))+"/audio", obj.audio(:,i));
                
            end
            %                 obj.datetime = HT_DataAccess([],'query', [...
            %                     'SELECT an.start',...
            %                     ' FROM [QuailKit].[dbo].[audio_node] an'...
            %                     ' inner join [QuailKit].[dbo].[audio] a on an.audio_id = a.stream_id',...
            %                 char(" WHERE name = '"+RecordingName+"'")], 'cellarray');
            %                 obj.datetime=obj.datetime{1,1};
            h5writeatt(fileStartLoc, "/", 'props', '');
            %                obj.datetime = datetime(obj.datetime,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
            if length(varargin) == 2
                fileEndLoc = string(varargin{1,2});
                copyfile(fileStartLoc, fileEndLoc);
                delete(fileStartLoc);
            end
            end
            
        end
        
        function [s,f, t] = get(obj, first, last, propertyType,channel)
            propertyType = string(propertyType);
            testStr = char(propertyType);
            amountOfDS = h5info(obj.filepath, "/c"+channel+"/");
            amountOfDS = length(amountOfDS.Datasets);
            if testStr == "spgram" && str2num(channel) <= amountOfDS
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                info=h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                for kk=1:size(info.Attributes,1)
                    obj.(info.Attributes(kk).Name)=info.Attributes(kk).Value;
                end                
                startIn = floor(first*obj.spgramfs) + 1;
                endIn = floor(last*obj.spgramfs) + 1;
                startT=floor(first*obj.spgramfs)/obj.spgramfs;
                endT=floor(last*obj.spgramfs)/obj.spgramfs;
                
                
                s = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn-startIn+1 Size(2)]);
                s = s';
                f = obj.freqs(1):obj.freqs(3):obj.freqs(2);
                t = (startT:1/obj.spgramfs:endT)';
                
            elseif propertyType == "audio"
                f = [];
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                
                startIn = floor(first*obj.audiofs) + 1;
                endIn = floor(last*obj.audiofs) + 1;
                startT=floor(first*obj.audiofs)/obj.audiofs;
                endT=floor(last*obj.audiofs)/obj.audiofs;
                
                obj.audio = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn-startIn+1 1]);
                t = (startT:1/obj.audiofs:endT)';
                s = obj.audio;
            else
                error("Incorrect propertyType:"+newline+char(9)+"The propertyType "+propertyType+" does not correspond with the existing ones: spgram(+Number of spectrogram that exists in the dataset) and audio.");
            end
        end
        
        function emptyFile(obj, varargin)
            %Gets the name of the h5 file from obj.filepath for the temp h5 file.
            filename =  split(obj.filepath,'\');
            filename = filename(end);
            filename = string(filename{1,1});
            
            %Create new h5 file
            fileInfo = h5info(obj.filepath);
            for i = 1:length(fileInfo.Groups)
                h5create(filename,"/c"+i+"/spgram",fileInfo.Groups(i).Datasets(3).Dataspace.Size);
                h5writeatt(filename,"/c"+i+"/spgram", 'props', h5readatt(obj.filepath, "/c"+i+"/spgram", 'props'));
                h5create(filename,"/c"+i+"/audio",fileInfo.Groups(i).Datasets(1).Dataspace.Size);
                h5writeatt(filename,"/c"+i+"/audio", 'audiofs', h5readatt(obj.filepath, "/c"+i+"/audio", 'audiofs'));
                h5create(filename,"/c"+i+"/raw",fileInfo.Groups(i).Datasets(2).Dataspace.Size);
                h5writeatt(filename,"/",'props',h5readatt(obj.filepath, '/', 'props'));
            end
            %Put the datetime into props on the root of the file.
            h5writeatt("C:\Users\jreznick\Texas Tech University\Quail Call - Joel\QuailKit.m\"+filename, '/','props',fileInfo.Attributes.Value);
            
            %Copy data that we want to keep into the datasets.
            if length(varargin) > 0
                lex = string(varargin{1,1});
                i = 1;
                while (i <= length(varargin))
                    i = i + 1;
                    while i <= length(varargin)
                        lex = string(varargin{1,i});
                        if lex == "spgram"
                            segments = 2300;
                            for c = 1:length(fileInfo.Groups)
                                SizeDSSpgram = fileInfo.Groups(c).Datasets(3).Dataspace.Size;
                                sizeNewFile = [1 SizeDSSpgram(2)];
                                for j = 1:segments:floor(SizeDSSpgram(1)/segments)
                                    if j < SizeDSSpgram(1)
                                        spgram = h5read(obj.filepath,"/c"+c+"/"+lex+"/",[sizeNewFile(1) 1],[segments SizeDSSpgram(2)]);
                                        h5write(filename, "/c"+c+"/"+lex+"/", spgram, [sizeNewFile(1) 1],[segments SizeDSSpgram(2)]);
                                        sizeNewFile(1) = sizeNewFile(1) + j;
                                    end
                                end
                            end
                            clear spgram;
                        elseif lex == "audio"
                            for c = 1:length(fileInfo.Groups)
                                audio = h5read(obj.filepath,"/c"+c+"/"+lex+"/");
                                h5write(filename,"/c"+c+"/"+lex+"/", audio);
                            end
                            clear audio;
                        elseif lex == "raw"
                            for c = 1:length(fileInfo.Groups)
                                raw = h5read(obj.filepath,"/c"+c+"/"+lex+"/");
                                h5write(filename,"/c"+c+"/"+lex+"/", raw);
                            end
                            clear raw;
                        else
                            break;
                        end
                        i = i+1;
                    end
                end
            end
            
            %copy file into SQL folder
            copyfile(filename,obj.filepath);
            delete(filename)
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
