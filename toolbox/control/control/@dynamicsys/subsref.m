function sys = subsref(sys,Struct)
%SUBSREF  Meta data management in referencing operation.

%   Author(s):  P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:12:49 $

% RE: restricted to referencing of the form
%           sys(row_indices,col_indices)
indices = Struct(1).subs;
indrow = indices{1};
if islogical(indrow)
   indrow = find(indrow);
end
indcol = indices{2};
if islogical(indcol)
   indcol = find(indcol);
end

% Delete Notes and UserData
sys.Notes = {};
sys.UserData = [];

% Check for duplicated I/O names
if isDuplicated(sys.OutputName,indrow) || ...
      isDuplicated(sys.InputName,indcol)
   warning('control:ioNameDuplicated','Some I/O names have been duplicated.')
end

% Set output names and output groups
sys.OutputName = sys.OutputName(indrow,1);
sys.OutputGroup = groupref(sys.OutputGroup,indrow);

% Set input names and input groups
sys.InputName = sys.InputName(indcol,1);
sys.InputGroup = groupref(sys.InputGroup,indcol);

%-------------------------------------------------------------

function boo = isDuplicated(Names,Indices)
% Checks for I/O name duplications as in sys(:,[1 1])
if isa(Indices,'char')
    boo = 0;
else
    Indices = sort(Indices);
    boo = ~all(cellfun('isempty',Names(Indices(~diff(Indices)))));
end
