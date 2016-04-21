function refresh(h)
%REFRESH  Recursively updates plot array visibility and layout.
%
%  This method should be invoked when the Visible, RowVisible, 
%  or ColumnVisible properties of @plotarray object are modified.

%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:22 $
%  Copyright 1986-2004 The MathWorks, Inc.
  
% Compute new visibility for plots in plotarray H
% RE: Each "plot" is either an HG axes or another plot array
Size = size(h.Axes);
RowVis = h.Visible & h.RowVisible;
ColVis = (h.Visible & h.ColumnVisible)';
NewVis = RowVis(:,ones(1,Size(2))) & ColVis(ones(1,Size(1)),:);

% Adjust overall plot array visibility (bypasses LAYOUT if nothing visible) 
if ~any(RowVis) & ~any(ColVis)
   h.Visible = 0;
end

% Reposition plots in plot array H 
% RE: Non recursive
layout(h)

% Update plot visibility and recursively apply REFRESH to subgrids
if isa(h.Axes(1),'hg.axes')
    % Apply new visibility to HG axes and set zoom property
    % based on visibility of axis
    hax = h.Axes(NewVis);
    set(hax,'Visible','on','ContentsVisible','on')
    bh = hgbehaviorfactory('Zoom');
    set(bh, 'Enable', true);
    hgaddbehavior(hax,bh);

    hax = h.Axes(~NewVis);
    set(hax,'Visible','off','ContentsVisible','off');
    bh = hgbehaviorfactory('Zoom');
    set(bh, 'Enable', false);
    hgaddbehavior(hax,bh);

else
    % Update visibility of each subgrid
    set(h.Axes(NewVis),'Visible',1)
    set(h.Axes(~NewVis),'Visible',0)
    % Recursive call to REFRESH
    % RE: Apply to ALL subarrays to properly update visibility of HG axes
    for ct=1:prod(Size)
        refresh(h.Axes(ct))
    end
end
