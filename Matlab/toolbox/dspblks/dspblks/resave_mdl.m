function resave_mdl
% RESAVE_MDL Utility function for Signal Processing Blockset.
%   Opens, re-saves, then closes all MDL files in the current directory.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:05:26 $

d=dir('*.mdl');
for i=1:length(d),
   [path,name,ext] = fileparts(d(i).name);
   open_system(name);
   close_system(name,1);  % save and close
end
