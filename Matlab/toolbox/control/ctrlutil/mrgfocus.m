function focus = mrgfocus(FRanges,SoftFlags)
%MRGFOCUS  Merges frequency ranges into single focus.
%
%  FOCUS = MRGFOCUS(FRANGES,SOFTFLAGS) merges a list of ranges
%  into a single range. The bool vector SOFTFLAGS signals which
%  ranges are soft and can be  ignored when well separated from 
%  the remaining dynamics (these correspond to pseudo integrators 
%  or derivators, or response w/o dynamics)

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.2 $ $Date: 2002/04/10 06:39:11 $

% Merge well-defined ranges (SOFTRANGE=0)
focus = LocalMergeRange(FRanges(~SoftFlags));

% Incorporate soft range contribution (SOFTRANGE=1)
if isempty(focus)
    focus = LocalMergeRange(FRanges(SoftFlags));
else
    % Discard I/D ranges that are separated by at least 2 decades from
    % remaining dynamics.
    for ct=find(SoftFlags(:) & cellfun('length',FRanges))'
        SoftFlags(ct) = (FRanges{ct}(2)>focus(1)/100);
    end
    focus = LocalMergeRange([{focus};FRanges(SoftFlags)]);
end


%--------------- Local Functions ----------------------------

function focus = LocalMergeRange(FRanges)
% Take the union of a list of ranges
focus = zeros(0,2);
for ct=1:length(FRanges)
    focus = [focus ; FRanges{ct}];
    focus = [min(focus(:,1)) , max(focus(:,2))];
end