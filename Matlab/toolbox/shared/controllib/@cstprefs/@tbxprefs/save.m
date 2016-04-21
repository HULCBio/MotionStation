function save(h,filename)
%SAVE  Save Toolbox Preferences to disk

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:53 $

if nargin<2
   %---If no file name is specified, save to default preference file
   filename = h.defaultfile;
end

%---We need to save the preferences in structure 'p'
p = get(h);

%---Write preferences to disk
save(filename,'p');
