function too_many_editors(openEditors, loading),
% TOO_MANY_EDITORS 
%
%

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 01:01:11 $

try,
    if ~loading,
	    TAG = 'WIN_RESOURCE_LIMITATION_DLG';
	    fig = findall(0, 'type','figure','tag', TAG);
	    if isempty(fig),
    	    fig = warndlg(['Due to limitations on Windows95/98/Me platforms, ',...
			     'we recommend you now close some Stateflow Diagrams to ', ...
			     'free up graphical resources.  Failure to do so may result ', ...
			     'in Windows resource depletion and potential data loss.'],'Resource Alert');
            set(fig, 'tag', TAG);
 	    else,
	 	    figure(fig);
	    end;
    else,
       sfclose(openEditors(end));
    end;
catch,
	disp(lasterr);
end;
