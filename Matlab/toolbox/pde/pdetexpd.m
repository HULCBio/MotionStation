function f=pdetexpd(x,y,sd,u,ux,uy,t,f)
%PDETEXPD Evaluate an expression on triangles.

%       A. Nordmark 12-19-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:12:04 $

if ischar(f),
  ic=findstr(f,'!');
  nf=length(ic)+1;
  if nf>1,
    X=x;
    Y=y;
    SD=sd;
    U=u;
    UX=ux;
    UY=uy;
    nt=length(x);
    fff=zeros(1,nt);
    lf=length(f);
    ic=[0 ic lf+1];
    for ii=1:nf,
      ff=f(ic(ii)+1:ic(ii+1)-1);
      iii=find(SD==ii);
      x=X(iii);
      y=Y(iii);
      sd=SD(iii);
      if size(U),
        u=U(:,iii);
        ux=UX(:,iii);
        uy=UY(:,iii);
      end
     ffold=ff;
      try
          ff=eval(ffold);
      catch
          errstr=sprintf( ...
          '%s\n\nIn expression:\n%s\nwhen evaluating pde coefficients in subdomain %d.\n', ...
          lasterr,ffold,ii);
        error('PDE:pdetexpd:InvalidExpression', errstr);
      end
      if any(size(ff)-[1 1]) && any(size(ff)-size(x))
        errstr=sprintf( ...
          '%s\n\nIn expression:\n%s\nwhen evaluating pde coefficients in subdomain %d.\n', ...
          'Expression evaluates to wrong size',ffold,ii);
        error('PDE:pdetexpd:InvalidSizeFromExpression', errstr);
      end
      fff(iii)=ff.*ones(size(iii));
    end
    f=fff;
  else
   fold=f;
    try
        f=eval(fold);
    catch
       errstr=sprintf( ...
        '%s\n\nIn expression:\n%s\nwhen evaluating pde coefficients.\n', ...
        lasterr,fold);
      error('PDE:pdetexpd:InvalidExpression', errstr);
    end
    if any(size(f)-[1 1]) && any(size(f)-size(x))
      errstr=sprintf( ...
        '%s\n\nIn expression:\n%s\nwhen evaluating pde coefficients.\n', ...
        'Expression evaluates to wrong size',fold);
      error('PDE:pdetexpd:InvalidSizeFromExpression', errstr);
    end
  end
end

