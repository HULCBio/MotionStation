function [lat,lon] = singlenan(lat,lon)
% SINGLENAN removes duplicate nans in lat-long vectors

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:39 $

if ~isempty(lat)
    nanloc = isnan(lat);	[r,c] = size(nanloc);
    nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
    lat(nanloc) = [];  lon(nanloc) = [];
end
