function index = p_index2count(rn,index)
% P_INDEX2COUNT Private. Converts table of indices into a list of counts.
% Example:
% 	index = [[1 1],[1 1],[1 1]]
% 	rn.size = [1 1]
% 	index = p_index2count(rn,index)
% 	index = 
%       1
%       1
%       1
% Note: 'index' passed to p_index2count is assumed to be an array of 1's

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:11:40 $

% Reshape index (number of indices x indices)
try
    index = reshape(index,length(rn.size),[])';
catch
    errId = ['MATLAB:RNUMERIC_' mfilename '_m'];
    error(errId,sprintf([lasterr '\n'...
            'Index array must be an (N x '  num2str(length(rn.size)) ') vector.' ]));
end
% Check index has at least >1 row-index
for subscript = index',
    if any(subscript' > rn.size),
      error(['INDEX has an entry: [' num2str(subscript') '], which exceeds the defined size of object.']);
    end
end

% 'arrayorder' does not apply to this processor, therefore, there's not need to check

index = ones(size(index,1),1); % column of ones, each element representing a value requested 

% [EOF] p_index2count.m