function out=pdesmech(p,t,c,u,p1,v1,p2,v2,p3,v3,p4,v4)
%PDESMECH  Calculates structural mechanics tensor functions.
%
%       OUT=PDESMECH(P,T,C,U,P1,V1,...) computes tensor expressions such
%       as stresses and strains for plane stress and plane strain structural
%       mechanics applications.
%       P and T are the mesh point and triangle matrices, respectively,
%       C is the PDE equation's C coefficient, U = PDE solution [u; v] of
%       length 2*number of nodes.
%
%       Valid Property/value pairs include
%
%       tensor          {vonMises} | ux | uy | vx | vy | exx | eyy | exy |
%                       sxx | syy | sxy | e1 | e2 | s1 | s2
%       application     {ps} | pn
%       nu              {0.3} numerical value or string expression

%       Magnus Ringh 1-16-95, MR 6-13-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.2 $  $Date: 2003/11/18 03:11:59 $


% Error checks
nargs = nargin;
if nargs<4,
  error('PDE:pdesmech:nargin', 'Too few input arguments.')
elseif rem(nargs,2)~=0,
  error('PDE:pdesmech:NoPropPairs', 'Property/value pairs expected.')
end

% Default values
tensor='vonmises';
application='ps';
nu=0.3;

% Recover Property/value pairs from argument list
for i=1:2:nargs-5,
  Param = eval(['p' int2str((i-1)/2 +1)]);
  Value = eval(['v' int2str((i-1)/2 +1)]);
  if ~ischar(Param),
    error('PDE:pdesmech:ParamNotString', 'Parameter must be a string.')
  elseif size(Param,1)~=1,
    error('PDE:pdesmech:ParamNumRowsOrEmpty',...
        'Parameter must be a non-empty single row string.')
  end
  Param = lower(Param);
  if strcmp(Param,'tensor'),
    tensor=lower(Value);
    if ~ischar(tensor),
      error('PDE:pdesmech:TensorNotString', 'tensor must be a string.')
    elseif ~(strcmp(tensor,'vonmises') || strcmp(tensor,'von mises') || ...
      strcmp(tensor,'ux') || strcmp(tensor,'uy') || ...
      strcmp(tensor,'vx') || strcmp(tensor,'vy') || ...
      strcmp(tensor,'exx') || strcmp(tensor,'eyy') || strcmp(tensor,'exy') || ...
      strcmp(tensor,'sxx') || strcmp(tensor,'syy') || strcmp(tensor,'sxy') || ...
      strcmp(tensor,'e1') || strcmp(tensor,'e2') ||  ...
      strcmp(tensor,'s1') || strcmp(tensor,'s2')),
        error('PDE:pdesmech:InvalidTensorOption',...
            ['tensor must be vonMises | ux | uy | vx | vy | exx | eyy | ',...
          'sxx | syy | sxy | e1 | e2 | s1 | s2'])
    end
  elseif strcmp(Param,'application'),
    application=lower(Value);
    if ~ischar(application),
      error('PDE:pdesmech:ApplicationNotString', 'application must be a string.')
    elseif ~(strcmp(application,'ps') || strcmp(application,'pn')),
      error('PDE:pdesmech:ApplicationInvalidOption', 'application must be ps | pn')
    end
  elseif strcmp(Param,'nu'),
    nu=lower(Value);
    if ischar(nu),
      try
         nu=pdetxpd(p,t,u,nu);
      catch
      	 nu=NaN;
      end
    end
    if nu>0.5 || nu<0 || ~isreal(nu) || isnan(nu),
      error('PDE:pdesmech:NuInvalidRangeOrComplex',...
          'nu must be real and smaller than 0.5 and greater than 0.')
    end
  else
    error('PDE:pdesmech:InvalidParam', ['Unknown parameter: ' Param])
  end
end

nnode=size(p,2);
if length(u)~=2*nnode,
  error('PDE:pdesmech:LengthU',...
      'u must be of 2-dimensional system type (length=2*number of nodes)')
end

if strcmp(tensor,'ux'),
  mode=1;
elseif strcmp(tensor,'uy'),
  mode=2;
elseif strcmp(tensor,'vx'),
  mode=3;
elseif strcmp(tensor,'vy'),
  mode=4;
elseif strcmp(tensor,'exx'),
  mode=5;
elseif strcmp(tensor,'eyy'),
  mode=6;
elseif strcmp(tensor,'exy'),
  mode=7;
elseif strcmp(tensor,'sxx'),
  mode=8;
elseif strcmp(tensor,'syy'),
  mode=9;
elseif strcmp(tensor,'sxy'),
  mode=10;
elseif strcmp(tensor,'e1'),
  mode=11;
elseif strcmp(tensor,'e2'),
  mode=12;
elseif strcmp(tensor,'s1'),
  mode=13;
elseif strcmp(tensor,'s2'),
  mode=14;
elseif (strcmp(tensor,'vonmises') || strcmp(tensor,'von mises')),
  mode=15;
end

if strcmp(application,'ps'),
  appl=3;
elseif strcmp(application,'pn'),
  appl=4;
end

if mode<5,
  % ux, uy, vx, vy
  [ux,uy]=pdegrad(p,t,u);
  if mode==1,
    % ux
    out=ux(1,:);
  elseif mode==2,
    % uy
    out=uy(1,:);
  elseif mode==3,
    % vx
    out=ux(2,:);
  elseif mode==4,
    % vy
    out=uy(2,:);
  end
elseif mode<8,
  % exx, eyy, exy
  [ux,uy]=pdegrad(p,t,u);
  if mode==5,
    % exx
    out=ux(1,:);
  elseif mode==6,
    % eyy
    out=uy(2,:);
  elseif mode==7,
    % exy
    out=(ux(2,:)+uy(1,:))/2;
  end
elseif mode<11,
  % sxx, syy, sxy
  [sx,sy]=pdecgrad(p,t,c,u);
  if mode==8,
    % sxx
    out=sx(1,:);
  elseif mode==9,
    % syy
    out=sy(2,:);
  elseif mode==10,
    % sxy
    out=(sx(2,:)+sy(1,:))/2;
  end
elseif mode<13
  % e1, e2
  [ux,uy]=pdegrad(p,t,u);
  [out1,out2]=pdeeigx(ux(1,:),(ux(2,:)+uy(1,:))/2,...
      (ux(2,:)+uy(1,:))/2,uy(2,:));
  if mode==11,
    % e1
    out=out1';
  elseif mode==12,
    % e2
    out=out2';
  end
elseif mode<15,
  % s1, s2
  [sx,sy]=pdecgrad(p,t,c,u);
  [out1,out2]=pdeeigx(sx(1,:),(sx(2,:)+sy(1,:))/2,...
      (sx(2,:)+sy(1,:))/2,sy(2,:));
  if mode==13,
    out=out1';
  elseif mode==14,
    out=out2';
  end
elseif mode==15,
  % von Mises
  if appl==3,
    % Plane stress
    [sx,sy]=pdecgrad(p,t,c,u);
    [s1,s2]=pdeeigx(sx(1,:),(sx(2,:)+sy(1,:))/2,...
        (sx(2,:)+sy(1,:))/2,sy(2,:));
    out=sqrt(s1.*s1 + s2.*s2 -s1.*s2)';
  elseif appl==4,
    % Plane strain
    [sx,sy]=pdecgrad(p,t,c,u);
    [s1,s2]=pdeeigx(sx(1,:),(sx(2,:)+sy(1,:))/2,...
        (sx(2,:)+sy(1,:))/2,sy(2,:));
    out=sqrt((s1.*s1 + s2.*s2).*(nu.*nu-nu+1)'+...
        s1.*s2.*(2*nu.*nu-2*nu-1)')';
  end
else
  error('PDE:pdesmech:ModeRange',...
      'Mode must be an integer greater than 0 and less than 16.')
end

