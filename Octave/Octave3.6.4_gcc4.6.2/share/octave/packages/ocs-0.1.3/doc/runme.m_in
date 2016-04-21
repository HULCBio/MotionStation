exmpl ="nmos"
out=[];
nrm=[];


switch exmpl
  case "nmos"
    outstruct = parseIFF("nmos");
    x = [1 .03 1 0 0]';
    t = linspace(0,1,50);
    dmp = .1;
    pltvars={"Vgate","Vdrain"};
  case "pmos"
    outstruct = parseIFF("pmos");
    x = [1  .1 1 0 -1e-6]';
    t = linspace(0,.5,50)
    dmp = .1;
    pltvars={"Vgate","Vdrain"};
  case "inverter"
    outstruct = parseIFF("inverter");
    x = [.5  .5   1   0   0]';
    t = linspace(0,1,50);
    dmp=.1;
    pltvars={"Vgate","Vdrain"};
  case "and"
    outstruct = parseIFF("and");
    x = [.5 .5 .33 .66 .5 1 0 0 1]';
    t = linspace(0,.5,50);
    dmp = .1;
    pltvars = {"Va","Vb","Va_and_b"};
end

tol = 1e-6;
dtol= 1e-5;
maxit = 200;

[A,Jac,res,B,C,outstruct] = initsystemIFF(outstruct,x,0);

for it=1:length(t)
  for ii=1:maxit
    
    if (t(it)>0)|(ii>1)
      [A,Jac,res] = buildsystemIFF(outstruct,x,t(it));
    end

    xnew = (B+Jac)\(-res - C + Jac*x);
    nrm(it) = norm(x-xnew,inf);
    
    damp = dmp;
    if (ii>2)&(nrm(it)<dtol), damp=1; end
    x = (1-damp)*x+damp*xnew;
    
    if nrm(it)<tol 
      fprintf(1,'timestep %d converged in %d iterations\n',it,ii);
      x = xnew;
      out(:,it) = x;
      break
    elseif ii==maxit
      fprintf(1,'timestep %d did not converge, nrm=%g\n',it,nrm(it))
      x = xnew;
      out(:,it) = x;
      break
    end
    
  end
  if it>1
    axis([min(t) max(t) 0 1]);
    plotbynameIFF(t(1:it),out,outstruct,pltvars)
  end
end
