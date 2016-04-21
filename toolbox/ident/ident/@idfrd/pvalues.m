function Values = pvalues(dat)
%PVALUES  Values of all public properties of an object
%
%   VALUES = PVALUES(DAT)  returns the list of values of all
%   public properties of the object DAT.  VALUES is a cell vector.
%
%   See also  GET.

%       Author(s): P. Gahinet, 7-8-97
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.7 $  $Date: 2001/04/06 14:22:06 $

Npublic = 16;  % Number of IDFRD-specific public properties

% Values of public IDFRD-specific properties
Values = struct2cell(dat);
Values = Values(1:Npublic);
 
 

% end iddata/pvalues.m
