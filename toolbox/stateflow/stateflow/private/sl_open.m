function h = sl_open(blkpath)
%
% Silently loads a Simulink model given its name.
%

%
% Insure that the source model is in memory
%

%   Jay Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 01:00:25 $

   ind = find('/'==blkpath);
   modelName = blkpath(1:(ind(1)-1));
   %
   % Avoid recursion at load time by checking to see if it's in memory already
   if isempty(find_system('Name', modelName')),
      sf_load_model(modelName);
   end;

	h = get_param(blkpath, 'handle');
