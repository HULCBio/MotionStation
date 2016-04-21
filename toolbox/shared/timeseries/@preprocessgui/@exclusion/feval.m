function idx = feval(h,dataset)
%FEVAL
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:32:30 $

s = size(dataset.data);

% Define rule switches
boundsactive = strcmp(h.Boundsactive,'on');
outliersactive =  strcmp(h.Outliersactive,'on') && ~isempty(h.Outlierwindow) && h.Outlierwindow<s(1) && ...
        h.Outlierwindow>0 && h.Outlierconf>0;
flatlineactive = strcmp(h.Flatlineactive,'on') && ~isempty(h.Flatlinelength) && h.Flatlinelength>1 && ...
        size(dataset.data,1)>2;
expressionactive = strcmp(h.Expressionactive,'on') && length(deblank(h.Mexpression))>1;

idx = false(s);

t = dataset.Time;
  

if boundsactive
    X = dataset.Data;
    % Bounds Error checking
    if ~isempty(h.Ylow) && (length(h.Ylow)~=1 && length(h.Ylow)~=s(2))
        error('@exclusion:feval:ylowbounds', ...
            'The Y lower bound must either be a scalar or have length equal to the number of data columns');
    end
    if ~isempty(h.Yhigh) && (length(h.Yhigh)~=1 && length(h.Yhigh)~=s(2))
        error('@exclusion:feval:yhighbounds', ...
            'The Y upper bound must either be a scalar or have length equal to the number of data columns');
    end
    if (~isempty(h.Xlow) && ~isscalar(h.Xlow)) && (~isempty(h.Xhigh) && ~isscalar(h.Xhigh))
        error('@exclusion:feval:xbounds', ...
            'The time upper and lower bounds must be scalar');
    end  
    % Bounds comparison
    if ~isempty(h.Xlow) 
        if strcmp(h.Xlowstrict,'on')
            idx(find(t<h.Xlow),:) = true;
        else
            idx(find(t<=h.Xlow),:) = true;
        end
    end
    if ~isempty(h.Xhigh) 
        if strcmp(h.Xhighstrict,'on')
            idx(find(t>h.Xhigh),:) = true;
        else
            idx(find(t>=h.Xhigh),:) = true;
        end
    end        
    if length(h.Ylow)>1
        if strcmp(h.Ylowstrict,'on')
            idx(any((X<ones(size(X,1),1)*(h.Ylow(:)'))')') = true;
        else
            idx(any((X<=ones(size(X,1),1)*(h.Ylow(:)'))')') = true;
        end
    elseif length(h.Ylow)==1
        if strcmp(h.Ylowstrict,'on')
            idx(X<h.Ylow) = true;
        else
            idx(X<=h.Ylow) = true;
        end
    end
    if length(h.Yhigh)>1 
        if strcmp(h.Yhighstrict,'on')
            idx(any((X>ones(size(X,1),1)*(h.Ylow(:)'))')') = true;
        else
            idx(any((X>=ones(size(X,1),1)*(h.Ylow(:)'))')') = true;
        end
    elseif length(h.Yhigh)==1 
        if strcmp(h.Yhighstrict,'on')
            idx(X>h.Yhigh) = true;
        else
            idx(X>=h.Yhigh) = true;
        end
    end    
end

matlaberrorset = false;
for col=1:s(2)
    x = dataset.Data(:,col);
    
    if outliersactive
        % TO DO: Add iqr calc, can we do this more efficiently recursively?
        for row=1:s(1)
            L = min(max(row-floor(h.Outlierwindow/2),1),s(1)-h.Outlierwindow);
            U = L+h.Outlierwindow;
            idx(row,col) = (idx(row,col) || locallimits(x(L:U),h.Outlierconf ,x(row)));
        end
    end
    if flatlineactive 
        % Insert infs at the start and end to ensure we detect flatlines
        % which occur at the start and end
        dX = diff(diff([inf;x;inf])==0);
        % Find indices of leading and traling edges of constant periods
        I = [find(dX==1) find(dX==-1)];
        for k=1:size(I,1)
            % If the constant period is longer than the window length set
            % all the corresponging indices to excluded
            if I(k,2)-I(k,1)+1>=h.Flatlinelength
                idx(I(k,1):I(k,2),col) = true;
            end
        end   
    end
    
    if expressionactive && ~matlaberrorset
        try 
            assignin('caller','x',x);
            idx(evalin('caller',h.Mexpression),col) = true;
        catch
            msgbox('Invalid MATLAB expression. Note the label x must be used to represent the data',...
                  'Data Preprocessing Tool')

            matlaberrorset = true;
            %error('@exclusion:feval:expression', 'Invalid MATLAB expression.');
        end
    end
end

function idx = locallimits(x,conf,testpt)

med = median(x);
L = length(x);

if length(x)<4
    sigma = std(x);
else % Robust estimate of sigma from iqr
    [xsort I] = sort(x);
    sigma = .5/(sqrt(2)*erfinv(.5))*(xsort(ceil(3*L/4))-xsort(floor(L/4)));
end

delta = sqrt(2)*sigma*erfinv(2*conf/100-1);
if testpt>med+delta || testpt<med-delta
    idx = true;
else
    idx = false;
end
