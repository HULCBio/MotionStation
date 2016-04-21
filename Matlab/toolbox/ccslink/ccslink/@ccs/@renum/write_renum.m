function resp = write_renum(rs,index,data)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/11/30 23:11:10 $

error(nargchk(2,4,nargin));
if ~ishandle(rs),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RENUM Handle.');
end
if nargin==2,   
    data = index;
end

if ~isempty(setdiff(data,rs.label))
    error(generateccsmsgid('InvalidEnumValue'),['Input data contains at least one label that does not match any defined enumerated value.']);
end

if ischar(data),
    data = equivalent(rs,data);
elseif iscellstr(data),
    if length(data)>1
        warning(generateccsmsgid('TooManyData'),'DATA has more elements than the specified enum array, DATA will be limited to the defined register area. ');
    end
    data = equivalent(rs,data{1});
end

if nargin==2,
    write_rnumeric(rs,data);
else
    write_rnumeric(rs,index,data);
end
    
% [EOF] write_renum.m