function fname = dteds(latlim,lonlim,level)
%DTEDS U.S. Department of Defense Digital Terrain Elevation Data file names.
%
%  FNAME = DTEDS(latlim,lonlim) return 'Level 0' DTED file names 
%  (directory and name) required to cover the geographic region specified
%  by LATLIM and LONLIM.
%
%  FNAME = DTEDS(latlim,lonlim,level) return DTED file names  (directory
%  and name) required to cover the geographic region specified by LATLIM
%  and LONLIM.  Valid inputs for the LEVEL of the DTED files include 0, 1,
%  or 2.
%
%  DTED files contain digitial elevation maps covering 1 by 1 degree 
%  quadrangles at horizontal resolutions ranging from about 1 kilometer to
%  1  meter.  The 1 kilometer data is available online at 
%      http://164.214.2.59/geospatial/products/DTED/dted.html 
%  The higher resolution data is available to the U.S. Department of Defense 
%  and its contractors from the National Imagery and Mapping Agency (NIMA).
%
%  A third-party description of the DTED data may be found at:
%        http://www.fas.org/irp/program/core/dted.htm
%  Detailed official documentation is available at:
%        http://164.214.2.59/publications/specs/printed/DTED/dted1-2.doc
%
% See also DTED.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  L. Job, W. Stumpf
%  $Revision: 1.1.6.1 $ $Date: 2003/08/01 18:20:54 $

% DTED0 is 120x120
% DTED1 is 1201x1201
% except at higher latitudes, where there are fewer longitude records

error(nargchk(2,3,nargin));

if nargin < 3
    level = 0;
end
ext = sprintf('dt%d',level);

% Truncate the limits since DTED is read in 1 deg x 1 deg square tiles
latmin = floor(latlim(1));
latmax = floor(latlim(2));
lonmin = floor(lonlim(1));
lonmax = floor(lonlim(2));

% define columns and rows for tiles to be read
uniquelons = [lonmin:lonmax];
uniquelats = [latmin:latmax];
londir{length(uniquelons)} = '';
latdir{length(uniquelats)} = '';
dtedfile{length(uniquelons),length(uniquelats)} = '';

% redefine uniquelons if lonlim extends across the International Dateline
if lonmin > lonmax
	indx1 = [lonmin:179];
	indx2 = [-180:lonmax];
	uniquelons = [indx1 indx2];
end	

[latdir,londir] = dteddirs(uniquelons,uniquelats,ext);

% define the file names
fname{length(uniquelons),length(uniquelats)} = [];
for i = 1:length(uniquelons)
	for j = 1:length(uniquelats)
		fname{i,j} =[londir{i},latdir{j}];
	end
end
fname = fname(:);

%--------------------------------------------------------------------------

function [latdir,londir] = dteddirs(uniquelons,uniquelats,ext)

hWestEast = 'wee';
londir{length(uniquelons)} = [];
for i = 1:length(uniquelons)                                              
    londir{i} = sprintf('dted%c%c%03d%c', filesep,...
        hWestEast(2+sign(uniquelons(i))), abs(uniquelons(i)), filesep);                                             
end	                                                                       

hSouthNorth = 'snn';
latdir{length(uniquelats)} = [];
for i = 1:length(uniquelats)                                              
	latdir{i} = sprintf( '%c%02d.%s',...
        hSouthNorth(2+sign(uniquelats(i))), abs(uniquelats(i)), ext);                
end
