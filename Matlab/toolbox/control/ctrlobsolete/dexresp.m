function dexresp(fun,ssflag) 
%DEXRESP Example response for discrete functions.
%
%	DEXRESP('fun')

%	Andrew Grace 7-9-90 
%	Revised 6-21-92
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.10 $  $Date: 2002/04/10 06:34:32 $

if nargin==1, ssflag=0; end;

order=round(abs(randn(1,1))*5+2);
disp('')
disp(sprintf(' Here is an example of how the function %s works:',fun));
disp('')
disp(' Consider a randomly generated stable Transfer Function Model')
disp(' of the form G(z)=num(z)/den(z):')
[num,den]=drmodel(order)
Ts = exp(randn(1,1)-2)
if ssflag, 
  disp('Transform to state space with: [a,b,c,d] = tf2ss(num,den);');
  [a,b,c,d] = tf2ss(num,den);
  call=[fun,'(a,b,c,d,Ts);'];
else
  call=[fun,'(num,den,Ts);'];
end
disp('')
disp(sprintf('Call %s using the following command (see also, help %s):',fun,fun));
disp('')
disp(call)
disp('')
eval(call)
