function M = laurmat(V)
%LAURMAT Constructor for the class LAURMAT (Laurent Matrix).
%   M = LAURMAT(V) returns a the Laurent matrix object M associated to V
%   which can be a cell array (at most two dimensional) of Laurent
%   polynomials (see LAURPOLY) or an ordinary matrix.
%
%   Examples:
%      M1 = laurmat(eye(2,2))
%      Z  = laurpoly(1,1);
%      M2 = laurmat({1 Z;0 1})
%
%   See also LP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision: 16-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:39:15 $

%===============================================
% Class LAURMAT (Parent objects: None)
% Fields:
%   Matrix - cell array of Laurent polynomials.
%===============================================

switch nargin
	case 0 , V = laurpoly(1,0);
end

% Built object.
%--------------
if isa(V,'laurmat')
    M = V; 
    return
elseif isnumeric(V)
    V = num2cell(V);
elseif isa(V,'laurpoly')
    V = {V};
elseif ~iscell(V)
    error('Invalid argument value.')
end
[nbRow,nbCol] = size(V);
for j=1:nbRow
    for k=1:nbCol
        if ~isa(V{j,k},'laurpoly'),
            if isnumeric(V{j,k}), 
                V{j,k} = laurpoly(V{j,k},0);
            else 
                error('Invalid argument value.')
            end
        end
    end
end
M = struct('Matrix',{V});
M = class(M,'laurmat');
