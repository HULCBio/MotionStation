function xfocus = getfocus(this)
%GETFOCUS  Computes optimal X limits for wave plot 
%          by merging Focus of individual waveforms.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:47 $

% Collect time Focus for all visible MIMO responses
xfocus = cell(0,1);
for rct = allwaves(this)'
  % For each visible response...
  if rct.isvisible
    idxvis = find(strcmp(get(rct.View, 'Visible'), 'on'));
    xfocus = [xfocus ; get(rct.Data(idxvis), {'Focus'})];
  end
end

% Merge into single focus
xfocus = LocalMergeFocus(xfocus);

% Round it up
% REVISIT: should depend on units.
% Return something reasonable if empty.
if isempty(xfocus)
  xfocus = [0 1];
else
  xfocus(2) = tchop(xfocus(2));
end


% ----------------------------------------------------------------------------%
% Purpose: Merge all ranges
% ----------------------------------------------------------------------------%
function focus = LocalMergeFocus(Ranges)
% Take the union of a list of ranges
focus = zeros(0,2);
for ct = 1:length(Ranges)
  focus = [focus ; Ranges{ct}];
  focus = [min(focus(:,1)) , max(focus(:,2))];
end
