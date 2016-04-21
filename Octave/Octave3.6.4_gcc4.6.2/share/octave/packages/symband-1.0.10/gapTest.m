function estimate=gapTest(Lambda,err)
% estimate=gapTest(Lambda,err)
%   compute the errors using the gap test
%   Lambda and err are results of a call to [Lambda,{Ev,err}] = SBEig(A,V,tol)

if nargin!=2 error("nargin !=2 in function gaptest") endif

len=length(Lambda);
estimate=Lambda;

for k=1:len;
  estimate(k)=err(k)^2/min(sort(abs(Lambda-Lambda(k)))(2:len));
endfor

endfunction
