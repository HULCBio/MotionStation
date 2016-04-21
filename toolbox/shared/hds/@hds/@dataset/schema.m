function schema
% Defines properties for @dataset class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:29:25 $

% Register class 
pk = findpackage('hds');
c = schema.class(pk,'dataset',findclass(pk,'AbstractDataSet'));

% Public properties
p = schema.prop(c,'MetaData','MATLAB array');  % Meta data
p.GetFunction = @localGetMetaData;


function s = localGetMetaData(this,v)
s = getMetaData(this);