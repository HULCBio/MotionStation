function [xdata,ydata]=lfdata(pos,labelhandles,lfs)
%LFDATA  Line/Frame Data - Converts rectangular [l b r t] to xdata and ydata.
%
%   [xdata,ydata]=lfdata(pos,labelhandles,sz) 
%       inputs:
%     pos - length N cell array vector of position vectors, given 
%           as [left bottom right top] (as opposed to [l b w h])
%     labelhandles - length N vector of handles to corresponding text 
%           labels.  The xdata and ydata will include a gap which skips
%           over the label based on its extent property.
%     lfs - label-to-frame spacing, in pixels (scalar).
%   outputs:
%     xdata, ydata - length N cell arrays containing x and ydata of
%           lines which obey the rectanglular inputs but leave gaps
%           where the labels are.
%
%   T. Krauss, 12/1/95
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    N = length(pos);
    xdata = cell(N,1);
    ydata = cell(N,1);

    ex = get(labelhandles,'extent');
    if N==1
        ex=num2cell(ex,2);
    end

    for i=1:N
        xdata(i) = num2cell([pos{i}(1) pos{i}(3) pos{i}(3) ...
             ex{i}(1)+ex{i}(3)+lfs NaN ex{i}(1)-lfs pos{i}(1) pos{i}(1)],2);
        ydata(i) = num2cell([pos{i}(2) pos{i}(2) pos{i}(4) pos{i}(4) NaN ...
             pos{i}(4) pos{i}(4) pos{i}(2)],2);
    end

