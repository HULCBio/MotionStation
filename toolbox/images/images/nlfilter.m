function b = nlfilter(varargin)
%NLFILTER Perform general sliding-neighborhood operations.
%   B = NLFILTER(A,[M N],FUN) applies the function FUN to each M-by-N
%   sliding block of A.  FUN is a function that accepts an M-by-N matrix as
%   input and returns a scalar:
%
%       C = FUN(X)
%
%   C is the output value for the center pixel in the M-by-N block
%   X. NLFILTER calls FUN for each pixel in A. NLFILTER zero pads the M-by-N
%   block at the edges, if necessary.
%
%   B = NLFILTER(A,[M N],FUN,P1,P2,...) passes the additional parameters
%   P1,P2,..., to FUN.
%
%   B = NLFILTER(A,'indexed',...) processes A as an indexed image, padding
%   with ones if A is of class double and zeros if A is of class uint8.
%
%   Class Support
%   -------------
%   The input image A can be of any class supported by FUN. The class of B
%   depends on the class of the output from FUN.
%
%   Remarks
%   -------
%   NLFILTER can take a long time to process large images. In some cases,
%   the COLFILT function can perform the same operation much faster.
%
%   Example
%   -------
%   FUN can be a FUNCTION_HANDLE created using @.  This example produces
%   the same result as calling MEDFILT2 with a 3-by-3 neighborhood:
%
%       B = nlfilter(A,[3 3],@myfun);
%
%   where MYFUN is an M-file containing:
%
%       function scalar = myfun(x)
%       scalar = median(x(:));
%
%   FUN can also be an inline object.  The example above can be written as:
%
%       fun = inline('median(x(:))');
%       B = nlfilter(A,[3 3],fun);
%
%   See also BLKPROC, COLFILT, FUNCTION_HANDLE, INLINE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 5.20.4.3 $  $Date: 2003/08/23 05:53:04 $

[a, nhood, fun, params, padval] = parse_inputs(varargin{:});

% Expand A
[ma,na] = size(a);
aa = mkconstarray(class(a), padval, size(a)+nhood-1);
aa(floor((nhood(1)-1)/2)+(1:ma),floor((nhood(2)-1)/2)+(1:na)) = a;

% Find out what output type to make.
rows = 0:(nhood(1)-1); 
cols = 0:(nhood(2)-1);
b = mkconstarray(class(feval(fun,aa(1+rows,1+cols),params{:})), 0, size(a));
    
% Apply m-file to each neighborhood of a
f = waitbar(0,'Applying neighborhood operation...');
for i=1:ma,
  for j=1:na,
    x = aa(i+rows,j+cols);
    b(i,j) = feval(fun,x,params{:});
  end
  waitbar(i/na)
end
close(f)

%%%
%%% Function parse_inputs
%%%
function [a, nhood, fun, params, padval] = parse_inputs(varargin)

switch nargin
case {0,1,2}
    eid = sprintf('Images:%s:tooFewInputs',mfilename);
    msg = 'Too few inputs to NLFILTER';
    error(eid,'%s',msg); 
case 3
    if (strcmp(varargin{2},'indexed'))
        eid = sprintf('Images:%s:tooFewInputsIfIndexedImage',mfilename);
        msg = 'Too few inputs to NLFILTER';
        error(eid,'%s',msg);
    else
        % NLFILTER(A, [M N], 'fun')
        a = varargin{1};
        nhood = varargin{2};
        fun = varargin{3};
        params = cell(0,0);
        padval = 0;
    end
    
otherwise
    if (strcmp(varargin{2},'indexed'))
        % NLFILTER(A, 'indexed', [M N], 'fun', P1, ...)
        a = varargin{1};
        nhood = varargin{3};
        fun = varargin{4};
        params = varargin(5:end);
        padval = 1;
        
    else
        % NLFILTER(A, [M N], 'fun', P1, ...)
        a = varargin{1};
        nhood = varargin{2};
        fun = varargin{3};
        params = varargin(4:end);
        padval = 0;
    end
end

if (isa(a,'uint8') || isa(a,'uint16'))
    padval = 0;
end

fun = fcnchk(fun,length(params));
