function [data,string]=...
pdeptdata(prop,type,p,e,t,c,u,appl,params,hndls,time)
%PDEPTDATA Compute data and labels for PDETOOL plots.

%       Magnus Ringh 04-18-95, MR 09-11-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:45 $

if nargin<11,
  time=[];
end

if appl>1 && appl<5,
  syst=1;
else
  syst=0;
end
nnode=size(p,2);

userflag=0;

if type==1,
% xydata:
  if prop==1,
    if syst,
    % u
      data=u(1:nnode);
      string='u';
    else
    % u
      data=u;
      if appl==5 || appl==8,
        string='V';
      elseif appl==6
        string='A';
      elseif appl==7
        string='E';
      elseif appl==9,
        string='T';
      elseif appl==10
        string='c';
      else
        string='u';
      end
    end
  elseif prop==2,
    if syst,
    % v
      data=u(nnode+1:2*nnode);
      string='v';
    elseif appl==7,
    % AC Power Electromagnetics case: abs(B)=abs(j/omega*curl(E))
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=(1./omega).*sqrt(ux.^2+uy.^2);
      string='abs(B)';
    else
      % abs(grad(u))
      [ux,uy]=pdegrad(p,t,u);
      data=sqrt(ux.^2+uy.^2);
      if appl==5 || appl==8,
        string='abs(E)';
      elseif appl==6
        string='abs(B)';
      elseif appl==9,
        string='abs(grad(T))';
      elseif appl==10
        string='abs(grad(c))';
      else
        string='abs(grad(u))';
      end
    end
  elseif prop==3,
    if syst,
    % abs(u,v)
      data=sqrt(u(1:nnode).^2+u(nnode+1:2*nnode).^2);
      string='abs(u,v)';
    elseif appl==7,
    % AC Power Electromagnetics case: abs(H)=abs(1/mu*j/omega*curl(E))
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      mu=pdetxpd(p,t,u,[],deblank(params(2,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=(1./mu).*(1./omega).*sqrt(ux.^2+uy.^2);
      string='abs(H)';
    else
      % abs(c*grad(u))
      [ux,uy]=pdecgrad(p,t,c,u,time);
      data=sqrt(ux.^2+uy.^2);
      if appl==5
        string='abs(D)';
      elseif appl==6
        string='abs(H)';
      elseif appl==8,
        string='abs(J)';
      elseif appl==9 || appl==10,
        string='abs(q)';
      else
        string='abs(c*grad(u))';
      end
    end
  elseif prop==4,
    % structural mechanics:
    if (appl==3 || appl==4),
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      string='ux';
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    elseif appl==7,
    % AC Power Electromagnetics case: i=sigma*E
      sigma=pdetxpd(p,t,u,[],deblank(params(3,:)));
      if length(sigma)==size(t,2)
        sigma=pdeprtni(p,t,sigma);
      end
      data=sigma.*u;
      string='i';
    else
      userflag=1;
    end
  elseif prop==5,
    % structural mechanics:
    if (appl==3 || appl==4),
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      string='uy';
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    elseif appl==7,
    % AC Power Electromagnetics case: Q=E^2/sigma
      sigma=pdetxpd(p,t,u,[],deblank(params(3,:)));
      if length(sigma)==size(t,2)
        sigma=pdeprtni(p,t,sigma);
      end
      data=u.*u.*sigma;
      string='Q';
    else
      data=[];
      string='';
    end
  elseif prop==6,
    % structural mechanics:
    if (appl==3 || appl==4),
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      string='vx';
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    elseif appl==7,
    % AC Power Electromagnetics case: user entry
      userflag=1;
    else
      data=[];
      string='';
    end
  elseif prop>6,
    % structural mechanics:
    if prop==19,
      % user entry:
      userflag=1;
    else
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      if prop==7,
        string='vy';
      elseif prop==8,
        string='exx';
      elseif prop==9,
        string='eyy';
      elseif prop==10,
        string='exy';
      elseif prop==11,
        string='sxx';
      elseif prop==12,
        string='syy';
      elseif prop==13,
        string='sxy';
      elseif prop==14,
        string='e1';
      elseif prop==15,
        string='e2';
      elseif prop==16,
        string='s1';
      elseif prop==17,
        string='s2';
      elseif prop==18,
        string='von Mises';
      end
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    end
  else
    data=[];
    string='';
  end

  if userflag,
    if syst
      [uvx,uvy]=pdegrad(p,t,u);
      ux=uvx(1,:); ux=pdeprtni(p,t,ux);
      vx=uvx(2,:); vx=pdeprtni(p,t,vx);
      uy=uvy(1,:); uy=pdeprtni(p,t,uy);
      vy=uvy(2,:); vy=pdeprtni(p,t,vy);
      [cuvx,cuvy]=pdecgrad(p,t,c,u,time);
      cux=cuvx(1,:); cux=pdeprtni(p,t,cux);
      cvx=cuvx(2,:); cvx=pdeprtni(p,t,cvx);
      cuy=cuvy(1,:); cuy=pdeprtni(p,t,cuy);
      cvy=cuvy(2,:); cvy=pdeprtni(p,t,cvy);
      usave=u;
      u=usave(1:nnode);
      v=usave(nnode+1:2*nnode);
    else
      [ux,uy]=pdegrad(p,t,u);
      ux=pdeprtni(p,t,ux);
      uy=pdeprtni(p,t,uy);
      [cux,cuy]=pdecgrad(p,t,c,u,time);
      cux=pdeprtni(p,t,cux);
      cuy=pdeprtni(p,t,cuy);
    end
    x=p(1,:)'; y=p(2,:)';
    if ~isempty(hndls),
      ustr=deblank(get(hndls(12),'String'));
    else
      ustr='NaN';
    end
    tri=t; t=time;
    utmp=eval(ustr,'NaN');
    t=tri;
    if isempty(utmp) || isempty(ustr),
      pdetool('error',' No user entry supplied.')
      data=NaN; string='';
      return;
    elseif isnan(utmp),
      pdetool('error',sprintf(' Unable to evaluate ''%s''.',ustr))
      data=NaN; string='';
      return;
    else
      data=utmp;
      string=ustr;
    end
    if syst
      u=usave;
    end
  end

elseif type==2,
% zdata
  userflag=0;
  if prop==1,
    if syst,
      % u
      data=u(1:nnode);
      string='u';
    else
      % u
      data=u;
      if appl==5 || appl==8,
        string='V';
      elseif appl==6
        string='A';
      elseif appl==5
        string='E';
      elseif appl==9,
        string='T';
      elseif appl==10
        string='c';
      else
        string='u';
      end
    end
  elseif prop==2,
    if syst,
      % v
      data=u(nnode+1:2*nnode);
      string='v';
    elseif appl==7,
      % AC Power Electromagnetics case: abs(B)=abs(j/omega*curl(E))
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=(1./omega).*sqrt(ux.^2+uy.^2);
      string='abs(B)';
    else
      % abs(grad(u))
      [ux,uy]=pdegrad(p,t,u);
      data=sqrt(ux.^2+uy.^2);
      if appl==5 || appl==8,
        string='abs(E)';
      elseif appl==6
        string='abs(B)';
      elseif appl==9,
        string='abs(grad(T))';
      elseif appl==10
        string='abs(grad(c))';
      else
        string='abs(grad(u))';
      end
    end
  elseif prop==3,
    if syst,
      % abs(u,v)
      data=sqrt(u(1:nnode).^2+u(nnode+1:2*nnode).^2);
      string='abs(u,v)';
    elseif appl==7,
      % AC Power Electromagnetics case: abs(H)=abs(1/mu*j/omega*curl(E))
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      mu=pdetxpd(p,t,u,[],deblank(params(2,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=(1./mu).*(1./omega).*sqrt(ux.^2+uy.^2);
      string='abs(H)';
    else
      % abs(c*grad(u))
      [ux,uy]=pdecgrad(p,t,c,u,time);
      data=sqrt(ux.^2+uy.^2);
      if appl==5
        string='abs(D)';
      elseif appl==6
        string='abs(H)';
      elseif appl==8,
        string='abs(J)';
      elseif appl==9 || appl==10,
        string='abs(q)';
      else
        string='abs(grad(u))';
      end
    end
  elseif prop==4,
    % structural mechanics:
    if (appl==3 || appl==4),
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      string='ux';
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    elseif appl==7,
    % AC Power Electromagnetics case: i=sigma*E
      sigma=pdetxpd(p,t,u,[],deblank(params(3,:)));
      if length(sigma)==size(t,2)
        sigma=pdeprtni(p,t,sigma);
      end
      data=sigma.*u;
      string='i';
    else
      userflag=1;
    end
  elseif prop==5,
    % structural mechanics:
    if (appl==3 || appl==4),
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      string='uy';
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    elseif appl==7,
    % AC Power Electromagnetics case: Q=E^2/sigma
      sigma=pdetxpd(p,t,u,[],deblank(params(3,:)));
      if length(sigma)==size(t,2)
        sigma=pdeprtni(p,t,sigma);
      end
      data=u.*u./sigma;
      string='Q';
    else
      data=[];
      string='';
    end
  elseif prop==6,
    % structural mechanics:
    if (appl==3 || appl==4),
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      string='vx';
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    elseif appl==7,
    % AC Power Electromagnetics case: user entry
      userflag=1;
    else
      data=[];
      string='';
    end
  elseif prop>6,
    % structural mechanics:
    if prop==19,
      % user entry:
      userflag=1;
    else
      if appl==3,
        ap='ps';
      elseif appl==4,
        ap='pn';
      end
      if prop==7,
        string='vy';
      elseif prop==8,
        string='exx';
      elseif prop==9,
        string='eyy';
      elseif prop==10,
        string='exy';
      elseif prop==11,
        string='sxx';
      elseif prop==12,
        string='syy';
      elseif prop==13,
        string='sxy';
      elseif prop==14,
        string='e1';
      elseif prop==15,
        string='e2';
      elseif prop==16,
        string='s1';
      elseif prop==17,
        string='s2';
      elseif prop==18,
        string='von Mises';
      end
      data=pdesmech(p,t,c,u,'tensor',string,'application',ap);
    end
  else
    data=[];
    string='';
  end

  if userflag,
    if syst
      [uvx,uvy]=pdegrad(p,t,u);
      ux=uvx(1,:); ux=pdeprtni(p,t,ux);
      vx=uvx(2,:); vx=pdeprtni(p,t,vx);
      uy=uvy(1,:); uy=pdeprtni(p,t,uy);
      vy=uvy(2,:); vy=pdeprtni(p,t,vy);
      [cuvx,cuvy]=pdecgrad(p,t,c,u,time);
      cux=cuvx(1,:); cux=pdeprtni(p,t,cux);
      cvx=cuvx(2,:); cvx=pdeprtni(p,t,cvx);
      cuy=cuvy(1,:); cuy=pdeprtni(p,t,cuy);
      cvy=cuvy(2,:); cvy=pdeprtni(p,t,cvy);
      usave=u;
      u=usave(1:nnode);
      v=usave(nnode+1:2*nnode);
    else
      [ux,uy]=pdegrad(p,t,u);
      ux=pdeprtni(p,t,ux);
      uy=pdeprtni(p,t,uy);
      [cux,cuy]=pdecgrad(p,t,c,u,time);
      cux=pdeprtni(p,t,cux);
      cuy=pdeprtni(p,t,cuy);
    end
    x=p(1,:)'; y=p(2,:)';
    if ~isempty(hndls),
      ustr=deblank(get(hndls(15),'String'));
    else
      ustr='NaN';
    end
    tri=t; t=time;
    utmp=eval(ustr,'NaN');
    t=tri;
    if isempty(utmp) || isempty(ustr),
      pdetool('error',' No user entry supplied.')
      data=NaN; string='';
      return;
    elseif isnan(utmp),
      pdetool('error',sprintf(' Unable to evaluate ''%s''.',ustr))
      data=NaN; string='';
      return;
    else
      data=utmp;
      string=ustr;
    end
    if syst
      u=usave;
    end
  end

elseif type==3,
% flowdata:
  if prop==1,
    if syst,
    % (u,v)
      tmp=[u(1:nnode); u(nnode+1:2*nnode)];
      data=pdeintrp(p,t,tmp);
      string='(u,v)';
    elseif appl==6,
      % Magnetostatics case, B=curl(A)
      [ux,uy]=pdegrad(p,t,u);
      data=[uy; -ux];
      string='B';
    elseif appl==7,
      % AC Power Electromagnetics case, B=j/omega*curl(E)
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=[(1./omega).*uy; -(1./omega).*ux];
      string='B';
    else
      % grad u
      [ux,uy]=pdegrad(p,t,u);
      data=[-ux; -uy];
      if appl==5 || appl==8,
        string='E';
      elseif appl==9,
        string='-grad(T)';
      elseif appl==10,
        string='-grad(c)';
      else
        string='-grad(u)';
      end
    end
  elseif prop==2 && ~syst,
    if appl==6,
    % Magnetostatics case, H=(1/mu)*curl(A)
      [ux,uy]=pdecgrad(p,t,c,u,time);
      data=[uy; -ux];
      string='H';
    elseif appl==7,
    % AC Power Electromagnetics case, H=1/mu*j/omega*curl(E)
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      mu=pdetxpd(p,t,u,[],deblank(params(2,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=[(1./mu).*(1./omega).*uy; -(1./mu).*(1./omega).*ux];
      string='H';
    else
    % c*grad(u) (scalar case only)
      [ux,uy]=pdecgrad(p,t,c,u,time);
      data=[-ux; -uy];
      if appl==5
        string='E';
      elseif appl==8,
        string='J';
      elseif appl==9 || appl==10,
        string='q';
      else
        string='-c*grad(u)';
      end
    end
  elseif prop==3 || (prop==2 & syst),
  % user entry
    if syst
      [uvx,uvy]=pdegrad(p,t,u);
      ux=uvx(1,:);
      vx=uvx(2,:);
      uy=uvy(1,:);
      vy=uvy(2,:);
      [cuvx,cuvy]=pdecgrad(p,t,c,u,time);
      cux=cuvx(1,:);
      cvx=cuvx(2,:);
      cuy=cuvy(1,:);
      cvy=cuvy(2,:);
      usave=u;
      u=usave(1:nnode);
      v=usave(nnode+1:2*nnode);
    else
      [ux,uy]=pdegrad(p,t,u);
      [cux,cuy]=pdecgrad(p,t,c,u,time);
    end
    x=p(1,:)'; x=pdeintrp(p,t,x);
    y=p(2,:)'; y=pdeintrp(p,t,y);
    if ~isempty(hndls),
      ustr=deblank(get(hndls(13),'String'));
    else
      ustr='NaN';
    end
    tri=t; t=time;
    utmp=eval(ustr,'NaN');
    t=tri;
    if isempty(utmp) || isempty(ustr),
      pdetool('error',' No user entry supplied.')
      data=NaN; string='';
      return;
    elseif isnan(utmp),
      pdetool('error',sprintf(' Unable to evaluate ''%s''.',ustr))
      data=NaN; string='';
      return;
    else
      [n,m]=size(utmp);
      if n~=2 || m~=size(t,2),
        if n*m~=2*nnode,
          pdetool('error',' Incorrect data format.')
          data=NaN; string='';
          return;
        end
        utmp=utmp(:);
        tmp=[utmp(1:nnode); utmp(nnode+1:2*nnode)];
        data=pdeintrp(p,t,tmp);
      else
        data=utmp;
      end
        string=ustr;
    end
    if syst
      u=usave;
    end
  else
    data=[];
    string='';
  end

elseif type==4,
% deformdata:
  if prop==1,
    if syst,
    % (u,v)
      tmp=[u(1:nnode); u(nnode+1:2*nnode)];
      data=tmp;
      string='(u,v)';
    elseif appl==6,
      % Magnetostatics case, B=curl(A)
      [ux,uy]=pdegrad(p,t,u);

      data=pdeprtni(p,t,[uy;-ux]);
      string='B';
    elseif appl==7,
      % AC Power Electromagnetics case, B=j/omega*curl(E)
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=pdeprtni(p,t,[(1./omega).*uy; -(1./omega).*ux]);
      string='B';
    else
      % grad u
      [ux,uy]=pdegrad(p,t,u);
      data=pdeprtni(p,t,[-ux; -uy]);
      if appl==5 || appl==8,
        string='E';
      elseif appl==9,
        string='-grad(T)';
      elseif appl==10,
        string='-grad(c)';
      else
        string='-grad(u)';
      end
    end
  elseif prop==2 && ~syst,
    if appl==6,
    % Magnetostatics case, H=(1/mu)*curl(A)
      [ux,uy]=pdecgrad(p,t,c,u,time);
      data=pdeprtni(p,t,[uy; -ux]);
      string='H';
    elseif appl==7,
    % AC Power Electromagnetics case, H=1/mu*j/omega*curl(E)
      omega=pdetxpd(p,t,u,[],deblank(params(1,:)));
      mu=pdetxpd(p,t,u,[],deblank(params(2,:)));
      [ux,uy]=pdegrad(p,t,u);
      data=pdeprtni(p,t,[(1./mu).*(1./omega).*uy; -(1./mu).*(1./omega).*ux]);
      string='H';
    else
    % c*grad(u) (scalar case only)
      [ux,uy]=pdecgrad(p,t,c,u,time);
      data=pdeprtni(p,t,[-ux; -uy]);
      if appl==5
        string='E';
      elseif appl==8,
        string='J';
      elseif appl==9 || appl==10,
        string='q';
      else
        string='-c*grad(u)';
      end
    end
  elseif prop==3 || (prop==2 && syst),
  % user entry
    if syst
      [uvx,uvy]=pdegrad(p,t,u);
      ux=uvx(1,:);
      vx=uvx(2,:);
      uy=uvy(1,:);
      vy=uvy(2,:);
      [cuvx,cuvy]=pdecgrad(p,t,c,u,time);
      cux=cuvx(1,:);
      cvx=cuvx(2,:);
      cuy=cuvy(1,:);
      cvy=cuvy(2,:);
      usave=u;
      u=usave(1:nnode);
      v=usave(nnode+1:2*nnode);
    else
      [ux,uy]=pdegrad(p,t,u);
      [cux,cuy]=pdecgrad(p,t,c,u,time);
    end
    x=p(1,:)'; x=pdeintrp(p,t,x);
    y=p(2,:)'; y=pdeintrp(p,t,y);
    if ~isempty(hndls),
      ustr=deblank(get(hndls(14),'String'));
    else
      ustr='NaN';
    end
    tri=t; t=time;
    utmp=eval(ustr,'NaN');
    t=tri;
    if isempty(utmp) || isempty(ustr),
      pdetool('error',' No user entry supplied.')
      data=NaN; string='';
      return;
    elseif isnan(utmp),
      pdetool('error',sprintf(' Unable to evaluate ''%s''.',ustr))
      data=NaN; string='';
      return;
    else
      [n,m]=size(utmp);
      if n~=2 || m~=size(t,2),
        if n*m~=2*nnode,
          pdetool('error',' Incorrect data format.')
          data=NaN; string='';
          return;
        end
        utmp=utmp(:);
        tmp=[utmp(1:nnode); utmp(nnode+1:2*nnode)];
        data=pdeintrp(p,t,tmp);
      else
        data=utmp;
      end
        string=ustr;
    end
    if syst
      u=usave;
    end
    data=pdeprtni(p,t,data);
  else
    data=[];
    string='';
  end
  data = real(data);
end

