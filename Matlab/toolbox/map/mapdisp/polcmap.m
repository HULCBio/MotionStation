function out = polcmap(varargin)
%POLCMAP colormap for political maps
%
% POLCMAP applies a random muted colormap. The size of the colormap
% is the same as the current figure's existing colormap.
%
% POLCMAP(ncolors) creates a colormap with the specified number of colors
%
% POLCMAP(ncolors,maxsat) controls the maximum saturation of the colors. 
% Larger maximum saturation values produce brighter, more saturated colors. 
% If omitted, the default is 0.5.
%
% POLCMAP(ncolors,huelimits,saturationlimits,valuelimits) controls the colors. 
% Hue, saturation and value are randomly selected values within the limit 
% vectors. These are two-element vector of the form [min max]. Valid 
% values range from 0 to 1.  As the hue varies from 0 to 1, the resulting 
% color varies from red, through yellow, green, cyan, blue and magenta, 
% back to red. When the saturation is 0, the colors are unsaturated; they are
% simply shades of gray.  When the saturation is 1, the colors are fully 
% saturated; they contain no white component.  As the value varies from 
% 0 to 1, the brightness increases.
%
% cmap = POLCMAP(...) returns the colormap without applying it to the figure.
%
% See also DEMCMAP, COLORMAP

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%   $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:19:17 $


if ~ismember(nargin,[0 1 2 4])
	error('Incorrect number of input arguments')
end

if nargin == 0, 
	m = size(get(0,'DefaultFigurecolormap'),1); 
else
	m= varargin{1};
end

if nargin <= 1 % POLCMAP(ncolors)
	huelims = [0 1];
	satlims = [.25 .5];
	vallims = [1 1];
end

if nargin == 2 % POLCMAP(ncolors,maxsat)
	huelims = [0 1];
	satlims = [0 varargin{2}];
	vallims = [1 1];
end

if nargin == 4 % POLCMAP(ncolors,huelimits,saturationlimits,valuelimits)
	huelims = varargin{2};
	satlims = varargin{3};
	vallims = varargin{4};
end


randomvalues = rand(m,1);
randomhues = huelims(1) + randomvalues*diff(huelims);

randomvalues = rand(m,1);
randomsats = satlims(1) + randomvalues*diff(satlims);

randomvalues = rand(m,1);
randomvals = vallims(1) + randomvalues*diff(vallims);

hsv = [randomhues randomsats randomvals];

map = hsv2rgb(hsv);

if nargout == 1
	out = map;
else
	colormap(map);
end

