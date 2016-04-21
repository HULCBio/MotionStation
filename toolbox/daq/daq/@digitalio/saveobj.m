function obj = saveobj(obj)
%SAVEOBJ Save filter for data acquisition objects.
%
%    B = SAVEOBJ(OBJ) is called by SAVE when a data acquisition object is
%    saved to a .MAT file. The return value B is subsequently used by SAVE  
%    to populate the .MAT file.  
%
%    SAVEOBJ will be separately invoked for each object to be saved.
% 
%    See also DAQ/PRIVATE/SAVE, ANALOGINPUT/LOADOBJ.
%

%    MP 4-17-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:41:49 $

% Define a persistent variable to help with recurssively linked objects
persistent objsSaved;

% Check to see if we have previously saved this object prior
if ~isempty(objsSaved)
	for i = 1:length(objsSaved)
		if isequal(objsSaved{i}, obj)
			% Detected that object has been previously saved
			% Break the recursive link
			obj = [];
			% Display a warning to the user
            bt = warning('query', 'backtrace');
            warning off backtrace;
			warning('daq:saveobj:recursive', ...
				'A recursive linking between objects has been found during the SAVE. \nAll objects have been saved, but the link has been removed.');			
            warning(bt);
            return;
		end
	end
end

% Object was not saved prior, add to recurssive list.
objsSaved{end+1} = obj;

% Call the helper function which does all the work.  This cannot be in the private
% directory since access to the object's fields are needed.
obj = helpersaveobj(obj);

% Reset the IsSaved flag to off so that the object and the object's
% UserData can be saved again.
allobj = daqfind;
for i = 1:length(allobj)
   tempobj = get(allobj, i);
   set(tempobj, 'IsSaved', zeros(1,10));
end

% Object saved without recurssive issue, remove from recurssive list.
objsSaved(end) = [];

