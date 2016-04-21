function exresp(fun,ssflag) 
%EXRESP Example response, used by plotting control routines to give
%       an example or their use.
%	EXRESP('fun')
%	EXRESP('fun',ssflag)

%	Andrew Grace  7-9-90
%	Revised ACWG 6-21-92
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.12 $  $Date: 2002/04/10 06:33:35 $

if nargin==1, ssflag = 0; end

order=round(abs(randn(1,1))*5+2);
disp('')
disp(sprintf(' Here is an example of how the function %s works:',fun));
disp('')
disp(' Consider a randomly generated stable Transfer Function Model:')
if fun(1)=='d'
  disp(' of the form G(z)=num(z)/den(z):')
  [num,den]=drmodel(order)
else
  disp(' of the form G(s)=num(s)/den(s):')
  [num,den]=rmodel(order)
end
if ssflag, 
  disp('Transform to state space with: [a,b,c,d] = tf2ss(num,den);');
  [a,b,c,d] = tf2ss(num,den);
  call=[fun,'(ss(a,b,c,d));'];
else
  call=[fun,'(tf(num,den));'];
end
disp('')
disp(sprintf('Call %s using the following command (see also, help %s):',fun,fun));
disp('')
disp(call)
disp('')

try
   eval(call)
catch
   lasterr
end

