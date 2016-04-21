function pdemtx=pdetrans(strmtx,type)
%PDETRANS Translates application specific PDE coefficients into generic
%       PDE coefficients that fit the ASSEMPDE, PARABOLIC and HYPERBOLIC syntax
%
%       PDEMTX=PDETRANS(STRMTX,TYPE)
%
%       The application specific coefficients, stored in STRMTX (one per row),
%       are converted to standard PDE Toolbox coefficients (c, a, f, and d),
%       which are stored in the string matrix PDEMTX ([c; a; f; d]).
%       The application type is passed in the flag TYPE.

%       Magnus Ringh 12-12-94, MR 9-02-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:06 $

if nargin<2,
  pdetool('error','  Too few input arguments.')
  return
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
if type==1                              % Generic scalar
  [nc, cr]=pdecchk(strmtx(1,:));
  pdemtx=str2mat(cr,strmtx(2:size(strmtx,1),:));
  setappdata(pde_fig,'ncafd',[nc 1 1 1])
elseif type==2                          % Generic system
  c=strmtx([1 2 8 9],:);
  [nc,cr]=pdecchk(c);
  a=strmtx([3 4 10 11],:);
  f=strmtx([5 12],:);
  d=strmtx([6 7 13 14],:);
  pdemtx=str2mat(cr,a,f,d);
  setappdata(pde_fig,'ncafd',[nc 4 2 4])
elseif type==3,                         % Structural mechanics, plane stress case
  E=deblank(strmtx(1,:)); nu=deblank(strmtx(2,:));
  G=['(', E, ')./(2*(1+(', nu, ')))'];
  mu=['2*(', G, ').*(', nu, ')./(1-(', nu, '))'];
  c1=['2*(', G, ')+(', mu, ')'];
  c2='0';
  c3=G;
  c4='0';
  c5=G;
  c6=mu;
  c7='0';
  c=str2mat(c1,c2,c3,c4,c5,c6,c7,c3,c2,c1);
  a=str2mat('0.0','0.0','0.0','0.0');
  f=strmtx(3:4,:);
  rho=deblank(strmtx(5,:));
  d=str2mat(rho,'0','0',rho);
  pdemtx=str2mat(c,a,f,d);
  setappdata(pde_fig,'ncafd',[10 4 2 4])
elseif type==4,                         % Structural mechanics, plane strain case
  E=deblank(strmtx(1,:)); nu=deblank(strmtx(2,:));
  G=['(', E, ')./(2*(1+(', nu, ')))'];
  mu=['2*(', G, ').*(', nu, ')./(1-2*(', nu, '))'];
  c1=['2*(', G, ')+(', mu, ')'];
  c2='0';
  c3=G;
  c4='0';
  c5=G;
  c6=mu;
  c7='0';
  c=str2mat(c1,c2,c3,c4,c5,c6,c7,c3,c2,c1);
  a=str2mat('0.0','0.0','0.0','0.0');
  f=strmtx(3:4,:);
  rho=deblank(strmtx(5,:));
  d=str2mat(rho,'0','0',rho);
  pdemtx=str2mat(c,a,f,d);
  setappdata(pde_fig,'ncafd',[10 4 2 4])
elseif type==5,                         % Electrostatics
  [nc,c]=pdecchk(strmtx(1,:));          % epsilon (may be anisotropic)
  f=strmtx(2,:);                        % rho
  a='0.0';
  pdemtx=str2mat(c,a,f,'1.0');
  setappdata(pde_fig,'ncafd',[nc 1 1 1])
elseif type==6,                         % Magnetostatics
  c=['1./(', deblank(strmtx(1,:)) ')']; % 1/mu
  f=deblank(strmtx(2,:));               % i
  a='0.0';
  pdemtx=str2mat(c,a,f,'1.0');
  setappdata(pde_fig,'ncafd',ones(1,4))
elseif type==7,                         % AC electromagnetics
  c=['1./(' deblank(strmtx(2,:)) ')'];  % 1/mu
  a=sprintf('sqrt(-1)*(%s).*(%s)-(%s).*(%s).*(%s)',...
      deblank(strmtx(1,:)),deblank(strmtx(3,:)),deblank(strmtx(1,:)),...
      deblank(strmtx(1,:)),deblank(strmtx(4,:)));
  % j*omega*sigma-omega^2*epsilon
  f='0.0';
  pdemtx=str2mat(c,a,f,'1.0');
  setappdata(pde_fig,'ncafd',ones(1,4))
elseif type==8,                         % DC analysis in Conductive Media
  [nc, c]=pdecchk(strmtx(1,:));         % sigma (may be anisotropic)
  f=strmtx(2,:);                        % q
  a='0.0';
  pdemtx=str2mat(c,a,f,'1.0');
  setappdata(pde_fig,'ncafd',[nc 1 1 1])
elseif type==9,                         % Heat transfer
  d=sprintf('(%s).*(%s)',deblank(strmtx(1,:)),deblank(strmtx(2,:)));
  % rho*C
  [nc, c]=pdecchk(strmtx(3,:));         % k (may be anisotropic)
  f=sprintf('(%s)+(%s).*(%s)',deblank(strmtx(4,:)),...
      deblank(strmtx(5,:)),deblank(strmtx(6,:)));
  % Q + h*Text
  a=deblank(strmtx(5,:));               % h
  pdemtx=str2mat(c,a,f,d);
  setappdata(pde_fig,'ncafd',[nc 1 1 1])
elseif type==10,                        % Diffusion
  d='1.0';
  [nc, c]=pdecchk(strmtx(1,:));         % D (may be anisotropic)
  f=strmtx(2,:);                        % Q
  a='0.0';
  pdemtx=str2mat(c,a,f,d);
  setappdata(pde_fig,'ncafd',[nc 1 1 1])
end

