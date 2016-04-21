function [b, ecode] = genpoly2b(genpoly,m,prim_poly)
% GENPOLY2B Check the validity of RS generator polynomial and compute the corresponding b
%    [B,ECODE] = GENPOLY2B(GENPOLY) returns B corresponding to the Galois row vector
%    GENPOLY, and ECODE which specifies whether GENPOLY is a valid generator polynomial.
%    If GENPOLY is invalid, B returns -1.
%
%       Meaning of values of ECODE:
%       0 : genpoly OK
%       1 : invalid genpoly
%       2 : invalid genpoly: genpoly not monic
%
%    [B,ECODE] = GENPOLY2B(GENPOLY,M,PRIM_POLY) takes an ordinary row vector GENPOLY.
%    M is the number of bits per symbol and PRIM_POLY is the primitive 
%    polynomial of the Galois Field.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/03/27 00:05:39 $ 

% Initial checks
if nargin~=1 & nargin~=3
    error('GENPOLY2B takes either one or three inputs.');
end

if ~strcmp(class(genpoly),'gf')
    nargchk(3,3,nargin);
    genpoly = gf(genpoly,m,prim_poly);
end
gpOne = genpoly(1);
if ~isequal(gpOne.x,1)
    ecode = 2;
    b = [];
    return;
end
roots_int = roots(genpoly);   % column vector
t2 = length(roots_int);

% Ensure number of roots equals deg(genpoly)
if t2==0 | length(roots_int) ~= length(genpoly)-1
    ecode = 1;
    b = -1;
    return
end
roots_power = int2pow(roots_int');              % gf object, row vector
roots_power = sort(double(roots_power.x));      % sorted; double
b = min(roots_power);

% Check if roots_power are consecutive numbers
if ~isequal(roots_power,[b:b+t2-1])
    % Check if roots_power is the mod of consecutive numbers
	b_new = roots_power(min(find(roots_power-[b:b+t2-1])));
	b_new_pos = min(find(roots_power-[b:b+t2-1]));
	roots_power(1:b_new_pos-1) = roots_power(1:b_new_pos-1)+2^m-1;
	if ~isequal(sort(roots_power), [b_new:b_new+t2-1])
        ecode = 1;      % invalid genpoly
    else
        ecode = 0;      % genpoly ok
        b = b_new;
    end
else
    ecode = 0;          % genpoly ok
end
return;

%%%%%%%%%%%%%%%%%%%%
% Helper functions %
%%%%%%%%%%%%%%%%%%%%

% --- INT2POW

function gf_pow = int2pow(gf_int)
    [temp gf_pow] = gftuple((de2bi(double(gf_int.x),gf_int.m)),de2bi(double(gf_int.prim_poly)));
	gf_pow = gf(gf_pow',gf_int.m,gf_int.prim_poly);
return;

