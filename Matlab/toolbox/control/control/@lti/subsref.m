function L = subsref(L,Struct)
%SUBSREF  LTI property management in referencing operation.
%
%   RESULT.LTI = SYS.LTI(Outputs,Inputs) sets the LTI properties
%   of the subsystem produced by
%            RESULT = SYS(Outputs,Inputs) .
%
%   See also TF/SUBSREF.

%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:47:40 $

% RE: * restricted to referencing of the form
%           sys(row_indices,col_indices)
%     * minimal error checking

indices = Struct(1).subs;
if ~strcmp(Struct(1).type,'()'),
    error('This type of referencing is not supported for LTI objects.')
end
indrow = indices{1};
indcol = indices{2};

% Delete Notes and UserData
L.Notes = {};
L.UserData = [];

% Check for duplicated I/O names
if isDuplicated(L.OutputName,indrow) | ...
        isDuplicated(L.InputName,indcol)
    warning('Some I/O names have been duplicated.')
end

% Set output names and output groups
L.OutputName = L.OutputName(indrow,1);
L.OutputGroup = groupref(L.OutputGroup,indrow);

% Set input names and input groups
L.InputName = L.InputName(indcol,1);
L.InputGroup = groupref(L.InputGroup,indcol);

% Update delays
L.ioDelay = L.ioDelay(indices{1:min(ndims(L.ioDelay),end)});
L.InputDelay = ...
    L.InputDelay(indcol,:,indices{3:min(end,ndims(L.InputDelay))});
L.OutputDelay = ...
    L.OutputDelay(indrow,:,indices{3:min(end,ndims(L.OutputDelay))});

%-------------------------------------------------------------

function boo = isDuplicated(Names,Indices)
% Checks for I/O name duplications as in sys(:,[1 1])
if isa(Indices,'char')
    boo = 0;
else
    Indices = sort(Indices);
    boo = ~all(cellfun('isempty',Names(Indices(~diff(Indices)))));
end
