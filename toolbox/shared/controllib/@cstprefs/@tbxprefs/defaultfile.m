function filename = defaultfile(h)
%DEFAULTFILE  Get name of user's default preference file

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:48 $

filename = [prefdir(1) filesep 'cstprefs.mat'];
