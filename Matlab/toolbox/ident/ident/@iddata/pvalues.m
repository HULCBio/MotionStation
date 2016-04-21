function Values = pvalues(dat)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(DAT)  returns the list of values of all
%   public properties of the object DAT.  VALUES is a cell vector.
%
%   See also  GET.

 %       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.6 $  $Date: 2001/04/06 14:22:02 $

Npublic = 17;  % Number of IDDATA-specific public properties

% Values of public IDDATA-specific properties
Values = struct2cell(dat);
Values = Values(1:Npublic);

 

% end iddata/pvalues.m
