function [msg,value] = scalevaluescheck(Hq,value)
%SCALEVALUESCHECK Check the scale values for QFILT object.
%   [S,MSG] = SCALEVALUESCHECK(Hq,S) checks that the value of S is
%   appropriate for the Hq.scalevalues property where Hq is a QFILT
%   object.  If it is wrong, then an appropriate error message is
%   returned in string MSG.  If it is right, then MSG is empty.  S must
%   be numeric and a scalar or empty, or a vector of length Hq.numberofsections.
%   If no error, then S is returned with the correct scale value.  Empty
%   scale values are not expanded.  If the number of scale values does not
%   match the number of sections, then any scaling at the end is skipped.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:28:31 $

msg = '';
if nargin<2
  value = get(Hq,'scalevalues');
end
if ~isnumeric(value)
  error('ScaleValues must be numeric.');
end
if ~isreal(value)
  error('ScaleValues must be real.');
end
if ~isempty(value)
  value = value(:).';
end
if prod(size(value))~=1
  if length(value) > numberofsections(Hq)+1;
    msg = 'The length of ScaleValues must be no greater than length NumberOfSections+1.';
  end
end

