function sysout = pade(sys,n)
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

%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $  $Date: 2002/04/10 06:17:09 $

%  Reference:  Golub and Van Loan, Matrix Computations, John Hopkins
%              University Press, pp. 557ff.

error(sprintf('%s\n%s','PADE is not supported for FRD models.', ...
   'Use DELAY2Z to incorporate exact time delays in FRD models.'));