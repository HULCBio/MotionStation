function h = dataset(data,time,varargin)
%DATASET
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:25 $

h = preprocessgui.dataset;
h.Data = data;
h.Time = time;
if nargin==2
    h.Name = 'default';
end
h.headings = cell(size(data,2),1);
for k=1:size(data,2)
   h.headings{k} = ['Column ' num2str(k)];
end