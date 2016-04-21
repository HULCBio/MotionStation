function [obj,msg] = namem(hndl)

%NAMEM  Determines the object name (tag or type) for graphics objects
%
%  obj = NAMEM returns the object name for all objects on the current
%  axes.  The object name is defined as its tag, if the tag property
%  is supplied.  Otherwise, it is the object type.  Duplicate object
%  names are removed from the output string matrix.
%
%  obj = NAMEM(h) returns the object names for the objects specified
%  by the input handles h.
%
%  [obj,msg] = NAMEM(...)  returns a string msg indicating any error
%  encountered.
%
%  See also CLMO, HIDE, SHOWM, TAGM, HANDLEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.8.4.1 $    $Date: 2003/08/01 18:19:03 $


%  Initialize inputs

if nargin == 0;   hndl = handlem('all');   end


%  Initialize outputs

obj = [];   msg = [];

%  Enforce a vector input

hndl = hndl(:);

%  Handle tests

if isstr(hndl) | any(~ishandle(hndl))
    msg = 'Vector of handles required';
	if nargout < 2;  error(msg);   end
	return
end


%  Determine the types of each graphics object
%  Include in the name list only if it is unique

objtag  = get(hndl,'Tag');
objtype = get(hndl,'Type');

for i = 1:length(hndl)
     if length(hndl) == 1
	      if isempty(objtag);  objtag = objtype;  end
     else
	      if isempty(objtag{i});  objtag{i} = objtype{i};  end
	 end
end

if length(hndl) == 0;          obj = [];
   elseif length(hndl) == 1;   obj = objtag;
   else                        [obj,i] = unique(strvcat(objtag{:}),'rows');
							   obj = strvcat(objtag{sort(i)});
end
