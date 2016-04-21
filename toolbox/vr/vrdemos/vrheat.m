%VRHEAT Heat transfer visualization example.
%   A step-by-step example of sending matrix values to virtual reality
%   to achieve large changes of virtual world efficiently.
%   Heat transfer is visualized using an L-shaped object subdivided into
%   triangles. Colors of all vertices change in every animation step.
%
%   The heat transfer data computed in FEMLAB(tm).

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2003/09/16 16:44:50 $ $Author: batserve $

function vrheat

disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('%%% Heat transfer visualization demo %%%');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp('%%% In this demo we demonstrate transfers of matrix data between MATLAB');
disp('%%% and virtual reality. Using this feature, massive color changes');
disp('%%% or shape shifting can be achieved, which can be useful for visualizing');
disp('%%% various physical processes.');
disp(' ');
disp('%%% We use precalculated time-based data of temperature distribution');
disp('%%% in an L-shaped metal block and send it step by step to the virtual reality,');
disp('%%% resulting in an animation where the colors of the whole block change');
disp('%%% every animation frame.');
disp(' ');

disp('%%% We load the precalculated data first.');
dispeval('load ''vrheat.mat'';');

disp('%%% The geometry of the L-shaped block is stored in the ''lblock'' structure.');
disp('%%% For visualisation purposes, the block is subdivided into triangular facets.');
disp('%%% Surface facet vertex coordinates are stored in the ''lblock.mesh.p'' field');
disp('%%% and triangle edges are described by indices into the vertex array.');
dispeval('lblock.mesh');
dispeval('vert = lblock.mesh.p'';');

disp('%%% A set of facets in VRML is defined as a single vector of vertex indices');
disp('%%% where facets are separated by -1, so we need to transform the vertex array');
disp('%%% appropriately. Indexes in VRML are zero-based, so 1 is deducted from all index');
disp('%%% values stored originally in 1-based index array lblock.mesh.e .');
dispeval([
    'facets = lblock.mesh.e(1:3,:)-1; ...\n' ...
    '   facets(4,:) = -1; ...\n' ...
    '   f = facets; f = f(:); ...\n' ...
    '   facets = facets'';']);

disp('%%% Now we''ll prepare a colormap which represents various levels of temperature.');
disp('%%% The MATLAB built-in ''jet'' colormap is designed for these purposes.');
dispeval('cmap = jet(192);');

disp('%%% The ''lblock.sol.u'' field contains a matrix describing the temperatures of vertices');
disp('%%% as the time passes. We have 41 precalculated phases (1 is initial) for 262 vertices.');
dispeval('lblock.sol');

disp('%%% Now we need to scale the temperature values so that they map into the colormap.');
dispeval([
    'u = lblock.sol.u; ...\n' ...
    '   ucolor = (u-repmat(min(u),size(u,1),1)) .* (size(cmap,1)-1); ...\n' ...
    '   urange = max(u) - min(u); ...\n' ...
    '   urange(find(urange == 0)) = 1; ...\n' ...
    '   ucolor = round(ucolor./repmat(urange,size(u,1),1));']);

disp('%%% We will calculate the first animation frame so we have something to begin with.');
dispeval([
    'uslice=ucolor(:,1); ...\n' ...
    '   colind=zeros(size(facets)); ...\n' ...
    '   colind(:,1:3)=uslice(facets(:,1:3)+1); ...\n' ...
    '   colind(:,4)=-1; ...\n' ...
    '   ci = colind''; ci = ci(:);']);

disp('%%% The data are ready so we can load the world.');
dispeval('world = vrworld(''vrheat.wrl''); open(world);');

disp('%%% Let''s start the viewer. A cube should appear in the viewer window.');
dispeval('view(world); vrdrawnow;');

disp('%%% Now we''ll prepare the L-shaped block. The VRML world we have loaded');
disp('%%% contains a basic cubic form we can reshape to anything we want');
disp('%%% by setting its ''point'' and ''coordIndex'' fields which represent');
disp('%%% the vertex coordinates and indices to the vertex array.');
disp('%%% We will also set the colors by setting the ''color'' and ''colorIndex'' fields.');
disp(' ');
disp('%%% We first set the colors, then the color indices, then the vertices');
disp('%%% and then the vertex indices. The order is not mandatory but is generally');
disp('%%% better because this way we are sure there is no temporary state');
disp('%%% when we have more vertices than colors, or more indices than values,');
disp('%%% which would cause some vertices to have undefined color or some indices');
disp('%%% referring to nonexisting (yet) values.');
dispeval([ ...
        'world.IFS_Colormap.color = cmap; ...\n' ...
        '   world.IFS.colorIndex = ci; ...\n' ...
        '   world.IFS_Coords.point = vert; ...\n' ...
        '   world.IFS.coordIndex = f;']);

disp('%%% The textual comment can also be set to something sensible.');
dispeval('world.TEXT.string = {''Time = 0''}; vrdrawnow;');

disp('%%% Now we can start the animation. Watch it in the viewer.');
disp('%%% You can move around the object, or try to set other rendering modes,');
disp('%%% e.g. a wireframe mode which demonstrates how the L-block is subdivided.');

dispeval([ ...
        'for i = 1:size(u,2) ...\n' ...
        '     pause(0.2); ...\n' ...
        '     uslice = ucolor(:,i); ...\n' ...
        '     colind = zeros(size(facets)); ...\n' ...
        '     colind(:,1:3) = uslice(facets(:,1:3)+1); ...\n' ...
        '     colind(:,4) = -1; ...\n' ...
        '     ci=colind''; ...\n' ...
        '     ci=ci(:); ...\n' ...
        '     world.IFS.colorIndex = ci; ...\n' ...
        '     world.TEXT.string = {sprintf(''Time = %%g'', lblock.sol.tlist(i))}; ...\n' ...
        '     vrdrawnow;\n' ...
        '   end']);

disp('%%% We''re done!');
disp('%%% At this point we should close the world and clean any used global variables.');
disp('%%% However, you may want to keep the world (and experiment with it more, or save it).');
disp(' ');
x = input('Do you want to keep the world? (y/n) ', 's');
disp(' ');
if strcmpi(x, 'y')
    disp('%%% We clear the used variables but keep the world.');
    dispeval('clear ans ci cm cmap colind f facets i lblock nh u ucolor urange uslice v vert;');
else
    disp('%%% We clear the used variables and close and delete the world object.');
    dispeval([
        'close(world); delete(world); ...\n' ...
        '   clear ans ci cm cmap colind f facets i lblock nh u ucolor urange uslice v vert world;']);
end

disp('%%% Demo finished.');
disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  DISPEVAL
%  displays and evaluates a command
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dispeval(x)
    disp('%%%');
	disp('%%% Press Enter to execute the commands.');
	x = sprintf(x);
	fprintf('\n>> %s\n', x);
	ignore = input('','s');
	evalin('base', x);
	fprintf('\n');
