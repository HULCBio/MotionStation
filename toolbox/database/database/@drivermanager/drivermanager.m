function d = drivermanager()
%DRIVERMANAGER Construct database drivermanager object.
%   D = DRIVERMANAGER constructs a database drivermanager object.  The 
%   drivermanager object is used to call methods that return and modify 
%   the properties of the set of loaded database drivers as a whole.
%
%   See also GET, SET.

%   Author(s): C.F.Garvin, 07-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.6 $   $Date: 2002/06/17 12:00:56 $

%Create parent object for generic methods
dbobj = dbtbx;

%Build dummy structure to create drivermanager object
t.type = 'DriverManager';

%Return drivermanager object
d = class(t,'drivermanager',dbobj);
