function varargout = sfopen
%SFOPEN Opens a new machine.

%	Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14.2.1 $  $Date: 2004/04/15 01:01:42 $

[filename, pathname] = uigetfile('*.mdl');

if filename,
    [path,filename,ext] = fileparts(filename);
    
    
    if(~strcmp(ext,'.mdl'))
       errordlg(sprintf('Cannot open a model without .mdl extension: %s%s',filename,ext),'Stateflow');
       filename = '';
    end
    
    if (~isempty(filename)), 
    	% Temporarily cd'ing to the directory in question is the only way 
    	% to get rid of unwanted name crufts (such as: 'f:\...'); 
    	% These are to be avoided as they will polute the name of the model
    	% and then in turn corrupt the machine name.
    
    	sf('Version'); % make sure the Stateflow MEX file is loaded before changing directory
    	pwDir = pwd;
    	cd(pathname);
    	open_system(filename); 
    	cd(pwDir);
    	if nargout>0
    		varargout{1} = get_param(filename,'handle');
    	end
    elseif nargout>0
    		varargout{1} = -1;
    end;
elseif nargout>0
		varargout{1} = -1;
end;
