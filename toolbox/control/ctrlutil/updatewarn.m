function updatewarn
%UPDATEWARN  output a warning when LOADOBJ routines are called

%   Author(s): G. Wolodkin 03/15/2000
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 06:39:02 $

persistent last_old_object;

if isempty(last_old_object) | (etime(clock, last_old_object) > 1)
  disp('Updating LTI objects saved with previous MATLAB version...')
  disp('Resave your MAT files to improve loading speed.');
end
last_old_object = clock;
