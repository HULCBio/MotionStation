%% Provides the OpenFcn callback for blocks that are 'links' to TLC 
%% or C files.


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/10 18:39:33 $

function sfundemo_openfcn
  
  edit(sfundemo_helper(matlabroot));
  