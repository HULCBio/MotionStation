function g = poly2tfd(num,den,delt,delay)
%POLY2TFD Create transfer functions in 3 row representation
%	g = poly2tfd(num,den,delt,delay)
% POLY2TFD creates a MPC toolbox transfer function in following format:
%
% g = [   b0   b1  b2  ... ]   (numerator coefficients)
%     |   a0   a1  a2  ... |   (denominator coefficients)
%     [ delt delay  0  ... ]   (only first 2 elements used in this row)
%
% Inputs:
%  num      : Coefficients of the transfer function numerator.
%  den      : Coefficients of the transfer function denominator.
%  delt     : Sampling time.  Can be 0 (for continuous-time system)
%             or > 0 (for discrete-time system).  Default is 0.
%  delay    : Pure time delay (dead time).  Can be >= 0.
%             If omitted or empty, set to zero.
%             For discrete-time systems, enter as PERIODS of pure
%             delay (an integer).  Otherwise enter in time units.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0
   disp('USAGE:  g = poly2tfd(num,den,delt,delay)')
   return
elseif nargin < 2
   error('Need at least 2 input arguments')
end

% Strip leading zeros from denominator, removing equal number
% from numerator.

[mden,n]=size(den);
if mden ~= 1
   error('T.F. denominator (DEN) must be a row vector.')
end
inz = find(den ~= 0);  % get rid of leading zeros in the denominator
if isempty(inz)
   error('T.F. denominator (DEN) was zero')
end
den = den(inz(1):n);
[mden,n] = size(den);
[nrow,ncol]=size(num);
if nrow ~= 1
    error('T.F. numerator (NUM) must be a row vector.')
end
if ncol > n
   if any(num(1,1:ncol-n) ~= 0)
      error('Order of numerator greater than denominator')
   else
      num=num(1,ncol-n+1:ncol);    % strip leading zeros from the numerator
   end
elseif n > ncol
   num=[zeros(1,n-ncol) num];   % pad numerator with leading zeros
end

if n == 1
   num=[0 num];                 % Take care of special case of a simple
   den=[0 den];                 % gain by adding leading zeros to both
end                             % numerator and denominator.

if nargin < 3
   delt=0;
elseif isempty(delt)
   delt=0;
elseif delt < 0
   error('DELT was < 0')
end

if nargin < 4
   delay=0;
elseif isempty(delay)
   delay=0;
elseif delay < 0
   error('DELAY < 0')
elseif delt > 0 & fix(delay) ~= delay
   error('DELAY must be # periods (integer) for discrete-time systems.')
end

g=[num;den];
g(3,1:2)=[delt,delay];

% end of function POLY2TFD.M