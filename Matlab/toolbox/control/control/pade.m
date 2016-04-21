function [aout,b,c,d] = pade(T,n)
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
%   P. Gahinet   7-22-96, 5-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2002/11/11 22:21:21 $

%  Reference:  Golub and Van Loan, Matrix Computations, John Hopkins
%              University Press, pp. 557ff.

ni = nargin;
no = nargout;
error(nargchk(1,2,ni))
if ni==1,
   n = 1; 
elseif n<0 | T<0,
   error('T and N must be non negative.')
end
n = round(n);

% The coefficients of the Pade approximation are given by the 
% recursion   h[k+1] = (N-k)/(2*N-k)/(k+1) * h[k],  h[0] = 1
% and 
%     exp(-T*s) == Sum { h[k] (-T*s)^k } / Sum { h[k] (T*s)^k }
%
if T>0
   a = zeros(1,n+1);   a(1) = 1;
   b = zeros(1,n+1);   b(1) = 1;
   for k = 1:n,
      fact = T*(n-k+1)/(2*n-k+1)/k;
      a(k+1) = (-fact) * a(k);
      b(k+1) = fact * b(k);
   end
   a = fliplr(a/b(n+1));
   b = fliplr(b/b(n+1));
else
   a = 1;
   b = 1;
end

if no==0,
   % Graphical Output if no left hand arguments (step response and Bode plot)
   if T==0,
      warning('Zero delay: no plot drawn.')
      return
   end
   figure
   subplot(211)
   t1 = [0:T/100:2*T];
   y1 = step(a,b,t1);
   t2 = sort([t1 T*(1-10*eps)]);
   plot(t1,y1,'b-',t2,(t2>=T),'r--')
   xlabel('Time (secs)')
   ylabel('Amplitude')

   % Display 0th, 1st, 2nd, 3rd, 4th, 5th..
   if n == 0, ntmp = 4; else ntmp = n; end
   str = ['st';'nd';'rd';'th'];  str = str((ntmp<4).*ntmp+4*(ntmp>3),:);
   
   disp(sprintf('Step response of %d%s-order Pade approximation',n,str));
   
   % Get frequency Wc where phase error becomes significant
   j = sqrt(-1);
   wc = log10(2*pi/T);        % initial guess
   w = logspace(wc-1,wc+3,50);
   fr = polyval(a,j*w)./polyval(b,j*w);
   phase = unwrap(atan2(imag(fr),real(fr)));
   phase0 = -w*T;               % exact phase shift
   idiff = find(abs(phase-phase0) > 0.1*abs(phase));
   wc = w(idiff(1));
   lwc = floor(log10(wc));
   if wc/10^lwc<5,  
      wc = lwc;  
   else  
      wc = lwc+1;  
   end
   
   % Get detailed phase profile around Wc
   w = logspace(wc-1,wc+1,100);
   fr = polyval(a,j*w)./polyval(b,j*w);
   phase1 = (180/pi)*unwrap(atan2(imag(fr),real(fr)));
   phase2 = -(180/pi)*w*T;    
   subplot(212)
   semilogx(w,phase1,'b',w,phase2,'r--')
   
   % Adjust y scale and set title
   if n ~= 0
     ylim = get(gca,'ylim');
     set(gca,'ylim',[max(ylim(1),2*min(phase1)), ylim(2)])
   end
   xlabel('Frequency (rad/s)')
   ylabel('Phase (deg.)')
   title('Phase response')
   
   
elseif no<=2,
    % Return NUM and DEN
    aout = a;

elseif no==3,
    % Return Z,P,K
    c = a(1)/b(1);
    aout = roots(a);
    b = roots(b);

else
    % Return A,B,C,D
    [aout,b,c,d] = compreal(a,b);
end
