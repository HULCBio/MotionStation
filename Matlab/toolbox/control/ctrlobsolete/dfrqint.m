function w = dfrqint(a,b,c,d,Ts,npts)
%DFRQINT Discrete auto-ranging algorithm for DBODE plots.
%   W=DFRQINT(A,B,C,D,Ts,NPTS)
%   W=DFRQINT(NUM,DEN,Ts,NPTS)

%   Clay M. Thompson 7-10-90
%   Revised ACWG 11-25-91
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:34:29 $

if nargin==4,
   Ts = c; 
   npts = d;
   [a,b,c,d] = tf2ss(a,b);
end
[a1,b1] = d2cm(a,b,c,d,Ts,'tustin');
w = freqint(a1,b1,c,d,npts);
w = w(find(w<=pi/Ts));
if ~isempty(w), 
   w = sort([w(:); linspace(min(w),pi/Ts,128).']);
else
   w = linspace(pi/Ts/10,pi/Ts,128).';
end

% end dfrqint
