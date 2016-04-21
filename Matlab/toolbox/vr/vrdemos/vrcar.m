function vrcar
%VRCAR Car in the mountains - the basic Virtual Reality Toolbox example.
%   The VRCAR example illustrates the use of the Virtual Reality Toolbox
%   MATLAB interface. In a step-by-step tutorial, it shows commands for
%   navigating a virtual car along a path through the mountains.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.7.4.2 $ $Date: 2004/04/06 01:11:18 $ $Author: batserve $

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('%%%                                                    %%%');
disp('%%%        Welcome to the Virtual Reality Toolbox!     %%%');
disp('%%%                                                    %%%');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp('%%% In this example we will show you how to control an object in a virtual');
disp('%%% world using the MATLAB object-oriented interface.');
disp('%%%');
disp('%%% We begin with creating an object of class VRWORLD that represents');
disp('%%% the virtual world. The VRML file that constitutes the world was previously');
disp('%%% made by the V-Realm VRML builder contained in the Virtual Reality Toolbox.');
disp('%%% The name of the file is VRMOUNT.WRL.');
dispeval('world = vrworld(''vrmount.wrl'')');

disp('%%% The world must be opened before it can be used.');
disp('%%% This is accomplished by the OPEN command.');
dispeval('open(world);');

disp('%%% The virtual world can be viewed in the VRML viewer. Virtual Reality Toolbox'); 
disp('%%% offers two ways of viewing virtual worlds - internal viewer (default method)');
disp('%%% and external viewer, integrated with your Web browser (available on some platforms).');
disp('%%% We will view the virtual world in the viewer using the VIEW function.'); 
disp('%%% It may take some time before the viewer opens, so please be patient.');
dispeval('view(world);vrdrawnow;');

disp('%%% We can examine the properties of the virtual world by the GET command.');
disp('%%% Note the ''FileName'' and ''Description'' properties which contain the file name');
disp('%%% and description taken from the ''title'' property of the VRML file.');
disp('%%% Detailed description of all the properties is beyond the scope of this example'); 
disp('%%% but can be easily found in the VR Toolbox manual or in the online documentation.');
dispeval('get(world)');

disp('%%% All elements in a virtual world are represented by VRML nodes.');
disp('%%% Behaviour of any element can be controlled by changing the fields');
disp('%%% of the appropriate node (or nodes).');
disp('%%% The NODES command prints out a list of nodes available in the world.');
dispeval('nodes(world)');

disp('%%% To access a VRML node, an appropriate VRNODE object must be created.');
disp('%%% The node is identified by its name and the world it belongs to.');
disp('%%%');
disp('%%% We will create a VRNODE object associated with a VRML node ''Automobile''');
disp('%%% that represents the model of car on the road. If you don''t see it in the scene,');
disp('%%% don''t worry. It is hidden in the tunnel on the left.');
dispeval('car = vrnode(world, ''Automobile'')');

disp('%%% VRML fields of a given node can be queried by the FIELDS command.');
disp('%%% We''ll see that there are fields named ''translation'' and ''rotation''');
disp('%%% in the node list. We can move the car around by changing these fields.');
dispeval('fields(car)');

disp('%%% Now we prepare vectors of coordinates determining the car movement.');
disp('%%% By setting them in a loop we will create an animated scene.');
disp('%%% There are three sets of data for three phases of car movement.');

c1 = 'z1 = 0:12;\n   x1 = 3 + zeros(size(z1));\n   y1 = 0.25 + zeros(size(z1));\n';
c2 = '\n   z2 = 12:26;\n   x2 = 3:1.4285:23;\n   y2 = 0.25 + zeros(size(z2));\n';
c3 = '\n   x3 = 23:43;\n   z3 = 26 + zeros(size(x3));\n   y3 = 0.25 + zeros(size(z3));';
dispeval([c1 c2 c3]);

disp('%%% Now let''s move the car along the first part of its trajectory.');
disp('%%% The car is moved by setting the ''translation'' field of the ''Automobile'' node.');
dispeval('for i=1:length(x1);\n    car.translation = [x1(i) y1(i) z1(i)];vrdrawnow;\n    pause(0.1);\n   end;');

disp('%%% We''ll rotate the car a little to get to the second part of the road.');
disp('%%% This is done by setting the ''rotation'' property of the ''Automobile'' node.');
dispeval('car.rotation = [0, 1, 0, -0.7];vrdrawnow;');

disp('%%% Now we''ll pass the second road section.');
dispeval('for i=1:length(x2);\n    car.translation = [x2(i) y2(i) z2(i)];vrdrawnow;\n    pause(0.1);\n   end;');

disp('%%% Finally, we turn the car to the left again ...');
dispeval('car.rotation = [0, 1, 0, 0];vrdrawnow;');

disp('%%% ... and let it move through the third part of the road.');
dispeval('for i=1:length(x3);\n    car.translation = [x3(i) y3(i) z3(i)];vrdrawnow;\n    pause(0.1);\n   end;');

disp('%%% If we want to reset the scene to the original state');
disp('%%% defined in the VRML file, we can reload the world.');
dispeval('reload(world);vrdrawnow;');

disp('%%% After you are done with a VRWORLD object, it is necessary to close and delete it.');
disp('%%% This is accomplished by the CLOSE and DELETE commands.');
disp('%%%');
disp(' ');
disp('>> close(world);');
disp('>> delete(world);');
disp(' ');
disp('%%%');
disp('%%% However, we will not do it here. Instead, we leave the world open so that');
disp('%%% you can play with it further. You can try moving the car around using commands');
disp('%%% similar to those above, or you can try to access other nodes and their fields.');
disp('%%% We will clear only the used global variables.');
dispeval('clear ans car i x1 x2 x3 y1 y2 y3 z1 z2 z3;');

disp('%%%');
disp('%%% Congratulations! You have just finished the Virtual Reality Toolbox interactive tutorial.');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  DISPEVAL
%  displays and evaluates a command
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dispeval(x)
	disp('%%%');
	disp('%%% Press Enter to execute the command.');
	x = sprintf(x);
	fprintf('\n>> %s\n\n', x);
	ignore = input('','s');
	evalin('base', x);
	fprintf('\n');
