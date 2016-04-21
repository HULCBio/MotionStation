function setMember(hObj, memberName, data)
%SETDATA  Update a member's data.

idx = strcmp(hObj.MemberNames, memberName);

if (~any(idx))
    error('Invalid member name.')
end

if ((~isnumeric(data)) && (~isa(data, 'hdf5.hdf5type')))
    error('Data must be numeric or a subclass of hdf5type.')
elseif (numel(data) > 1)
    error('Data must contain a single value.')
end

hObj.Data{idx} = data;
