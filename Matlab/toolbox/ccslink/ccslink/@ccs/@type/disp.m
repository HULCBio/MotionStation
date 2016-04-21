function disp(td)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:13:57 $

fprintf('\n  Defined types    : ');
len = length(td.typename);
if len==0,
    fprintf('None');
else
	for i=1:len-1,
	fprintf('%s, ', td.typename{i});
	end
	fprintf('%s ', td.typename{len});
end

% [EOF] disp.m