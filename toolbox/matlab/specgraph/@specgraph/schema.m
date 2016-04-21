function schema
%creates the SPECGRAPH user object package

%   Copyright 1984-2003 The MathWorks, Inc.

schema.package('specgraph');

if( isempty(findtype('ChartDirtyEnum')) )
  schema.EnumType('ChartDirtyEnum',{'clean','invalid','inconsistent'});
end
