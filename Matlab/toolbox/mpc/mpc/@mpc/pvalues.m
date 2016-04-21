function Values = pvalues(mpcobj)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(MPCOBJ)  returns the list of values of all
%   public properties of the object MPCOBJ.  VALUES is a cell vector.
%
%   See also  GET.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.10.3 $  $Date: 2003/12/04 01:32:50 $   


Npublic = 14;  % Number of MPC-specific public properties

% Values of public LTI properties

Values = struct2cell(mpcobj);
Values = Values(1:Npublic);


% end mpc/pvalues.m
