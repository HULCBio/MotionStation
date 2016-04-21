function [y, count,msg] = poptimfcnchk(FUN,Xin,X,Vectorized,varargin)
%POPTIMFCNCHK: This function checks the objective function FUN 
%   Private to PFMINUNC, PFMINBND, PFMINLCON.


%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.7.6.3 $  $Date: 2004/03/18 17:59:32 $

msg = '';
y =NaN;
count = 0;
if ~isnumeric(X)
    msg = sprintf('%s%s\n','Start point must be of data type double and not ',class(X));
    error('gads:POPTIMFCNCHK:startPoint',msg);
end
if strcmpi(Vectorized,'off')  %The function is not vectorized. 
    try
        [y,count] = funevaluate(FUN,Xin,X,'init',[],[],varargin{:});
    catch
       error('gads:POPTIMFCNCHK:objfunCheck', ...
            ['PATTERNSEARCH cannot continue because user supplied objective function\n', ...
               'failed with the following error:\n%s'], lasterr)
   end
    if length(y) ~=1
        msg = sprintf('%s\n', ...
            'your objective function MUST return a scalar or use ''vectorized'' ''on'' options.');
        error('gads:POPTIMFCNCHK:objfunCheck',msg);
    end
    return;
elseif strcmpi(Vectorized,'on') %if vectorized is 'on', Completepoll MUST be 'on' too
    X2 = [X, X+eps];
    try
        [f,count] = funevaluate(FUN,Xin,X2,'init',[],[],varargin{:});
    catch
       error('gads:POPTIMFCNCHK:objfunCheck', ...
             ['PATTERNSEARCH cannot continue because user supplied objective function\n', ...
            'failed (HINT: ''vectorized'' option is ''on'') with the following error:\n%s'],lasterr);
    end
    if 2 ~=length(f)
        msg = sprintf('%s\n%s\n', ...
            'When ''Vectorized'' is ''on'', your objective function MUST return', ...
            'a vector of length equal to number input points.');
        error('gads:POPTIMFCNCHK:objfunCheck',msg);
    end
    y = f(1);
    return;
end
