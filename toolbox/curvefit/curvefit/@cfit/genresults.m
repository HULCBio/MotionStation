function resultstrings = genresults(fitresult,goodness,output,warnstr,errstr,convmsg,clev)
%GENRESULTS generate cell array of strings for results window.
%
%   RESULTSSTRINGS = GENRESULTS(FITRESULT,GOODNESS,OUTPUT) takes output
%   from FIM command and pretties it up and puts it in a cell array of strings.
%

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.13.2.1 $  $Date: 2004/02/01 21:39:11 $

if nargin<7, clev = 0.95; end

resultstrings = {};
if ~isempty(errstr)
    if ~isempty(findstr('Fitting computation cancelled.',errstr))
        resultstrings{end+1} = xlate('Fitting computation cancelled.');
    else
        resultstrings{end+1} = xlate('Fit could not be computed due to error:');
        resultstrings{end+1} = '';
        resultstrings{end+1} = errstr;
    end
else
    if output.exitflag < 0 
        resultstrings{end+1} = xlate('Fit computation did not converge:');
        resultstrings{end+1} = convmsg;
        resultstrings{end+1} = '';
        resultstrings{end+1} = xlate('Fit found when optimization terminated:');
        resultstrings{end+1} = '';
    elseif output.exitflag == 0
        resultstrings{end+1} = xlate('Fit computation did not converge:');
        resultstrings{end+1} = convmsg;
        resultstrings{end+1} = '';
        resultstrings{end+1} = xlate('Fit found when optimization terminated:');
        resultstrings{end+1} = '';
    end

    if ~isempty(warnstr)
        resultstrings{end+1} = sprintf('Warnings during fitting:');
        resultstrings{end+1} = sprintf(warnstr);
        resultstrings{end+1} = ' ';
    end
    
    [line1,line2,line3,line4] = makedisplay(fitresult,'f',output,clev);
    resultstrings(end+1:end+3) = {line2,line3,line4};
    
    resultstrings{end+1} = sprintf('Goodness of fit:');
    resultstrings{end+1} = sprintf('  SSE: %0.4g',goodness.sse);
    resultstrings{end+1} = sprintf('  R-square: %0.4g',goodness.rsquare);
    resultstrings{end+1} = sprintf('  Adjusted R-square: %0.4g',goodness.adjrsquare);
    resultstrings{end+1} = sprintf('  RMSE: %0.4g',goodness.rmse);
end

