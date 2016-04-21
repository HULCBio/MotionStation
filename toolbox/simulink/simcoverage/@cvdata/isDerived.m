function result = isDerived(Obj)

%Get object ID

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/23 03:02:52 $
id = Obj.id;

%No short-circuit and cv call may return []
result = (id == 0);
if ~result
	result = cv('get', id, 'testdata.isDerived');
end;
