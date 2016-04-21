%% Provides the paths for functions relating to blocks that 
%% are 'links' to TLC or C files.


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/10 18:39:39 $

function x = sfundemo_helper(root)
    
  shortFileName = get_param(gcb, 'filename');
  
  [path,name,ext,version] = fileparts(shortFileName);
  
  switch ext
   case '.tlc'
    midpath = fullfile('toolbox','simulink','blocks','tlc_c','');
   case '.c'
    midpath = fullfile('simulink','src','');
   otherwise
    midpath = '???';
  end
  
  x = fullfile(root, midpath, shortFileName);
  