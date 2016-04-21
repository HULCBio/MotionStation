%VRHEAT_ANIM Heat transfer visualization example with creating 2D animation.
%   An example of using MATLAB interface of Virtual Reality Toolbox to
%   create 2D off-line animation file. 
%
%   The heat transfer data computed in FEMLAB(tm).
%
%   See also VRHEAT, AVIFILE.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2003/09/16 16:44:52 $ $Author: batserve $

function vrheat_anim

disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('%%% Heat transfer visualization with creating 2D animation demo %%%');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp('%%% In this demo we demonstrate the use of Virtual Reality Toolbox');
disp('%%% MATLAB interface to create 2D off-line animation files.'); 
disp('%%% For details how to visualize the computed data please refer to');
disp('%%% VRHEAT, here we focus only on recording off-line animations.');
disp('%%% Recording is controlled by setting the relevant VRWORLD and');
disp('%%% VRFIGURE object properties.');
disp(' ');

disp('%%% We load the precalculated data and display the first time frame');
disp('%%% of the scene.');
disp('%%% ...');

load vrheat.mat;
vert = lblock.mesh.p';
facets = lblock.mesh.e(1:3,:)-1;
facets(4,:) = -1;
f = facets; f = f(:); 
facets = facets';
cmap = jet(192);
u = lblock.sol.u; 
ucolor = (u-repmat(min(u),size(u,1),1)) .* (size(cmap,1)-1);
urange = max(u) - min(u); 
urange(find(urange == 0)) = 1;
ucolor = round(ucolor./repmat(urange,size(u,1),1));
uslice=ucolor(:,1); 
colind=zeros(size(facets)); 
colind(:,1:3)=uslice(facets(:,1:3)+1); 
colind(:,4)=-1; 
ci = colind''; ci = ci(:);
world = vrworld('vrheat.wrl');
open(world);
world.IFS_Colormap.color = cmap;
world.IFS.colorIndex = ci;
world.IFS_Coords.point = vert;
world.IFS.coordIndex = f;
world.TEXT.string = 'Time = 0';
figure = vrfigure(world); 

disp('%%% We have the handles to the virtual world and the internal viewer');
disp('%%% figure objects saved in the variables ''world'' and ''figure''.');
disp('%%% Now we set the virtual world and figure properties related');
disp('%%% to the recording.');
disp('%%% We want to activate scheduled 2D recording into file');
disp('%%% vrheat_anim.avi during the scene time interval (0,4)');
disp('%%% that corresponds to the pre-computed heat distribution time.');
dispeval([ ...
        'set(world, ''RecordMode'', ''scheduled''); ...\n' ...
        '   set(world, ''RecordInterval'', [0 4]); ...\n' ...
        '   set(figure, ''Record2DFileName'', ''vrheat_anim.avi''); ...\n' ...
        '   set(figure, ''Record2D'', ''on''); ...\n' ...
        '   set(figure, ''Record2DCompressQuality'', 100); ...\n' ...
        '   set(figure, ''PanelMode'', ''off'');']);
    
disp('%%% Now we can start the animation. Watch it in the viewer.');
disp('%%% Please compose both MATLAB command window and Virtual Reality Toolbox');
disp('%%% viewer figure so that they are both fully visible and adjust the figure');
disp('%%% size to the required resolution of resulting 2D animation file.');
disp('%%% 2D animation is recorded exactly as you see it in the viewer figure,');
disp('%%% using the AVIFILE function.');
disp('%%% When scheduled recording is active, a time frame is recorded into');
disp('%%% the animation file with each setting the virtual world ''Time'' property.');
disp('%%% It is up to the user to set the scene time in the desired, usually');
disp('%%% from the point of view of the simulated phenomenon equidistant, times.');
disp('%%% Please note that the scene time can represent any independent quantity,');
disp('%%% along which you want to animate the computed solution.');

dispeval([ ...
        'for i = 1:size(u,2) ...\n' ...
        '     pause(0.01); ...\n' ...
        '     uslice = ucolor(:,i); ...\n' ...
        '     colind = zeros(size(facets)); ...\n' ...
        '     colind(:,1:3) = uslice(facets(:,1:3)+1); ...\n' ...
        '     colind(:,4) = -1; ...\n' ...
        '     ci=colind''; ...\n' ...
        '     ci=ci(:); ...\n' ...
        '     world.IFS.colorIndex = ci; ...\n' ...
        '     world.TEXT.string = {sprintf(''Time = %%g'', lblock.sol.tlist(i))}; ...\n' ...
        '     set(world,''Time'', lblock.sol.tlist(i)); ...\n' ...
        '     vrdrawnow;\n' ...
        '   end']);

disp('%%% As the animation stops, the file vrheat_anim.avi is created in your');
disp('%%% working directory. Now we close and delete the virtual world.');
dispeval('close(world); delete(world);');

disp('%%% Now you can play the 2D off-line animation file in your default');
disp('%%% system AVI player. By pressing Enter this demo will be finished.');
disp('%%% The AVI file will remain in your working directory for later use.');
dispeval('!start vrheat_anim.avi');

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
	evalin('caller', x);
	fprintf('\n');
