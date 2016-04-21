function state = gaplotscorediversity(options,state,flag,p1)
%GAPLOTSCOREDIVERSITY Plots a histogram of this generation's scores.
%   STATE = GAPLOTSCOREDIVERSITY(OPTIONS,STATE,FLAG) plots a histogram of current
%   generation's scores.
%
%   Example:
%   Create an options structure that uses GAPLOTSCOREDIVERSITY
%   as the plot function
%     options = gaoptimset('PlotFcns',@gaplotscorediversity);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2004/04/04 03:24:29 $

if nargin < 4
    p1 = 40;
end

hist(state.Score,p1);
title('Score Histogram')

