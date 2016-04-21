function fcnName = windowstrs2fcnnames(windowStrs)
% Convert window strings in popup to the actual window function names

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 23:45:57 $ 

% Get cell array with all windows names and fcn handles
[wincls,w] = findallwinclasses('nonuserdefined');

if iscell(windowStrs),
	for k = 1:length(windowStrs)
		fcnName{k} = convertstr2fcn(windowStrs{k},w,wincls);
	end
else
	fcnName = convertstr2fcn(windowStrs,w,wincls);
end

%----------------------------------------------------------------------
function fcnName = convertstr2fcn(windowStr,AllWindowStrs,fcnhndls)

indx = find(strcmpi(windowStr,AllWindowStrs));

fcnName = fcnhndls{indx};
