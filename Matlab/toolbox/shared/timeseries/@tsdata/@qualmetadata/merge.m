function outmetadata = merge(in1, in2)
%MERGE For merging qualmetadata in overloaded arithmatic and concatonation
%
% If quality tables are nested merge returns the description with more info
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:31 $


% Is in1 subset of in2?
[junk,I] = ismember(in1.Code,in2.Code);
I = find(I);
if length(I)==length(in1.Code) && ~isempty(in1.Code) &&  isequal(in1.Description,in2.Description(I))
    outmetadata = in2.copy;
    return
end

% Is in1 subset of in2?
[junk,I] = ismember(in2.Code,in1.Code);
I = find(I);
if length(I)==length(in2.Code) && ~isempty(in2.Code) &&  isequal(in2.Description,in1.Description(I))
    outmetadata = in1.copy;
    return
end
    
outmetadata = tsdata.qualmetadata;
