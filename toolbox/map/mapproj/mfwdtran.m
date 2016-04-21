function [x,y,z,savepts] = mfwdtran(varargin)
%MFWDTRAN  Process forward transformation.
%
%  [X, Y] = MFWDTRAN(LAT, LON) processes the map forward transformations
%  using the map projection defined in the current axes.  Using this
%  function, Greenwich data is transformed  to the cartesian coordinate
%  frame.  No clipping or trimming of the data is performed in this form.
%
%  [X, Y, Z] = MFWDTRAN(LAT, LON, ALT) transforms the 3 dimensional data to
%  the projected coordinate system.  If ALT = [] is  supplied or ALT is
%  omitted, then ALT = 0.
%
%  [X, Y, Z, STRCT] = MFWDTRAN(LAT, LON, ALT, OBJECT) clips and trims the
%  OBJECT data during this projection process.  The output STRCT is a
%  structure which is associated with each OBJECT displayed.  It contains
%  information regarding the clips and trims associated  with the OBJECT.
%  This information is computed in each projection  m-file.  In addition,
%  this structure is associated with each  displayed OBJECT in the OBJECT's
%  user data.  This association is  performed as part of the display
%  process.
%
%   Allowable OBJECT strings are 'surface' for map graticules; 
%  'line' for line objects; 'patch' for patch objects; 'light' for light
%  objects; 'text' for text objects; 'none' for no clipping  and trimming
%  of input data.
%
%  [...] = MFWDTRAN(MSTRUCT,...) assumes that a valid map  structure is
%  supplied as the first argument.  This structure is used to define the
%  map projection calculation performed.  No map axes need be displayed
%  when using this form.
%
%  See also MAPS, MINVTRAN, PROJFWD, PROJINV, PROJLIST.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:59:02 $
%  Written by:  E. Byrns, E. Brown

if isstruct(varargin{1})       %  Map structure provided as first argument
    mstruct = varargin{1};
    if nargin == 3
		 lat = varargin{2};   lon = varargin{3};
         alt = [];            object = 'none';

    elseif nargin == 4
		 lat = varargin{2};   lon = varargin{3};
         alt = varargin{4};   object = 'none';

    elseif nargin == 5
		 lat = varargin{2};   lon = varargin{3};
		 alt = varargin{4};   object = varargin{5};
    else
         error('Incorrect number of arguments')
    end

else                     %  No structure provided.  Get from current axes
    mstruct = [];
    if nargin == 2
		 lat = varargin{1};   lon = varargin{2};
         alt = [];            object = 'none';
    elseif nargin == 3
		 lat = varargin{1};   lon = varargin{2};
         alt = varargin{3};   object = 'none';
    elseif nargin == 4
		 lat = varargin{1};   lon = varargin{2};
         alt = varargin{3};   object = varargin{4};
    else
         error('Incorrect number of arguments')
    end
end

%  Set the altitude to zero in case of an empty argument

if isempty(alt);   alt = zeros(size(lat));   end

%  To deal with vertical data on the map and proper DataAspectRatio
%  One possibility:  Assume that z is in the same units as
%  lat and long.  Transform based upon this assumption.  Note that
%  the default altitude should then be geoid(1).  What does this
%  mean for a globe?  This is the forward transformation below

%     geoid = getm(gca,'Geoid');
%     units = getm(gca,'AngleUnits');
%     alt = angledim(alt,units,'radians');
%	  alt = alt*geoid(1);


%  Initialize the output arguments

x = [];  y = [];  z = [];   savepts = [];

%  Get the current projection data

if isempty(mstruct)
    [mstruct,msg] = gcm;
    if ~isempty(msg);   error(msg);   end
end

%  Test for a non-zero radius

if mstruct.geoid(1) == 0;  error('Non-zero Geoid radius needed');  end

%  Transform the map data

if ~strcmp(mstruct.mapprojection,'globe')
     [x,y,savepts] = feval(mstruct.mapprojection,mstruct,...
	                       lat,lon,object,'forward');

     switch  object      %  Adjust for clipped data in objects
	     case 'line',   z = zline(x,alt,savepts.clipped);
	     case 'patch',  z = alt(ones(size(x)));

		 case 'light'         %  Eliminate any lights which have been trimmed
		    z = alt;          %  Set the altitude data

			indx = find(isnan(x) | isnan(y));
			if ~isempty(indx)
                  x(indx) = [];   y(indx) = [];   z(indx) = [];
		    end

			savepts.clipped = [];     %  Clear any clip or trim markers
			savepts.trimmed = [];

		 otherwise,     z = alt;
	 end
else
     [x,y,z] = globe(mstruct,lat,lon,alt,object,'forward');
     savepts.trimmed = [];
     savepts.clipped = [];

end


%***********************************************************************
%***********************************************************************
%***********************************************************************

function zout = zline(x,z,clippts)

%ZLINE  Fill z line vector data to correspond with clipped x and y vectors
%
%  Synopsis
%
%           zout = zline(x,z,clippts)
%
%           x and clippts are outputs from CLIPDATA
%           z is original unclipped data
%
%       See also CLIPDATA, UNDOCLIP, UNDOLINE

if nargin ~= 3;    error('Incorrect number of arguments');    end

if ndims(z) > 2;  error('Input z can not have pages');  end

if size(z,1) == 1      %  Algorithm requires column vectors
      z = z';          %  X input will be made a column in clipline
end


if isempty(clippts)      %  No clips required
    zout = z;    return
end

%  Initialize needed data

[xrow,xcol] = size(x);
[zrow,zcol] = size(z);

zout = z;                 %  Ensure that columns with no clips are copied
                          %  and padded with NaNs at the end

fillrows = zrow+1:xrow;   %  Fill in extra rows with NaNs
if ~isempty(fillrows);  zout(fillrows,:) = NaN;   end

%  Adjust the z data column by column.  Place NaNs in the
%  z data column where the clipping process placed them in
%  the x data.  Shift the vector for the inclusion of this NaN.

for i = 1:zcol
      indx = find(clippts(:,2) == i);    %  Clip points for this column
	  if ~isempty(indx)
	      column = z(:,i);                    %  One column of data
          locations = sort(clippts(indx,3));  %  All the clip points
	      for j = length(locations):-1:1      %  Shift the vector and fill NaNs
	           lowerindx = 1:locations(j);
	           upperindx = locations(j)+1 : zrow+length(locations)-j;
               column = [column(lowerindx); NaN; column(upperindx)];
		  end

		  zout(1:length(column),i) = column;   %  Replace this column of data
	   end
end

