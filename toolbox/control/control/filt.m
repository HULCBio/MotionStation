function sys = filt(varargin)
%FILT  DSP-oriented specification of discrete transfer functions.
%
%   SYS = FILT(NUM,DEN)      Digital filter H(z^-1)=NUM(z^-1)./DEN(z^-1) 
%                            with unspecified sampling time.
%   SYS = FILT(NUM,DEN,Ts)   Digital filter H(z^-1)=NUM(z^-1)./DEN(z^-1)
%                            with sample time Ts.
%   SYS = FILT(M)            Gain matrix.
%
%   All the above calling syntaxes may be followed by Property/Value pairs. 
%
%   In the SISO case, NUM and DEN are row vectors listing the numerator and
%   denominator coefficients in ascending powers of z^-1.  In the MIMO case,
%   NUM and DEN are cell arrays of row vectors such that NUM{i,j} and 
%   DEN{i,j} specify the transfer function from input j to output i.
%
%   See also  TF

%       Author(s): A. Potvin, 3-1-94, P. Gahinet, 4-12-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $

ni = nargin;

% Dissect input list
DoubleInputs = 0;
PVstart = 0;
while DoubleInputs < ni & PVstart==0,
  nextarg = varargin{DoubleInputs+1};
  if isa(nextarg,'double') | isa(nextarg,'cell')
     DoubleInputs = DoubleInputs+1;
  else
     PVstart = DoubleInputs+1;  
  end
end

% Process numerical data 
switch DoubleInputs,
case 0
   % Empty filter 
   sys = tf;
case 1
   % Gain matrix 
   sys = tf(varargin{:});
case 2
   % unspecified sampling time -> Ts = -1
   sys = tf(varargin{1:2},-1,varargin{3:ni},'Variable','z^-1');
case 3
   sys = tf(varargin{:},'Variable','z^-1');
otherwise
   error('Too many numerical inputs.')
end

% end ../lti/filt.m

