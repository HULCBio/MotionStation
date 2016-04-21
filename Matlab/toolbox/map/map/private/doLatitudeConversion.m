function latout = doLatitudeConversion(function_name,from,to,varargin)
% DOLATITUDECONVERSION  Compute engine for old latitude conversion functions.
%
%   See also:  AUT2GEOD, CEN2GEOD, CNF2GEOD, ISO2GEOD, GEOD2AUT,
%              GEOD2CEN, GEOD2CNF, GEOD2ISO, GEOD2PAR, GEOD2REC,
%              PAR2GEOD, REC2GEOD.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:58:07 $

[latin,ellipsoid,units] = parseLatConvInputs(function_name,varargin{:});
latin = angledim(latin,units,'radians');    %  Convert to radians
latout = convertlat(ellipsoid,latin,from,to,'nocheck');
latout = angledim(latout,'radians',units);  %  Convert to output units

%--------------------------------------------------------------------------

function [latin,ellipsoid,units] = parseLatConvInputs(function_name,varargin)

nargs = numel(varargin);
checknargin(1,3,nargs,function_name);

latin = varargin{1};
switch(nargs)
    case 1
        ellipsoid = almanac('earth','geoid');
	    units = 'degrees';
    case 2
        if ischar(varargin{2});
            ellipsoid = almanac('earth','geoid');
            units = varargin{2};
        else
            ellipsoid = varargin{2};
            units = 'degrees';
        end
    case 3
        ellipsoid = varargin{2};
        units = varargin{3};
end

ellipsoid = checkellipsoid(ellipsoid,function_name,'ELLIPSOID',2);
