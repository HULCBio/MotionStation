function [wnout,z,r] = damp(a,Ts)
%DAMP  Natural frequency and damping of LTI model poles.
%
%    [Wn,Z] = DAMP(SYS) returns vectors Wn and Z containing the
%    natural frequencies and damping factors of the LTI model SYS.
%    For discrete-time models, the equivalent s-plane natural 
%    frequency and damping ratio of an eigenvalue lambda are:
%               
%       Wn = abs(log(lambda))/Ts ,   Z = -cos(angle(log(lambda))) .
%
%    Wn and Z are empty vectors if the sample time Ts is undefined.
%
%    [Wn,Z,P] = DAMP(SYS) also returns the poles P of SYS.
%
%    When invoked without left-hand arguments, DAMP prints the poles
%    with their natural frequency and damping factor in a tabular format 
%    on the screen.  The poles are sorted by increasing frequency.
%
%    See also POLE, ESORT, DSORT, PZMAP, ZERO.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%DAMP   Natural frequency and damping factor for continuous systems.
%   [Wn,Z] = DAMP(A) returns vectors Wn and Z containing the
%   natural frequencies and damping factors of A.   The variable A
%   can be in one of several formats:
%
%       1) If A is square, it is assumed to be the state-space
%          "A" matrix.
%       2) If A is a row vector, it is assumed to be a vector of
%          the polynomial coefficients from a transfer function.
%       3) If A is a column vector, it is assumed to contain
%          root locations.
%
%   When invoked without left hand arguments DAMP prints the 
%   eigenvalues with their natural frequency and damping factor in a
%   tabular format on the screen.
%
%   See also EIG and DDAMP.

%   J.N. Little 10-11-85
%   Revised 3-12-87 JNL
%   Revised 7-23-90 Clay M. Thompson
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:20:13 $

sa = size(a);
if sa(2)>1,
	if sa(1)==sa(2)
		% first input is an A matrix
		r = esort(eig(a));
	elseif sa(1)==1
		% first input is a NUM vector
		r = esort(roots(a));
	else
		error('Input must be a vector or a square matrix.')
	end
else
	r = a;
end

% Sample time argument (undocumented)
if nargin==1
	Ts = 0;
elseif ~isequal(size(Ts),[1 1])
	error('Second input must be a scalar.')
end

% Compute Wn and Z
if Ts<0,
	% Discrete system with unspecified Ts -> no info
	wn = [];  z = [];
else
	% Initialize with NaN's
	wn = zeros(size(r));  wn(:) = NaN;
	z = zeros(size(r));   z(:) = NaN;
	if Ts,
		% Discrete: compute equivalent S-plane poles
		idx = find(isfinite(r) & r~=0);
		s = log(r(idx))/Ts;
	else
		idx = find(isfinite(r));
		s = r(idx);
	end
	wn(idx) = abs(s);
	z(idx) = -cos(atan2(imag(s),real(s)));
end


if nargout==0,      
	% Print results on the screen. First generate corresponding strings:
	printdamp(r,wn,z,Ts)
else
	wnout = wn; 
end


