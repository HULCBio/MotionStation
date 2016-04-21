function mat = getm(hndl,propname)

%GETM  Get map object properties
%
%  mat = GETM(h,'MapPropertyName') returns the value of the specified
%  map property for the map graphics object with handle h.  The
%  graphics object h must be a map axis or one of its children.
%
%  mat = GETM(h) returns all map property values for the map object with
%  handle h.  
%
%  GETM MAPPROJECTION lists the available map projections.
%  GETM AXES lists the map axes properties.
%  GETM UNITS lists the recognized unit strings.
%
%  See also  AXESM, SETM, GET, SET

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.11.4.1 $    $Date: 2003/08/01 18:18:26 $

%  Programmers Note:  GETM is a time consuming call because of
%  the strmatch and getfield functions.  It is advised that when
%  programming, direct access is made to the map structure and
%  do not use calls to GETM.  For an example of this, see GRIDM
%  and FRAMEM.

if nargin == 0
	error('Incorrect number of arguments')

elseif nargin == 1
    if ~isstr(hndl)         %  Handle provided.  Get all properties
	     propname = [];
    else                    %  No handle.  Test for special string
        validparm = strvcat('mapprojection','units','axes');
		indx = strmatch(lower(hndl),validparm);
		if length(indx) == 1
		     hndl = deblank(validparm(indx,:));
		else
		    error('Unrecognized GETM string')
		end

		 switch  hndl
		    case 'mapprojection',    maps;     return
		    case 'units',            unitstr;  return
		    case 'axes',			setm(gca);      return
		 end
	 end
end


%  Valid handle test

if isempty(hndl);  error('Handle is not valid');  end;
if max(size(hndl) ~= 1);   error('Multiple handles not allowed');  end
if ~ishandle(hndl);        error('Handle is not valid');           end

%  Get the corresponding axis handle

if strcmp(get(hndl,'Type'),'axes')
     maphndl = hndl;

elseif strcmp(get(get(hndl,'Parent'),'Type'),'axes')
     maphndl = get(hndl,'Parent');

else
     error('GETM only works with a Map Axis and its children')
end

%  Test for a valid map axes and get the corresponding map structure

[mstruct,msg] = gcm(maphndl);
if ~isempty(msg)
	if nargout < 2;  error(msg);  end
	return
end

% check that new false easting, northing, scalefactor and zone properties
% are present. If needed, add them with the default values.

try, mstruct.zone; 			catch, mstruct.zone = []; 			end
try, mstruct.falseeasting; 	catch, mstruct.falseeasting = 0; 	end
try, mstruct.falsenorthing; catch, mstruct.falsenorthing = 0;	end
try, mstruct.scalefactor; 	catch, mstruct.scalefactor = 1; 	end
try, mstruct.labelrotation; catch, mstruct.labelrotation = 'off'; end

%  Get the user data structure from this object

userstruct = get(hndl,'UserData');
if ~isstruct(userstruct);   error('Map structure not found in object');   end

%  Return the entire structure if propname is empty

if isempty(propname);    mat = userstruct;   return;   end

%  Otherwise, get the fields of the structure and test for a match

structfields = fieldnames(userstruct);
indx = strmatch(lower(propname),lower(structfields));
if isempty(indx)
    error('Incorrect property for object')
elseif length(indx) == 1
    propname = structfields{indx};
else
	indx = strmatch(lower(propname),lower(structfields),'exact');
			  
	if length(indx) == 1
    	propname = structfields{indx};
	else
	    error(['Property ',propname,...
	          ' name not unique - supply more characters'])
	end
end

%  If match is found, then return the corresponding property

mat = getfield(userstruct,propname);

