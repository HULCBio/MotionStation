function refresh(this)
%REFRESH  Adjusts visibility of HG objects when visible 
%         portion of the axes grid changes.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:26 $

% RE: Used to
%   1) Reset visibility of g-objects when overall plot becomes visible 
%      (may go out of sync while plot is hidden)
%   2) Adjust g-object visibility inside grouped axes (cannot rely on 
%      ContentsVisible for toggling I/O visibility in grouped axes because
%      parent axes does not go invisible)
%   The visibility of g-objects within ungrouped axes is tied to the axes 
%   visibility via the ContentsVisible property.

% Adjust visibility of waveforms
Mask = refreshmask(this);
Waves = allwaves(this);
% REVISIT: next line should work when wf initialized to handle(0,1)
% for r=find(wf,'Visible','on')'
for wf=Waves(strcmp(get(Waves,'Visible'),'on'))'
   refresh(wf,Mask);
end
