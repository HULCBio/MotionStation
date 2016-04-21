function [scalevalues, msg] = scalvalexpand(Hq)
%SCALVALEXPAND  Returns the scale values as a vector.
%   [SCALEVALUES, MSG] = SCALVALEXPAND(Hq) returns the scale values of Qfilt
%   object Hq expanded as a vector SCALEVALUES, and a message if the
%   ScaleValues property is not set correctly.

%   Thomas A. Bryan, 14 July 1999
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/12 23:26:01 $

scalevalues = get(Hq,'ScaleValues');
nsections = get(Hq,'NumberOfSections');
msg='';

if ~isnumeric(scalevalues)
  msg = 'ScaleValues property of QFILT objects must be numeric.';
  return
end

if ~privisvector(scalevalues)
  msg = 'ScaleValues property of QFILT objects must be scalar or vector.';
  return
end

if ~isscalar(scalevalues) & length(scalevalues)~=nsections+1
  msg = ['ScaleValues property of QFILT objects must be a numeric scalar',...
        ' or vector of length NumberOfSections+1'];
  return
end

% Scalar expand if necessary
scalevalues = [scalevalues ones(1,nsections)];
