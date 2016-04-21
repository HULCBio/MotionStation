function Values = pvalues(mpcsimopt)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(MPCSIMOPT)  returns the list of values of all
%   public properties of the object MPCSIMOPT.  VALUES is a cell vector.
%
%   See also  GET.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:12 $   

Npublic = 12;  % Number of MPCSIMOPT-specific public properties

% Values of public LTI properties

Values = struct2cell(mpcsimopt);
Values = Values(1:Npublic);


% end lti/pvalues.m
