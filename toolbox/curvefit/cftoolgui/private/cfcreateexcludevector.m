function excludevector=cfcreateexcludevector(dataset,outlier)
% CFCREATEEXCLUDEVECTOR create an exclude vector.

% EXCLUDEVECTOR = CFCREATEEXCLUDEVECTOR(DATASET,OUTLIER) returns the logical
% vector EXCLUDEVECTOR for use in FIT (via FITOPTIONS).

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:39:41 $

ws = warning('off', 'all');
lastwarn('');

ds = handle(dataset);
if ~isempty(outlier)
   ol = handle(outlier);
end

xdata = ds.x;
ydata = ds.y;

% Consider invalid points
excludevector = isnan(xdata) | isnan(ydata);
if ~isempty(ds.weight)
   excludevector = excludevector | isnan(ds.weight);
end

% Consider points excluded individually
if ~isempty(outlier)
   excludevector(logical(ol.exclude)) = 1;
end

% Consider restrictions on x or y
if ~isempty(outlier) && ol.restrictDomain
    if ~strcmp(ol.domainLow,'')
        xmin = str2double(ol.domainLow);
        if (ol.domainLowLessEqual == 0) % include xmin<x
            excludevector = excludevector | (xdata<=xmin);
        else % include xmin<=x i.e. eclude x<xmin
            excludevector = excludevector | (xdata<xmin);
        end
    end
    if ~strcmp(ol.domainHigh,'')
        xmax = str2double(ol.domainHigh);
        if (ol.domainHighLessEqual == 0) % include x < xmax
            excludevector = excludevector | (xdata>=xmax);
        else % include x<=xmax i.e. exclude x>xmax
            excludevector = excludevector | (xdata>xmax);
        end
    end
end

if ~isempty(outlier) && ol.restrictRange
    if ~strcmp(ol.rangeLow,'')
        ymin = str2double(ol.rangeLow);
        if (ol.rangeLowLessEqual == 0) % include ymin < y
            excludevector = excludevector | (ydata<=ymin);
        else % include ymin <= y
            excludevector = excludevector | (ydata<ymin);
        end
    end
    if ~strcmp(ol.rangeHigh,'')
        ymax = str2double(ol.rangeHigh);
        if (ol.rangeHighLessEqual == 0) % include y < ymax
            excludevector = excludevector | (ydata>=ymax);
        else % include y <= ymax
            excludevector = excludevector | (ydata>ymax);
        end
    end
end

warning(ws);
