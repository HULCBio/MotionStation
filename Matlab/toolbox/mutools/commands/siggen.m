% function y = siggen('function(t)',t)
%
%   SIGGEN creates VARYING matrices as a function
%   of time.  If 'function()' is in terms of an argument,
%   that argument must be 't'.
%
%   Examples:
%
%       y = siggen('sin(t)',[0:pi/100:2*pi]);
%       y = siggen('rand(2,2)',[0:20]);
%
%   See also: COS_TR, SIN_TR, and STEP_TR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function y = siggen(func,t)

if nargin ~= 2,
    disp('usage: y = siggen(function(t),t)')
    return
    end

if ~isstr(func),
    error('first argument must be a string')
    return
    end

%       t is extracted as a column vector.

[ttype,nr,nc,npts] = minfo(t);
if ttype == 'vary',
    [tdat,tptr,tt] = vunpck(t);
    t = tt;
elseif ttype == 'cons',
    if nr == 1,
        npts = nc;
        t = t.';
    elseif nc == 1,
        npts = nr;
    else
        error('second argument does specify a vector')
        return
        end
else
    error('second argument must be VARYING or CONSTANT')
    return
    end

%       perform a single evaluation of the function.
%       If there is more than one time point and the eval
%       didn't generate a matrix of the right size it can
%       be detected by repeating the eval with two elements
%       of t.  In this case loop over t to generate ydat.
%       Two elements are used because some MATLAB functions
%       behave differently when given a scalar (eg: rand,
%       ones, zeros).  This means that the npts = 2 case
%       has to be done separately.

%       If a loop is not necessary, yet the number
%       of rows of the output varying matrix is more than
%       one, the eval() has created the data in the wrong
%       order.  It must be rearranged.

eval(['ydat = ' func ';']);
if npts > 2,
    [nr,nc] = size(ydat);
    nrr = round(nr/npts);
    timebase = t;
    t = timebase(1:2);
    eval(['ltest = ' func ';']);
    t = timebase;
    [nrltest,ncltest] = size(ltest);
    if nrltest == nr,
        nrr = nr;
        y = zeros(nrr*npts+1,ncltest+1);
        y(1:nrr,1:nc) = ydat;
        for i = 2:npts,
            eval(['nxtev = ' func ';']);
            y((i-1)*nrr+1:i*nrr,1:nc) = nxtev;
            end
    elseif  nrr > 1,
        y = zeros(nr+1,nc+1);
        ydat = reshape(ydat,npts*nrr*nc,1);
        index = ([0:nrr-1]'*npts+1)*ones(1,npts) + ones(nrr,1)*[0:npts-1];
        index = reshape(index,nrr*npts,1);
        for i = 1:nc,
            y(1:nr,i) = ydat(index + (i-1)*nrr*npts);
            end
    else
        y(1:nr,1:nc) = ydat;
        end
    y(1:npts,nc+1) = timebase;
    y(nrr*npts+1,nc+1) = inf;
    y(nrr*npts+1,nc) = npts;
elseif npts == 2,
    [nr,nc] = size(ydat);
    nrr = round(nr/npts);
    if nrr*npts ~= nr,
        eval(['ydat = [ydat; ' func '];']);
    elseif  nrr > 1,
        y = zeros(nr+1,nc+1);
        ydat = reshape(ydat,npts*nrr*nc,1);
        index = ([0:nrr-1]'*npts+1)*ones(1,npts) + ones(nrr,1)*[0:npts-1];
        index = reshape(index,nrr*npts,1);
        for i = 1:nc,
            y(1:nr,i) = ydat(index + (i-1)*nrr*npts);
            end
        end
    y(1:npts,nc+1) = timebase;
    y(nrr*npts+1,nc+1) = inf;
    y(nrr*npts+1,nc) = npts;
else
    [nr,nc] = size(ydat);
    y = zeros(nr+1,nc+1);
    y(1:nr,1:nc) = ydat;
    y(1:npts,nc+1) = timebase;
    y(nr+1,nc+1) = inf;
    y(nr+1,nc) = npts;
    end


%------------------------------------------------------------------


%
%