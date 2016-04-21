function R = atan2(Y,X)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/matlab/@double/atan2.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/03/21 22:07:35 $
% Comments:
% Need negative testing for the following assertions

eml_assert(nargin>1, ...
    'error','Not enough input arguments.');
eml_assert(isfloat(X), 'error', ['Function ''atan2'' is not defined for values of class ''' class(X) '''.']);
eml_assert(isfloat(Y), 'error', ['Function ''atan2'' is not defined for values of class ''' class(Y) '''.']);

XisScalar = (length(X)==1);
YisScalar = (length(Y)==1);
eml_assert( eml_all(size(X)==size(Y))||XisScalar||YisScalar, ...
    'error','Matrix dimensions must agree.');

eml_assert(strcmp(class(Y),'double') || strcmp(class(Y),'single'), ...
           'error', 'Inputs must be either single or double.');
eml_assert(strcmp(class(X),'double') || strcmp(class(X),'single'), ...
           'error', 'Inputs must be either single or double.');
% Geck G188799: ATNA2 arguments in R14 must be real
eml_assert(isreal(Y) && isreal(X), ...
            'error','Arguments must be real.');

[mX,nX] = size(X);
[mY,nY] = size(Y);

if XisScalar,
    m = mY;
    n = nY;
else
    m = mX;
    n = nX;
end

if(strcmp(class(Y), 'double') && strcmp(class(X), 'double'))
  R = zeros(m,n);
  sd = 1;
else 
  R = zeros(m,n,'single');
  sd = single(1);
end

if XisScalar, x = real(X); end
if YisScalar, y = real(Y); end

for i=1:m,
    for j=1:n,
        % scalar expansion code
        if ~XisScalar, x=real(X(i,j)); end
        if ~YisScalar, y=real(Y(i,j)); end

        % deal with NaNs and Inf(s)
        if isnan(x) || isnan(y)
            R(i,j) = NaN;
        elseif isinf(y) && isinf(x)
            R(i,j) = scalar_atan2(sign(y),sign(x),sd);
        else
            R(i,j) = scalar_atan2(y,x,sd);
        end
    end
end

eml_ignore('chk_mlR = builtin(''atan2'',Y,X);');
eml_ignore('chk_R_mlR = eps>=abs(R-chk_mlR);');
eml_ignore(eml_assert(     ... % when in MATLAB, assert
     eml_all(chk_R_mlR)           ... % that results are within tolerance
   | eml_all(isnan(chk_mlR(~chk_R_mlR))) ... % but allow for NaN(s)
     ));

return;

%%%%%%%%
function r = scalar_atan2(y,x,sd)

if x==0
    % at the limits of 1st and 4th quadrants
    if     y>0,  t =  pi/2;
    elseif y<0,  t = -pi/2;
    else         t =  0;
    end
    
    r = sd * t;    
else
  r = eml_atan2(y,x);
end

function bool = isfloat(x)
    bool = isa(x,'double') || isa(x,'single');
