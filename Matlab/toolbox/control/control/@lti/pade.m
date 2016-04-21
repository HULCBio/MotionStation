function sys = pade(sys,Ni,No,Nio)
%PADE  Pade approximation of time delays.
%
%   [NUM,DEN] = PADE(T,N) returns the Nth-order Pade approximation 
%   of the continuous-time delay exp(-T*s) in transfer function form.
%   The row vectors NUM and DEN contain the polynomial coefficients  
%   in descending powers of s.
%
%   When invoked without left-hand argument, PADE(T,N) plots the
%   step and phase responses of the N-th order Pade approximation 
%   and compares them with the exact responses of the time delay
%   (Note: the Pade approximation has unit gain at all frequencies).
%
%   SYSX = PADE(SYS,N) returns a delay-free approximation SYSX of 
%   the continuous-time delay system SYS by replacing all delays 
%   by their Nth-order Pade approximation.  
%
%   SYSX = PADE(SYS,NI,NO,NIO) specifies independent approximation
%   orders for each input, output, and I/O delay.  Here NI, NO, and 
%   NIO are integer arrays such that
%     * NI(j) is the approximation order for the j-th input channel
%     * NO(i) is the approximation order for the i-th output channel
%     * NIO(i,j) is the approximation order for the I/O delay from
%       input j to output i.
%   You can use scalar values for NI, NO, or NIO to specify a uniform 
%   approximation order, and use [] when there are no input, output, 
%   or I/O delays.
%
%   See also DELAY2Z, C2D, LTIMODELS, LTIPROPS.

%   Andrew C.W. Grace 8-13-89
%   P. Gahinet   7-22-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/10 05:48:57 $

%  Reference:  Golub and Van Loan, Matrix Computations, John Hopkins
%              University Press, pp. 557ff.

ni = nargin;
no = nargout;
error(nargchk(1,4,ni))
switch ni
case 1
   Ni = 1;  No = 1;  Nio = 1;
case 2
   if isequal(size(Ni),[1 1]),
      % Uniform approximation
      No = Ni;  Nio = Ni;
   else
      % Old syntax
      No = [];  Nio = [];
   end
case 3
   Nio = [];
end      

% Get system dimensions and delay 
sizes = size(sys);
ny = sizes(1);
nu = sizes(2);
id = sys.InputDelay;
od = sys.OutputDelay;
iod = sys.ioDelay;

% Quick exits
if isa(sys,'frd'),
   sys = delay2z(sys);
   return
elseif sys.Ts,
   warning('Model is discrete. Using DELAY2Z to map delays into poles at z=0')
   sys = delay2z(sys);
   return
elseif ~any(id(:)) & ~any(od(:)) & ~any(iod(:)),
   return
end

% Size Ni, No, and Nio appropriately
if size(Ni,2)~=1,
   Ni = permute(Ni,[2 1 3:ndims(Ni)]);
end
if size(No,2)~=1,
   No = permute(No,[2 1 3:ndims(No)]);
end
try
   Ni = CheckOrders(Ni,[nu 1 sizes(3:end)],'NI');
   No = CheckOrders(No,[ny 1 sizes(3:end)],'NO');
   Nio = CheckOrders(Nio,sizes,'NIO');
catch
   rethrow(lasterror)
end

% Call model-specific approximation algorithm
try
   sys = padeappx(sys,id,od,iod,Ni,No,Nio);
catch 
   rethrow(lasterror)
end

% Zero out approximated delays
sys.InputDelay = zeros(nu,1);
sys.OutputDelay = zeros(ny,1);
sys.ioDelay = zeros(ny,nu);


%%%%%%%%%%%%%%%%%%%%%%%%

function N = CheckOrders(N,ExpectedSize,argname)
%CHECKORDERS  Check approximation order arguments

sN = size(N);

% Empty and scalar cases
if any(sN==0),
   N = zeros(ExpectedSize(1:2));
   sN = ExpectedSize(1:2);
elseif isequal(sN(1:2),[1 1]),
   % scalar case
   N = repmat(N,ExpectedSize(1:2));
   sN = size(N);
end

% Align lengths of SN and EXPECTEDSIZE
if length(sN)==2,
   ExpectedSize = ExpectedSize(1:2);
else
   sN = [sN ones(1,length(ExpectedSize)-length(sN))];
end

% Error checking
if ~isa(N,'double') | any(N(:)~=round(N(:))) | any(N(:)<0)
   error(sprintf('%s should be an array of integers.',argname));
elseif ~isequal(sN,ExpectedSize),
   error(sprintf('%s is not properly dimensioned.',argname));
end

