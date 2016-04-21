function [snew, perm] = orderfields(s1,s2)
% ORDERFIELDS Order fields of a structure array.
% 
% SNEW = ORDERFIELDS(S1) orders the fields in S1 so the new structure array
% SNEW has field names in ASCII dictionary order.
% 
% SNEW = ORDERFIELDS(S1, S2) orders the fields in S1 so the new structure
% array SNEW has field names in the same order as those in S2. Sl and S2
% must have the same fields.
% 
% SNEW = ORDERFIELDS(S1, C) orders the fields in S1 so the new structure
% array SNEW has field names in the same order as those in the cell array
% of field name strings in C. S1 and C must have the same field names.
% 
% SNEW = ORDERFIELDS(S1, PERM) orders the fields in S1 so the new structure
% array SNEW has fieldnames in the order specified by the indices in PERM.
% If S1 has N fieldnames, the elements of PERM must be a rearrangement of
% the numbers from 1 to N. This is particularly useful if you have more
% than one structure array that you would like to reorder, all in an
% identical way.
% 
% [SNEW, PERM] = ORDERFIELDS(...) returns a permutation vector representing
% the change in order performed on the fields of the structure array that
% results in SNEW.
%
% ORDERFIELDS only orders top-level fields (it is not recursive).
% 
% Examples:
%          s = struct('b',2,'c',3,'a',1);
%          snew = orderfields(s);
%          [snew, perm] = orderfields(s,{'b','a','c'});
%          s2 = struct('b',3,'c',7,'a',4);
%          snew = orderfields(s2,perm);
% 
% See also STRUCT, FIELDNAMES, ISFIELD, GETFIELD, SETFIELD, RMFIELD, 
% CELL2STRUCT, STRUCT2CELL.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/10 23:25:31 $

if ~isstruct(s1) 
    error('MATLAB:orderfields:arg1NotStruct', 'First argument must be a struct.');
end
if nargin < 2          % ORDERFIELDS(S1)
    % Get sorted s1 fields
    [newfields, perm] = sort(fieldnames(s1));
elseif isnumeric(s2)   % ORDERFIELDS(S1, PERM)
    perm = s2(:);
    newfields = fieldnames(s1);
    n = length(newfields);
    if ( length(perm) ~= n )
        error('MATLAB:orderfields:InvalidPermLength',...
            'Permutation vector length must be the same as the number of fields in the struct.');
    end
    newfields = newfields(perm);
elseif isstruct(s2)   % ORDERFIELDS(S1, S2)
    % Get sorted s1 fields
    [newfields1, perm1] = sort(fieldnames(s1));
    newfields = fieldnames(s2);
    [newfields2, perm2] = sort(newfields);
    if ~all(strcmp(newfields1,newfields2))
        error('MATLAB:orderfields:StructFieldMismatch',...
            'Both structures must have exactly the same fields.');
    end
    % perm1 maps original s1 order to alphabetical order
    % perm2 maps original s2 order to alphabetical order
    % invperm2 maps alphabetical order to original s2 order
    % perm1(invperm2) maps original s1 order to original s2 order
    invperm2(perm2) = (1:length(perm2))';
    perm = perm1(invperm2);
elseif iscell(s2)     % ORDERFIELDS(S1, C)
    % Get sorted s1 fields
    [newfields1, perm1] = sort(fieldnames(s1));
    [newfields2, perm2] = sort(s2(:));
    if ~all(strcmp(newfields1,newfields2))
        error('MATLAB:orderfields:CellStrMismatchFieldnames',...
            'The strings of the cell array must match the fieldnames of the struct.');
    end
    % perm1(invperm2) maps original s1 order to original s2 order
    invperm2(perm2) = (1:length(perm2))';
    perm = perm1(invperm2);
    newfields = s2;
else
    error('MATLAB:orderfields:InvalidArg2',...
        'Second argument must be struct, cell array of strings, or a permuation vector.');
end

% Handle struct arrays
origsize = size(s1);
valuesvector = struct2cell(s1(:));  
valuesvector(:,:) = valuesvector(perm,:);
% create the new struct with the re-ordered fields
snew = cell2struct(valuesvector,newfields,1);
snew = reshape(snew,origsize);
