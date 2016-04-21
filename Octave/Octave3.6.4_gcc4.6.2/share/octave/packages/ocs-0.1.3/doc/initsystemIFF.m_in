function  [varargout] = initsystemIFF(instruct,x);

  ## Check number of internal variables

  intvar = 0;

  ## NLC section


  nblocks = length(instruct.NLC);

  for ibl = 1:nblocks
    for iel = 1:instruct.NLC(ibl).nrows

      ## evaluate element
      
      il = instruct.NLC(ibl).vnmatrix(iel,:)';
      nzil = find(il!=0);
      
      y = zeros(size(il));
      y(nzil)=x(il(nzil));
      

      [a,b,c] = feval(instruct.NLC(ibl).func,...
		      instruct.NLC(ibl).section,...
		      instruct.NLC(ibl).pvmatrix(iel,:),...
		      instruct.NLC(ibl).parnames,...
		      y,[],0);

      instruct.NLC(ibl).nintvar(iel) = columns(a)-instruct.NLC(ibl).nextvar;
      instruct.NLC(ibl).osintvar(iel) = intvar;
      intvar += instruct.NLC(ibl).nintvar(iel);

    end	## endfor
  end ## endfor

  ## LCR section

  nblocks = length(instruct.LCR);

  for ibl = 1:nblocks
    for iel = 1:instruct.LCR(ibl).nrows
      
      ## evaluate element
      il = instruct.LCR(ibl).vnmatrix(iel,:)';
      nzil = find(il!=0);
      
      y = zeros(size(il));
      y(nzil)=x(il(nzil));
      
      
      [a,b,c] = feval(instruct.LCR(ibl).func,...
		      instruct.LCR(ibl).section,...
		      instruct.LCR(ibl).pvmatrix(iel,:),...
		      instruct.LCR(ibl).parnames,...
		      y,[],0);

      instruct.LCR(ibl).nintvar(iel) = columns(a)-instruct.LCR(ibl).nextvar;
      instruct.LCR(ibl).osintvar(iel) = intvar;
      intvar += instruct.LCR(ibl).nintvar(iel);
      
    end	## endfor
  end ## endfor

  
  instruct.totintvar = intvar;
  
  #####################################
  ##
  ## Build initial system
  ##
  #####################################   

  n = instruct.totextvar+instruct.totintvar;
  A = spalloc(n,n,0);
  
  ######
  ## LCR section
  ######

  B = spalloc(n,n,0);
  C = spalloc(n,1,0);

  nblocks = length(instruct.LCR);

  for ibl = 1:nblocks
    for iel = 1:instruct.LCR(ibl).nrows
      
      ## evaluate element
      
      if instruct.LCR(ibl).nintvar(iel)
	intvars = instruct.totextvar+instruct.LCR(ibl).osintvar(iel)+...
	    [1:instruct.LCR(ibl).nintvar(iel)]';
      else
	intvars=[];
      end

      il = instruct.LCR(ibl).vnmatrix(iel,:)';
      nzil = find(il!=0);
      
      y = zeros(size(il));
      y(nzil)=x(il(nzil));
     
      z = x(intvars);
      
      [a,b,c] = feval(instruct.LCR(ibl).func,...
		      instruct.LCR(ibl).section,...
		      instruct.LCR(ibl).pvmatrix(iel,:),...
		      instruct.LCR(ibl).parnames,...
		      y,z,0);
      
      ## assemble matrices
      
      vars = [il;intvars];
      
      for irow=1:rows(a)
	if (vars(irow))
	  for icol=1:columns(a)
	    if (vars(icol))
	      A(vars(irow),vars(icol)) += a(irow,icol);
	      B(vars(irow),vars(icol)) += b(irow,icol);
	    end ## endif
	  end ## endfor
	  C(vars(irow)) += c(irow);
	end ## endif
      end ## endfor
    end	## endfor
  end ## endfor

  varargout{4}=B;
  varargout{5}=C;

end ## endif

######
## NLC section
######

Jac = spalloc(n,n,0);
res = spalloc(n,1,0);

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
		    y,z,0);
    
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
	res(vars(irow)) +=...
	    c(irow);
      end ## endif
    end ## endfor
  end ## endfor	
end  ## endfor

varargout{1}=A;
varargout{2}=Jac;
varargout{3}=res;
varargout{6}=instruct; 
