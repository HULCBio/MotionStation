function [lat,lon,alt] = minvtran(varargin)
%MINVTRAN Process inverse transformation.
%
%  [LAT, LON] = MINVTRAN(X, Y) processes the map inverse  transformations
%  using the map projection defined in the current axes.  Cartesian data is
%  transformed to the  Greenwich coordinate frame.  No clipping or trimming
%  of the data are removed in this form.
%
%  [LAT, LON, ALT] = MINVTRAN(X, Y, Z) transforms the 3 dimensional data
%  from the projected space to the Greenwich coordinate system. If Z = []
%  is supplied or is omitted, then Z = 0 is assumed.
%
%  [LAT, LON, ALT] = MINVTRAN(X, Y, Z, OBJECT, STRCT) removes all clips and
%  trims from the input data. The input STRCT is a structure  which is
%  associated with each  OBJECT displayed.  It contains  information
%  regarding the clips and trims associated with the  object.  This is
%  returned from the function MFWDTRAN.
%
%  Allowable OBJECT strings are 'surface' for map graticules;  'line' for
%  line objects; 'patch' for patch objects; 'light' for light objects;
%  'text' for text objects; 'none' for no clipping and trimming of input
%  data.
%
%  [...] = MINVTRAN(MSTRUCT,...) assumes that a valid map  structure is
%  supplied as the first argument.  This structure is used to define the
%  map projection calculation performed.  No map axes need be displayed
%  when using this form.
%
%  See also MAPS, MFWDTRAN, PROJFWD, PROJINV, PROJLIST.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/02/01 21:59:03 $
%  Written by:  E. Byrns, E. Brown

if isstruct(varargin{1})       %  Map structure provided as first argument
    mstruct = varargin{1};
    if nargin == 3
		 x = varargin{2};         y = varargin{3};
		 z = [];                  object = 'none';
	     savepts.trimmed = [];    savepts.clipped = [];
    elseif nargin == 4
		 x = varargin{2};         y = varargin{3};
		 z = varargin{4};         object = 'none';
	     savepts.trimmed = [];    savepts.clipped = [];
    elseif nargin == 6
		 x = varargin{2};   y = varargin{3};   z = varargin{4};
         object = varargin{5};   savepts = varargin{6};
    else
         error('Incorrect number of arguments')
    end

else                     %  No structure provided.  Get from current axes
    mstruct = [];
    if nargin == 2
		 x = varargin{1};       y = varargin{2};
         z = [];                object = 'none';
	     savepts.trimmed = [];  savepts.clipped = [];
    elseif nargin == 3
		 x = varargin{1};       y = varargin{2};
         z = varargin{3};       object = 'none';
	     savepts.trimmed = [];  savepts.clipped = [];
    elseif nargin == 5
		 x = varargin{1};   y = varargin{2};   z = varargin{3};
         object = varargin{4};   savepts = varargin{5};
    else
         error('Incorrect number of arguments')
    end
end

%  Set the z plane to zero in case of an empty argument

if isempty(z);   z = zeros(size(x));   end

%  Initialize the output arguments

lat = [];  lon = [];    alt = [];

%  Get the current projection data if necessary

if isempty(mstruct)
    [mstruct,msg] = gcm;
    if ~isempty(msg);   error(msg);   end
end

%  Test for a non-zero radius

if mstruct.geoid(1) == 0;  error('Non-zero Geoid radius needed');  end


%  To deal with vertical data on the map and proper DataAspectRatio
%  One possibility:  Assume that z is in the same units as
%  lat and long.  Transform based upon this assumption.  Note that
%  the default altitude should then be geoid(1).  What does this
%  mean for a globe?  This is the forward transformation below

%     geoid = getm(gca,'Geoid');
%     units = getm(gca,'AngleUnits');
%     alt = angledim(alt,units,'radians');
%	  alt = alt*geoid(1);


%  Transform the map data

if ~strcmp(mstruct.mapprojection,'globe')
    [lat,lon] = feval(mstruct.mapprojection,mstruct,...
	                  x,y,object,'inverse',savepts);

    alt = z;

    if ~isempty(savepts.clipped)
         switch  object      %  Adjust for clipped data in line objects
	         case 'line',    alt(savepts.clipped(:,1)) = [];
	     end
    end
else
    [lat,lon,alt] = globe(mstruct,x,y,z,object,'inverse');
end

%  Set the altitude variable if the object is a patch
%  Patches can only have a scalar altitude variable

if strcmp(object,'patch');   alt = z(1);   end

