function S = sign(X)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Complex numbers do not work.
% 2) Logicals are asserted out.
% 3) NaN friendly but not correct.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/@double/sign.m$
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $  $Date: 2004/04/14 23:57:58 $

eml_assert(nargin==1, ...
    'error','Not enough input arguments.');
eml_assert(isfloat(X), 'error', ['Function ''sign'' is not defined for values of class ''' class(X) '''.']);

% WISH : [mX,nX] = size(X);
mX=size(X,1); nX=size(X,2);

resultClass = class(X);

if isreal(X)
    S = zeros(mX,nX,resultClass);
    for p=1:mX,
        for q=1:nX,
            x = X(p,q);
            if isnan(x), S(p,q) =  NaN;
            elseif x>0,  S(p,q) =  1;
            elseif x<0,  S(p,q) = -1;
            end
        end
    end
else
    S = complex(zeros(mX,nX,resultClass),zeros(mX,nX,resultClass));
    for p=1:mX,
        for q=1:nX,
            x = X(p,q);
            if isnan(x)
                S(p,q) = NaN*1i;
            else
                a = sqrt(real(x)^2+imag(x)^2);
                if a>0,  S(p,q) = x./a;
                else     S(p,q) = 0;
                end
            end
        end
    end   
end

% Comment out until G165192 is fixed by Akernel
% Compare results to MATLAB builtin
eml_ignore('mlS = builtin(''sign'',X);');
eml_ignore('S_mlS = eps>=abs(S-mlS);');
eml_ignore(eml_assert(        ... % when in MATLAB, assert that
      eml_all(S_mlS)              ... % results are within tolerance
    | eml_all(isnan(mlS(~S_mlS))) ... % but allow for NaN(s)
    ));

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
