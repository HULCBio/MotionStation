function result = sfcustom( method, varargin )
%SFCUSTOM( METHOD, VARARGIN) Add custom code here.

%	E. Mehran Mestchian
%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.52.4.1 $  $Date: 2004/04/15 00:59:57 $
%

switch method
case 'save'
	machineId = varargin{1};
	fileName = varargin{2};
%	custom_save( machineId,fileName);
case 'load'
	machineId = varargin{1};
	simulinkH = varargin{2};
%	custom_load( machineId,simulinkH);
case 'editor'
	defaultEditorFigure = varargin{1};
	try,  
   	load_custom_target_menus(defaultEditorFigure);  
	catch,
	end 
   %	custom_editor( defaultEditorFigure )
case 'filter unresolved symbols'
   % Given a target id and a list of unresolved symbols, filter out any
   % symbols that we resolve.  Return the remainder.
   targetId = varargin{1};
   errorStructArray = varargin{2};
case 'allow_constant_sample_time'
   %%% Stateflow generated SFunctions now call into sfcustom.m
   %%% to ask whether charts can be allowed to have constant sample time.
   %%% In the previous versions of Stateflow(before 2.0), charts inherited a 
   %%% constant sample time if they were fed by constant input signals from Simulink.
   %%% This was not the right thing since, 99% of the Stateflow charts
   %%% have some type of persistent state (i.e., states, output data, local data)
   %%% making them unsuitable to inherit constant sample time.
   %%% A side effect of this was that when Simulink's inline parameters
   %%% optimization was turned on, these models yielded different results
   %%% since these charts got executed only once during the start of simulation.
   %%% If for some reason, you are relying on the old behavior, you can change the
   %%% following line to 
   %%%     result= 1;
   %%% to revert to previous behavior.
   %%% However, we strongly recommend that you modify your diagrams not to
   %%% depend on this behavior since it will not be supported in future releases.
   result = 0;
case 'test_loading_this_file'
   return;
case 'c_parenthesization'
   %%% Set  optional additional parnethesization for C expressions in generated code.
   %%% 16x16 bit vector organized by precedence levels.
   %%% Use all zeros, or an empty array, to get minimal parenthesization.
   %%% Use all ones to get full parenthesization.
   %%%
   %%% parent operator => row
   %%% (child operator) => entry
   %%%
   %%% Examples:
   %%%      minimal ()              full ()
   %%%      a && b || c           (a && b) || c        result[4] = hex2dec('10');
   %%%      a | b == 0             a | (b == 0)        result[6] = hex2dec('100');
   %%%
   %%%   % the following bit vector represents the bits that are ignored, because
   %%%   % they are cases which require () for emitting correct C code.
   %%%      result = hex2dec([...
   %%%         '0000';...	%  comma		0x0001
   %%%         '0001';...	%  assign		0x0002
   %%%         '0003';...	%  ? :			0x0004
   %%%         '0007';...	%  ||			0x0008
   %%%         '000f';...	%  &&			0x0010
   %%%         '001f';...	%  |			0x0020
   %%%         '003f';...	%  ^			0x0040
   %%%         '007f';...	%  &			0x0080
   %%%         '00ff';...	%  == !=		0x0100
   %%%         '01ff';...	%  < > 		        0x0200
   %%%         '03ff';...	%  << >>		0x0400
   %%%         '07ff';...	%  + -			0x0800
   %%%         '0fff';...	%  * / %		0x1000
   %%%         '1fff';...	%  prefix		0x2000
   %%%         '3fff';...	%  postfix		0x4000
   %%%         '7fff'...	%			0x8000
   %%%          ]);
   persistent sParenTable;
   if(length(varargin)>0 & isequal(varargin{1},'reset'))
      sParenTable = [];
   end
   if(isempty(sParenTable))
      sParenTable = hex2dec([...
            '0000';...	%  comma		0x0001
            '0318';...	%  assign		0x0002 Vijay9jul02: added "0100+0200+0010+0008"
            '0000';...	%  ? :			0x0004
            '3ff0';...	%  ||			0x0008
            '3fe0';...	%  &&			0x0010
            '1bc0';...	%  |			0x0020
            '1ba0';...	%  ^			0x0040
            '1b60';...	%  &			0x0080
            '0000';...	%  == !=		0x0100
            '0600';...	%  < > 		    0x0200
            '0e00';...	%  << >>		0x0400
            '0ce0';...	%  + -			0x0800
            '00e0';...	%  * / %		0x1000
            '0000';...	%  prefix		0x2000
            '0000';...	%  postfix		0x4000
            '0000'...	%			0x8000
         ]);   
   end;
   if(length(varargin)>0 & ~isequal(varargin{1},'reset'))
      sParenTable = varargin{1};
   end
   result = sParenTable;
   return;
otherwise,
	warning(sprintf('Unrecognized method ''%s'' is ignored.',method));
	return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function load_custom_target_menus(defaultEditorFigure)

	% collect target files
	sfTargets = find_target_files;
	if(isempty(sfTargets))
		return;
	end
	
	% find the menu
	customTargetMenu = findobj(defaultEditorFigure...
                              ,'Type','uimenu'...
	                           ,'Label','&Tools');
	if(isempty(customTargetMenu))
		warning('Could not find Tools menu in sfcustom/load_custom_target_menus.');						
		return;
	end

	% add commands to menu
	for i=1:length(sfTargets)
		name = sfTargets(i).name;
		uimenu('Parent',customTargetMenu...
          ,'Label',['Open ',name,' Target']...
			 ,'Callback', 'sf(''Private'',''sfcall'')');
	end		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function custom_editor( defaultEditorFigure )
	disp('Stateflow custom tools');
	m = uimenu('Parent',defaultEditorFigure,'Label','Custom');
	uimenu('Parent',m,'Label','Database');
	uimenu('Parent',m,'Label','Report Generator');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function custom_save( machineId, fileName )
	fid = fopen(fileName,'at');
	if fid<=2, warning(sprintf('Failed to open file %s.',fileName)); end
	fprintf(fid,'\nCustomInfo {\n');
	fprintf(fid,'\t#This block contains custom Stateflow information\n');
	fprintf(fid,'\t#Date: %s\n',datastr(now,0));
	fprintf(fid,'}\n');
	fclose(fid);
	disp(sprintf('Saved customized model: %s.',fileName));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function custom_load( machineId, simulinkH )
	disp(sprintf('Loading customized Stateflow model: %s.',get_param(simulinkH,'Filename')));


