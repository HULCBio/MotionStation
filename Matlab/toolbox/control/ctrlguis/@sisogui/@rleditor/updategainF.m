function updategainF(Editor)
%UPDATEGAINF  Root locus plot update when modifying the filter gain.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 04:58:35 $

% RE: Assumes gain does not change sign

if Editor.LoopData.Configuration==4
   % Change in F affects open loop model --> do full update
   update(Editor)
end

