function int = innerfun(fun,lowerlim,upperlim,nquad,n,level,x,quadrule)
%
%usage:  int = innerfun(fun,lowerlim,upperlim,nquad,n,level,x,quadrule);
%

int = 0;
[bp,wf]=feval(quadrule,nquad(level));

xx=x;
qx=(upperlim(level)-lowerlim(level))./2;
px=(upperlim(level)+lowerlim(level))./2;
xlevel=qx.*bp+px;

nl=nquad(level);
if ( level == 1 )
  for i=1:nl
    xx(level)=xlevel(i);
    int = int + wf(i) .* feval(fun,xx);
  endfor
else
  for i=1:nl
    xx(level)=xlevel(i);
    vint = innerfun(fun,lowerlim,upperlim,nquad,n,level-1,xx,quadrule);
    int = int + wf(i) .* vint;
  endfor
endif

int = int .* qx;

endfunction
