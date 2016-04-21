function y = dbtbx()
%DBTBX Construct Database Toolbox object.

%   Author(s): C.F.Garvin, 10-30-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.5 $   $Date: 2002/06/17 12:01:36 $

x.dumfld = [];             %Need field placeholder to create object
y = class(x,'dbtbx');
