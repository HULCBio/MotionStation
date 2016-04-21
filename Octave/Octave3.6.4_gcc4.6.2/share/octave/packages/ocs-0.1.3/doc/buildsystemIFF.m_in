function  [varargout] = buildsystemIFF(instruct,x,t);

  ## [varargout] = buildsystemIFF(instruct,x,t)

  n = instruct.totextvar+instruct.totintvar;
  A = spalloc(n,n,0);
  Jac = spalloc(n,n,0);
  res = spalloc(n,1,0);
  
  ## NLC section


  nblocks = length(instruct.NLC);

  for ibl = 1:nblocks
    for iel = 1:instruct.NLC(ibl).nrows

      ## evaluate element
      
      if instruct.NLC(ibl).nintvar(iel)    
    intvars = instruct.totextvar+instruct.NLC(ibl).osintvar(iel)+...
	[1:instruct.NLC(ibl).nintvar(iel)]';
	  else
	  intvars=[];
	  end
    
      il = instruct.NLC(ibl).vnmatrix(iel,:)';
      nzil = find(il!=0);
      
      y = zeros(size(il));
      y(nzil)=x(il(nzil));
      
      z = x(intvars);
      
      [a,b,c] = feval(instruct.NLC(ibl).func,...
		      instruct.NLC(ibl).section,...
		      instruct.NLC(ibl).pvmatrix(iel,:),...
		      instruct.NLC(ibl).parnames,...
		      y,z,t);
      
          ## assemble matrices

    vars = [il;intvars];

    for irow=1:rows(a)
      if (vars(irow))
	for icol=1:columns(a)
	  if (vars(icol))
	    A(vars(irow),vars(icol)) += a(irow,icol);
	    Jac(vars(irow),vars(icol)) += b(irow,icol);
	  end ## endif
	end ## endfor
	res(vars(irow)) += c(irow);

	end ## endif
      end ## endfor
    end ## endfor	
  end  ## endfor

  varargout{1}=A;
  varargout{2}=Jac;
  varargout{3}=res;
