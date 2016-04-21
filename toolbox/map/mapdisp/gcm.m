function [mapstruct,msg] = gcm(hndl)

%GCM  Get the map projection structure from an axes
%
%  GCM will return the map projection data structure from the
%  current axes (gca).  If the current axes does not contain a
%  map definition, then an error results.
%
%  GCM(hndl) returns the map structure from the axes specified
%  by the input hndl.
%
%  [m,msg] = GCM(...) returns an optional second argument
%  which is a string indicating any error state.
%
%  See also AXESM, GETM

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown



%  Set the default handle if no inputs are supplied

if nargin == 0
    hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
    if isempty(hndl);  error('No axes in current figure');  end
end

%  Initialize outputs

mapstruct = [];   msg = [];

%  Check for map axis.  If valid map, get the map structure

[mflag,msg] = ismap(hndl);

if mflag
     mapstruct = get(hndl,'UserData');
	 
	 % check that new properties are present. If not, add the default values.
	 
	 try, mapstruct.zone; 			catch, mapstruct.zone = []; 		end
	 try, mapstruct.falseeasting; 	catch, mapstruct.falseeasting = 0; 	end
	 try, mapstruct.falsenorthing; 	catch, mapstruct.falsenorthing = 0; end
	 try, mapstruct.scalefactor; 	catch, mapstruct.scalefactor = 1; 	end
	 try, mapstruct.labelrotation; 	catch, mapstruct.labelrotation = 'off'; end
	 
		 
else
     if nargout < 2; error(msg);  end
end

