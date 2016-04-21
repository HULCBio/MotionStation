function [mflag,msg] = ismap(hndl)

%ISMAP  Test for current map axes
%
%  ISMAP returns a 1 if the current axes (gca) have the proper
%  tag and structure for a map definition.  Otherwise, it
%  returns a 0.
%
%  ISMAP(hndl) tests the axes specified by hndl for a map definition.
%
%  [m,msg] = ISMAP(...) returns an optional second argument
%  which is a string indicating any error state.
%
%  See also  GCM, ISMAPPED

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 0
    hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
    if isempty(hndl);  error('No axes in current figure. Select a figure with map axes or use AXESM to define one.');  end
end

%  Test for current map axes

mflag = 1;   msg = [];


if min(size(hndl)) ~= 1
    mflag = 0;
	msg   = 'Input handle must be a scalar';

elseif ~ishandle(hndl)
    mflag = 0;
    msg   = 'Input data is not a graphics handle';

elseif ~strcmp(get(hndl,'Type'),'axes')
    mflag = 0;
    msg   = 'Object handle is not an axis';
else
	mapstruct = get(hndl,'UserData');
    if ~isstruct(mapstruct)
           mflag = 0;
	       msg   = 'Not a map axes. Select a map axes or use AXESM to define one.';
    else
	       names = fieldnames(mapstruct);
           if ~strcmp(names{1},'mapprojection')
                 mflag = 0;
	             msg   = 'Not a map axes. Select a map axes or use AXESM to define one.';
           end
	end
end

