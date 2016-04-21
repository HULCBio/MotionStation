function result = parseRTWBuildArgs_DSPtarget(args, token)
% example:
%     args   = 'TARGET_TYPE="C6701EVM" SELECTION_METHOD="Manual"';
%     token  = 'TARGET_TYPE';
%     parseRTWBuildArgs_DSPtarget(args,token);
% returns 'C6701EVM'

% $RCSfile: parseRTWBuildArgs_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:10 $
% Copyright 2001-2003 The MathWorks, Inc.

% extract out everything up to and including the token (and the = sign)
tmp = args(findstr(args,token)+length(token)+1:end);

% truncate everything after the next space
[result,tmp] = strtok(tmp);

% strip out double quotes if any exist
if ~isempty(result),
	i = find(result=='"');
    result(i) = '';
end

% [EOF] parseRTWBuildArgs_DSPtarget.m
