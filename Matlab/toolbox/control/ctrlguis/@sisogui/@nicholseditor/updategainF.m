function updategainF(Editor)
%UPDATEGAINF  Plot update when modifying the filter gain.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 05:05:51 $

if Editor.LoopData.Configuration==4
   % Change in F affects open loop model --> do full update
   update(Editor)
end
