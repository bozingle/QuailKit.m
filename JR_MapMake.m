classdef JR_MapMake
    %JR_MAPMAKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        results
        window
        filepath
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
        
        function obj = mapMake(obj)
            ax = worldmap('USA');
            load coastlines;
            geoshow(coastlat, coastlon, "DisplayType", 'polygon', 'FaceColor','green');
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
    end
end

