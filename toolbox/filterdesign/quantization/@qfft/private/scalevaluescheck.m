function [msg,value] = scalevaluescheck(F,value)
%SCALEVALUESCHECK Check the scale values for QFFT object.
%   [S,MSG] = SCALEVALUESCHECK(F,S) checks that the value of S is
%   appropriate for the F.scalevalues property where F is a QFFT
%   object.  If it is wrong, then an appropriate error message is
%   returned in string MSG.  If it is right, then MSG is empty.  S must
%   be numeric and a scalar, or a vector of length F.numberofsections.
%   If no error, then S is returned with the correct scale value.  This
%   allows for expanding empty scale values.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:25:23 $

msg = '';
if nargin<2
  value = get(F,'scalevalues');
end
if isempty(value)
  value = 1;
end
if ~isnumeric(value)
  error('ScaleValues must be numeric.');
end
if ~isreal(value)
  error('ScaleValues must be real.');
end
if prod(size(value))~=1
  if length(value) ~= numberofsections(F)
    msg = 'ScaleValues must be a scalar or a vector of length NumberOfSections.';
  end
end
value = value(:)';
