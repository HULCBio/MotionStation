function  s = iirparser(whichIIR,numOrd,denOrd,f,edges,des,varargin)
%IIRPARSER is a helper function to check for correct arguments for IIR designs.
%

%   whichIIR:  1=iirlpnorm, 2=iirlpnormc, 3=iirgrpdelay, 
%              4=firlpnorm, 5=firlpnorm(minPhase)

%   Author(s): D. Shpak
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/14 15:39:44 $ 

if ~all(isfinite([numOrd(:);denOrd(:);f(:);edges(:);des(:)]))
	error('Input specs cannot contain NaN or Inf.');
end
if (max(size(edges)) < 2 | max(size(f)) < 2 | max(size(des)) < 2)
   error (['The band-edge frequency, frequency, and desired value, '...
   'vectors must be vectors with at least two elements.']);
end
if (any(diff(f) <= 0) | any(f < 0) | any(f > 1))
   error ('Frequency points must be in increasing order and range from 0 to 1.');
end
if (any(diff(edges) <= 0) | rem(length(edges),2) ~= 0)
   error ('There must be an even number of band-edge frequencies in increasing order.');
end
if (length(intersect(f,edges)) ~= length(edges))
   error ('The band-edge frequencies must appear in the frequency vector.');
end
if (any(des < 0))
   error ('Desired values must be positive.');
end
if (whichIIR ~= 3) & all(diff(des) == 0)
    error ('Desired values cannot all be the same.');
end
if (edges(1) ~= f(1) | edges(end) ~= f(end))
   error (['The first band edge must equal the first frequency and '...
         'the last band edge must equal the last frequency.']);
end
if (length(f) ~= length(des))
   error (['The frequency and desired value must be vectors of the same length.']);
end
nBands = length(edges)/2;

% Make sure that the specified frequency points are INSIDE of the bands
inside = [];
for band=1:nBands
    inside = union(inside, intersect(find(f >= edges(2*band-1)), find(f <= edges(2*band))));
end
if length(inside) ~= length(f)
    error('Frequency points must be located within the bands.');
end

if (size(numOrd) ~= [1 1] | numOrd < 0 | fix(numOrd) ~= numOrd)
   error ('Numerator order must be a non-negative integer.');
end
if (size(denOrd) ~= [1 1] | denOrd < 0 | fix(denOrd) ~= denOrd)
   error ('Denominator order must be a non-negative integer.');
end
if (numOrd + denOrd <= 0)
    error ('Numerator or denominator must have an order > 0.');
end

switch whichIIR,
case {1,2,3},
	maxOrd = 50; 
	if max(numOrd,denOrd) > maxOrd, 
		error(['The maximum filter order is ',sprintf('%d',maxOrd),'.']); 
	end 
end

if (min(size(edges)) > 1 | min(size(f)) > 1 | min(size(des)) > 1)
   error (['The band-edge frequency, frequency, and desired value, '...
   'vectors must be vectors.']);
end

wt = ones(1, length(f));
% Check for weighting argument
if nargin >= 7
   wt = varargin{1};
	if (any(wt <= 0))
   	error ('Error weights must be positive.');
   end
   if ~all(isfinite(wt))
       error('Error weights must be finite.');
   end
   if (length(f) ~= length(des) | length(f) ~= length(wt))
   	error (['The frequency, desired value, and error weighting '...
            'must be vectors of the same length.']);
   end
end

% Check for maximum radius argument.
maxRadius = 0.999999;
if nargin >= 8
   maxRadius = varargin{2};
   if (length(maxRadius) ~= 1 | maxRadius  <= 0 | maxRadius  >= 1.0)
      error('Pole radius must be a scalar between 0 and 1.');
   end
end

% The values of P for the least Pth method
P = [2 128];
if nargin >= 9
   P = varargin{3};
   if ischar(P)
      if strcmp(lower(P), 'inspect')
         P = [4 2];
      else
         error('Unrecognized string used for P.');
      end
   else
   	[M,N] = size(P);
   	if M*N ~= 2
      	error('You must specify a vector with the minimum and maximum values of P.');
   	end
   	if ~any(isfinite(P)) | any(rem(P,2)) | any(P <= 0)
      	error('The elements of P should be even, finite, and positive.');
      end
   end
end
% Grid density
density = 20;
if nargin >= 10
   if iscell(varargin{4})
      density = varargin{4}{1};
   else
      density = varargin{4};
   end
   [M,N] = size(density);
   if M*N ~= 1 | density < 10 | ~isfinite(density)
      error('The grid density must be a finite scalar value of at least 10.');
   end
end

% Check for initial conditions
BS = [];
AS = [];
if whichIIR == 1 | whichIIR == 2
	Ho = 0.001;
	if nargin >= 11
  		if nargin < 12
      		error('For initial conditions, specify INITNUM and then INITDEN as polynomials.');
   		end
   		B = varargin{5};
   		A = varargin{6};
   		% If A and B are empty, then the mex file does the initialization.
   		% Otherwise, we need to convert A and B into the proper format.
   		if ~(isempty(B) & isempty(A))
   			if (length(B) ~= numOrd+1)
      			error(['The length of the numerator initial condition vector ' ...
            	'must be one more than the numerator order.']);
   			end
   			if (length(A) ~= denOrd+1)
      			error(['The length of the denominator initial condition vector ' ...
            	'must be one more than the denominator order.']);
   			end
   			if (B(1) == 0 | A(1) == 0)
      			error('The initial condition vectors cannot have leading zeros.');
   			end
            if ~any(isfinite(B)) | ~any(isfinite(A))
                error('The initial condition vectors must be finite');
            end
      		% Convert the polys into a cascade of second-order polys
      		[BS,kb] = toSecond(B);
      		[AS,ka] = toSecond(A);
      		Ho = kb/ka;
   		end
	end
end

if whichIIR == 4 | whichIIR == 5
    Ho = 1;
	if nargin >= 11
  		if nargin >= 12
      		error('For initial conditions, specify INITNUM as a polynomial.');
   		end
   		BS = varargin{5};
   		if (length(BS) ~= numOrd+1)
      		error(['The length of the numerator initial condition vector ' ...
            'must be one more than the numerator order.']);
   		end
   		if (BS(1) == 0)
      		error('The initial condition vector cannot have leading zeros.');
   		end
      	% For minPhase, convert the poly into a cascade of second-order polys
      	if whichIIR == 5
            [BS,kb] = toSecond(BS);
            BS = [kb BS]; % Proper format for FIR designs
        end
	end
end

if whichIIR == 3
	if nargin >= 11
   	A = varargin{5};
   	% If A and B are empty, then the mex file does the initialization.
   	% Otherwise, we need to convert A and B into the proper format.
   	if ~(isempty(A))
   		if (length(A) ~= denOrd+1)
      		error(['The length of the denominator initial condition vector ' ...
            'must be one more than the denominator order.']);
   		end
   		if (A(1) == 0)
      		error('The initial condition vector cannot have leading zeros.');
   		end
      	% Convert the polys into a cascade of second-order polys
      	[AS,ka] = toSecond(A);
   	end
	end
	Ho = max(des) - min(des);  % Actually, Ho is tau, the group delay estimate
	if nargin >= 12
   	Ho = varargin{6};
   	if (length(Ho) ~= 1 | Ho <= 0)
      	error('The initial estimate of the group delay must be a positive scalar');
   	end
   end
end

% Construct the structure to return as output
[s.numOrd,s.denOrd,s.edges,s.f,s.des,s.wt,s.maxRadius,s.P,s.density,s.Ho,s.BS,s.AS] = ...
    deal(numOrd,denOrd,edges,f,des,wt,maxRadius,P,density,Ho,BS,AS);

%-------------------------------------------------------------------------

% The mex function requires the coefficients to be ordered like
% MATLAB's second-order sections but without the leading 1's
function [q,ks] = toSecond(r)
z = roots(r);
z = cplxpair(z);
r1 = poly(z);
ks = r(1)/r1(1);
order = length(z);
sections = fix(order/2);
q = [];
k=1;
for m=1:sections
   tmp = real(conv([1 -z(k)],[1 -z(k+1)]));
   q = [q tmp(2:3)];
   k = k + 2;
end
if rem(order,2)
   q = [q -z(order)];
end
