function [mflag,msg] = ismapped(hndl)

%ISMAPPED  Test if object is projected on a map axes
%
%  ISMAPPED returns a 1 if the current object (gco) is projected on
%  a map axes.  Otherwise it returns a 0.
%
%  ISMAPPED(hndl) tests the object specified by hndl.
%
%  [m,msg] = ISMAPPED(...) returns an optional second argument
%  which is a string indicating any error state.
%
%  See also  GCM, ISMAP

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
    hndl = get(get(0,'CurrentFigure'),'CurrentObject');
    if isempty(hndl);  error('No selected object in current figure');  end
end

%  Initialize outputs

mflag = 1;   msg   = [];

%  Test the object parent for a map axes

parent = get(hndl,'Parent');
[axesflag,msg] = ismap(parent);
if ~isempty(msg);   mflag = 0;   return;   end

%  Test the object user data for necessary components

userdata = get(hndl,'UserData');
if ~isstruct(userdata)
    mflag = 0;    msg = 'Map structure not found';
else

    names = fieldnames(userdata);
    if ~ismember('trimmed',names) & ~ismember('trimmed',names) 
		 mflag = 0;   msg = 'Necessary fields not found in map structure';
    end
end
