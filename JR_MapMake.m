classdef JR_MapMake
    %JR_MAPMAKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        results
        window
        filepath
        distance
        lonlim
        latlim
    end
    
    methods
        
        function obj = JR_MapMake(date)
            obj.filepath = ""+"MapMakeObj_"+replace(date, "/", "_");%Location where the processed file should be.
            if exist(obj.filepath)
                fileObj = load(obj.filepath+"/mapDet_"+replace(date, "/", "_")+".mat");
                obj = fileObj.obj;
            else
                mkdir(obj.filepath);
                obj.results = HT_DataAccess([],'query',...
                "SELECT [Activity(s)].[DateTime], [Activity(s)].[Seconds], [Activity(s)].[Latitude], [Activity(s)].[Longitude]"+...
                "FROM [Activity(s)]"+...
                "WHERE ((([Activity(s)].[DateTime])>#"+date+"#));", 'numeric');

                save(obj.filepath+"/mapDet_"+replace(date, "/", "_")+".mat", "obj");
            end
        end
        
        function obj = mapMake(obj, distance, unit)
            obj.distance = distance;%5 mile radius
            R = 1;
            if unit == 'miles'
                R = 3959;
            elseif unit == 'meters'
                R = 6.3781*(10.^6);
            elseif unit == 'kilometers'
                R = 6.3781*(10.^3);
            end
            
            %Find max long min long
            meanLong =  mean(obj.results(:,4));
            obj.lonlim = [meanLong - rad2deg(obj.distance/R) meanLong + rad2deg(obj.distance/R)];
            
            %Find max lat min lat
            meanLat = mean(obj.results(:,3));
            obj.latlim = [meanLat - rad2deg(obj.distance/R) meanLat + rad2deg(obj.distance/R)];
            
             ax = worldmap(obj.latlim, obj.lonlim);
             load coastlines;
             geoshow(coastlat, coastlon, 'DisplayType', 'polygon', 'FaceColor','green');
             states = shaperead('usastatelo', 'UseGeoCoords', true);
             faceColors = makesymbolspec('Polygon',...
                 {'INDEX', [1 numel(states)], 'FaceColor', ...
                 polcmap(numel(states))}); % NOTE - colors are random
             geoshow(ax, states, 'DisplayType', 'polygon', ...
               'SymbolSpec', faceColors)
           geoshow('worldlakes.shp', 'FaceColor', 'cyan');
           geoshow('worldrivers.shp', 'Color', 'blue');
           geoshow(obj.results(:,3), obj.results(:,4), 'DisplayType', 'multipoint', 'Marker', '.', 'Color', 'red');
        end
        
        function obj = newmapMake(obj,distance,unit)
            
            obj.distance = distance;
            R = 1;
            if unit == 'miles'
                R = 3959;%Radius of the earth in miles
            elseif unit == 'meters'
                R = 6.3781*(10.^6);
            elseif unit == 'kilometers'
                R = 6.3781*(10.^3);
            end
            
            
            %Find max long min long
            meanLong =  mean(obj.results(:,4));
            obj.lonlim = [meanLong - rad2deg(obj.distance/R) meanLong + rad2deg(obj.distance/R)];
            
            %Find max lat min lat
            meanLat = mean(obj.results(:,3));
            obj.latlim = [meanLat - rad2deg(d/R) meanLat + rad2deg(d/R)];
            
            webmap('World Imagery', 'WrapAround', true);
            %Display results
            wmmarker(obj.results(:,3), obj.results(:,4));
            wmlimits(obj.latlim, obj.lonlim);
            
            %geoshow(obj.results(:,3), obj.results(:,4), 'DisplayType', 'multipoint', 'Marker', '.', 'Color', 'red');
         
        end
    end
end