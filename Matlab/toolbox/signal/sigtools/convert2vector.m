function h = convert2vector(h)
%CONVERT2VECTOR Convert data structure to vector
%   CONVERT2VECTOR(H) Convert data structure H to vector.  H can be any
%   MATLAB datatype, i.e. a structure, matrix, cell array, cell array of 
%   structures, etc.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:31:29 $

% In r13 see if this can be a static method of siggui

if isstruct(h),
    
    % Convert Structure to Vector
    h = struct2vector(h);
elseif iscell(h),
    
    % Convert Cell array to Vector
    h = cell2vector(h);
else
    
    % Make sure that the vector is a row vector
    h = transpose(h(:));
end


% --------------------------------------------------------------
function h = struct2vector(h)

% Loop over the structure in case of a vector of structures
hnew = {};
for i = 1:length(h)
    hnew = {hnew{:} struct2cell(h(i))};
end

h = cell2vector(hnew);


% ---------------------------------------------------------------
function h = cell2vector(h)

for i = 1:length(h)
    h{i} = convert2vector(h{i});
end

h = [h{:}];
