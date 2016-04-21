function result = upfind(varargin)
%upfind(object, options)
%  Finds objects underneath object's parent.
%   shorthand for object.up.find(options)
%
%	Tom Walsh
%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/15 01:01:30 $

objects = varargin{1};
options = varargin;
options(1) = [];

parents = [];

for i=1:length(objects)
    parents = [parents up(objects(i))];
end
    
result = find(parents, options);


