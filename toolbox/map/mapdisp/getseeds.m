function [row,col,value] = getseeds(map,maplegend,nseeds,seedval)

%GETSEEDS:  Get seed locations and values for encoding maps
%
%  [row,col,val] = GETSEEDS(map,maplegend,nseeds) allows
%  user to identify geographical objects while customizing a
%  map. It prompts the user for mouse click positions of objects and
%  assigns them a code value.  The user is prompted for the value
%  to seed at each location.  The outputs are the row and column of
%  the seed location and the value assigned at that location.
%
%  [row,col,val] = GETSEEDS(map,maplegend,nseeds,seedval) assigns
%  the value seedval to each location supplied.  If seedval is a
%  scalar then the same value is assigned at each location.  Otherwise,
%  if seedval is a vector it must be length(nseeds) and each entry
%  is assigned to the corresponding location.  GETSEEDS operates
%  on the current axes (gca).
%
%  mat = GETSEEDS(...) returns a single output matrix
%  where mat = [row col val].
%
%  See also ENCODEM

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin < 3
	error('Incorrect number of arguments')
elseif nargin == 3
   seedval = [];
end

%  Argument input tests

if length(size(map)) > 2
    error('Input map can not have pages')

elseif ~isequal(sort(size(maplegend)),[1 3])
    error('Input maplegend must be a 3 element vector')

elseif max(size(nseeds)) > 1
    error('Nseeds input must be empty or scalar')

elseif ~isreal(nseeds)
    warning('Imaginary part of complex NSEEDS argument ignored')
	nseeds = real(nseeds);
end

%  Ensure integer nseeds

nseeds = round(nseeds);

%  Test the seedval input

if ~isempty(seedval)
    if length(seedval) == 1
	      seedval = seedval(ones([nseeds 1]));
	elseif ~isequal(sort(size(seedval)), [1 nseeds])
	      error('Seed vector must be scalar or length nseeds')
	else
	      seedval = seedval(:);   %  Ensure a column vector
    end
end

%  Get seeds from a map.

if ismap
     [lat,long] = inputm(nseeds);

%  Adjust longitudes based upon whether maplegend starts above
%  or below zero.  In other words, allow for a 0 to 360 degree
%  longitude range as well as a -180 to 180 degree range.  Inputm
%  will always return a range from -180 to 180.

     if maplegend(3) >= 0
          long = zero22pi(long,getm(gca,'AngleUnits'),'exact');
     end

else
      [long,lat] = ginput(nseeds);     %  For displays of images
end




%  Set value for each location

if isempty(seedval)
    needseeds = 1;   answer{1} = '';
    prompt={'Enter the seed values for each location'};
 	title = ['Input for ',num2str(nseeds),' Seed Locations'];

	while needseeds
 	       answer=inputdlg(prompt,title,1,answer(1));
           if isempty(answer)
		          row = [];  col = [];   val = [];  return
		   end

		   value = str2num(answer{1})';

		   if length(value) == nseeds
		          needseeds = 0;
		   else
		          uiwait(errordlg('Incorrect number of seeds',...
				            'Seed Value Error','modal'));
		   end
    end

else
    value = seedval;
end

%  Convert lat, long degree data to cell positions.

[row,col,badpts] = setpostn(map,maplegend,lat,long);
if ~isempty(badpts);   value(badpts) = [];   end

%  Set the output matrix if necessary

if nargout <= 1;    row = [row col value]; end

