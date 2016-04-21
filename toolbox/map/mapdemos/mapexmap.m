%% Creating Maps Using MAPSHOW (X,Y)
% This gallery illustrates the range of maps that you can create using
% |mapshow|.
%
% Copyright 1996-2003 The MathWorks, Inc.

%% Map 1: Roads - a geographic data structure
% Display the |roads| geographic data structure.

roads = shaperead('concord_roads.shp');
figure
mapshow(roads);

%% Map 2: Roads with custom LineStyle
% Display the roads shape and change the LineStyle.

figure
mapshow('concord_roads.shp','LineStyle',':');

%% Map 3: Roads with SymbolSpec 
% Display the roads shape, and render using a SymbolSpec.

%% 
% To learn about the |concord_roads.shp| dataset, read its associated
% |concord_roads.txt| metadata file which describes the attributes.

type concord_roads.txt

%%
% Query the attributes in this roads file.
roads = shaperead('concord_roads.shp')

%%
% Find out how many roads fall in each CLASS.
for i = 1:7
   N_CLASS(i) = sum([roads(:).CLASS]==i);
end
N_CLASS

%%
% Find out how many roads fall in each ADMIN_TYPE.
for i = 0:3
   N_ADMIN_TYPE(i+1) = sum([roads(:).ADMIN_TYPE]==i);
end
N_ADMIN_TYPE

%%
% Notice that there are no roads in this file that are CLASS 1 or 7, and
% the roads are either ADMIN_TYPE 0 or 3.
%
% Create a SymbolSpec to: 
%
% * Color local roads (ADMIN_TYPE=0) cyan, state roads (ADMIN_TYPE=3) red.
% * Hide very minor roads (CLASS=6).
% * Make all roads that are major or larger (CLASS=1-4) have a LineWidth of 2.
%

roadspec = makesymbolspec('Line',...
                          {'ADMIN_TYPE',0,'Color','cyan'}, ...
                          {'ADMIN_TYPE',3,'Color','red'},...
                          {'CLASS',6,'Visible','off'},...
                          {'CLASS',[1 4],'LineWidth',2});
figure
mapshow('concord_roads.shp','SymbolSpec',roadspec);

%% Map 4: Roads with SymbolSpec, override defaults
% Override default properties of the SymbolSpec.

roadspec = makesymbolspec('Line',...
                          {'ADMIN_TYPE',0,'Color','c'}, ...
                          {'ADMIN_TYPE',3,'Color','r'},...
                          {'CLASS',6,'Visible','off'},...
                          {'CLASS',[1 4],'LineWidth',2});
figure
mapshow('concord_roads.shp','SymbolSpec',roadspec,'DefaultColor','b', ...
        'DefaultLineStyle','-.');

%% Map 5: Roads, override SymbolSpec 
% Override a graphics property of the SymbolSpec.

roadspec = makesymbolspec('Line',...
                          {'ADMIN_TYPE',0,'Color','c'}, ...
                          {'ADMIN_TYPE',3,'Color','r'},...
                          {'CLASS',6,'Visible','off'},...
                          {'CLASS',[1 4],'LineWidth',2});
figure
h = mapshow('concord_roads.shp','SymbolSpec',roadspec,'Color','b');

%% Map 6: Waterways and roads in one map
% Display the waterways and roads shapes in one figure.

figure
mapshow('concord_roads.shp');
mapshow(gca,'concord_hydro_line.shp','Color','b');
mapshow(gca,'concord_hydro_area.shp','FaceColor','b','EdgeColor','b');

%% Map 7: Mount Washingtion SDTS digital elevation model

%%
% View the Mount Washington terrain data as a mesh.
figure
h = mapshow('9129CATD.ddf','DisplayType','mesh');
Z = get(h,'ZData');
colormap(demcmap(Z))

%%
% View the Mount Washington terrain data as a surface.
figure
mapshow('9129CATD.ddf');
colormap(demcmap(Z))
view(3); % View  as a 3-d surface
axis normal;

%% Map 8: Mount Washington and Mount Dartmouth on one map with contours
% Display the grid and contour lines of Mount Washington and Mount
% Dartmouth.

figure
[Z_W, R_W] = arcgridread('MtWashington-ft.grd');
[Z_D, R_D] = arcgridread('MountDartmouth-ft.grd');
mapshow(Z_W, R_W,'DisplayType','surface');
hold on
mapshow(gca,Z_W, R_W,'DisplayType','contour');
mapshow(gca,Z_D, R_D, 'DisplayType','surface');
mapshow(gca,Z_D, R_D,'DisplayType','contour');
colormap(demcmap(Z_W))

%%
% Set the contour lines to the max surface value.
zdatam(handlem('line'),max([Z_D(:)' Z_W(:)']));

%% Map 9: Image with a worldfile 
% Display an image with a worldfile.

figure
mapshow('concord_ortho_e.tif');

%% Credits
% concord_roads.shp, concord_hydro_line.shp, concord_hydro_area.shp, 
% concord_ortho_e.tif:
%
%    Office of Geographic and Environmental Information (MassGIS),
%    Commonwealth of Massachusetts  Executive Office of Environmental Affairs
%    http://www.state.ma.us/mgis
%
% 9129CATD.ddf (and supporting files): 
% 
%    United States Geological Survey (USGS) 7.5-minute Digital Elevation
%    Model (DEM) in Spatial Data Transfer Standard (SDTS) format for the
%    Mt. Washington quadrangle, with elevation in meters.
%    http://edc.usgs.gov/products/elevation/dem.html
%
%    For more information, run: 
%    
%    >> type 9129.txt
%
% MtWashington-ft.grd, MountDartmouth-ft.grd:
%
%    MtWashington-ft.grd is the same DEM as 9129CATD.ddf, but converted to
%    Arc ASCII Grid format with elevation in feet.
%
%    MountDartmouth-ft.grd is an adjacent DEM, also converted to Arc ASCII
%    Grid with elevation in feet.
%
%    For more information, run: 
%    
%    >> type MtWashington-ft.txt
%    >> type MountDartmouth-ft.txt
%

