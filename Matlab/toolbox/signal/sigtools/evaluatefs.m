function fs = evaluatefs(str)
%EVALUATEFS  Evaluate sampling frequency input.
%   FS = EVALUATEFS(STR) evaluates user input string STR and returns
%   scalar FS.  An error message is given if FS is negative, zero,
%   not numeric, or not a scalar.

%   Author: T. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:51:59 $

[fs,errmsg] = evaluatevars(str);
error(errmsg)
if ~isnumeric(fs)
  error('Fs must be numeric.')
end
if isempty(fs) | length(fs)>1
  error('Fs must be a scalar.');
end
if fs<=0
  error('Fs must be positive.')
end

% [EOF] evaluatefs.m