function [z,newf,loopflag] = ezplotfeval(f,x,y)
%EZPLOTFEVAL Helper to evaluate function on array inputs
%   Z=EZPLOTFEVAL(F,X) applies the function F to the array X, looping
%   if necessary (if F is not vectorized).
%
%   Z=EZPLOTFEVAL(F,X,Y) applies the function F to the two arrays X
%   and Y, looping if necessary.
%
%   [Z,NEWF,LOOPFLAG]=EZPLOTFEVAL(F,...) also returns a new function
%   handle NEWF that works on array inputs (could be used in future
%   calls to save time), and the flag LOOPFLAG which is true if it was
%   necessary to loop, or false if not
%
%   See also EZCONTOUR, EZCONTOURF, EZMESH, EZMESHC, EZPLOT,
%            EZPLOT3, EZPOLAR, EZSURF, EZSURFC.

%   Copyright 1984-2004 The MathWorks, Inc.  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:06:44 $

% Try evaluating the function directly.  If it succeeds and gives a
% result of the right size, we're done.
le = lasterror;
loopflag = false;
newf = f;
try
    if nargin<3
       z = feval(f,x(:));
    else
       z = feval(f,x(:),y(:));
    end
    failed = false;
catch
    failed = true;
    lasterror(le);
end

if ~failed
    % We are satisfied if we got a scalar or a result with the
    % same size as the input.  An input function with an expression
    % such as "1" will produce a scalar output for a vector input.
    if isequal(numel(z),numel(x))
        z = reshape(z,size(x));
        return
    elseif isscalar(z)
        z = repmat(z,size(x));
        return;
    end
end

% Otherwise try to evaluate the function one element at a time.
% If the input function is bad, this may also fail, and we'll
% let the error go uncaught.
if nargin<3
    z = feval(f,x(1));
else
    z = feval(f,x(1),y(1));
end

warning('MATLAB:ezplotfeval:NotVectorized', ...
['Function failed to evaluate on array inputs; vectorizing the function may\n'...
'speed up its evaluation and avoid the need to loop over array elements.']);

% Otherwise evaluate instead a nested function that calls the input
% function in a loop (repeating the first element for convenience)
newf = @applyfun;
loopflag = true;
if nargin<3
    z = applyfun(x);
else
    z = applyfun(x,y);
end

    % In the following nested function, note that f is the input argument
    % to the containing function.
    % (The variable i is also in the shared context.)

    function z = applyfun(x,y)
    z = zeros(size(x));
    if nargin<2
        for i=1:numel(x),
           z(i) = feval(f,x(i));
        end
    else
        for i=1:numel(x),
           z(i) = feval(f,x(i),y(i));
        end
    end       
    z = reshape(z,size(x));
    end
    
end
