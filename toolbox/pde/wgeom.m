function fid=wgeom(dl,mn)
%WGEOM  Write Geometry Specification Function.
%
%       FID=WGEOM(DL,MN) writes a Geometry M-file with the name
%       [MN,'.m']. The Geometry M-file is equivalent to the
%       Decomposed Geometry Matrix DL. FID is -1 if the file couldn't
%       be written.
%
%       The specification of the Decomposed Geometry Matrix, DL,
%       can be found in DECSG.

%       A. Nordmark 8-08-94, MR 9-14-94, AN 2-7-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:49 $


fid=fopen([mn,'.m'],'w');
if fid==-1
        return
end

mn=pdebasnm(mn);

nbs=size(dl,2);

umng=upper(mn);

% Write header
fprintf(fid,'function [x,y]=%s(bs,s)\n',mn);
fprintf(fid,'%%%s\tGives geometry data for the %s PDE model.\n',umng,mn);
fprintf(fid,'%%\n');
fprintf(fid,'%%   NE=%s gives the number of boundary segments\n',umng);
fprintf(fid,'%%\n');
fprintf(fid,'%%   D=%s(BS) gives a matrix with one column for each boundary segment\n',umng);
fprintf(fid,'%%   specified in BS.\n');
fprintf(fid,'%%   Row 1 contains the start parameter value.\n');
fprintf(fid,'%%   Row 2 contains the end parameter value.\n');
fprintf(fid,'%%   Row 3 contains the number of the left-hand regions.\n');
fprintf(fid,'%%   Row 4 contains the number of the right-hand regions.\n');
fprintf(fid,'%%\n');
fprintf(fid,'%%   [X,Y]=%s(BS,S) gives coordinates of boundary points. BS specifies the\n',umng);
fprintf(fid,'%%   boundary segments and S the corresponding parameter values. BS may be\n');
fprintf(fid,'%%   a scalar.\n');
fprintf(fid,'\n');
fprintf(fid,'nbs=%d;\n\n',nbs);
fprintf(fid,'if nargin==0,\n');
fprintf(fid,'  x=nbs; %% number of boundary segments\n');
fprintf(fid,'  return\n');
fprintf(fid,'end\n');
fprintf(fid,'\n');
fprintf(fid,'d=[\n');
fprintf(fid,'  ');fprintf(fid,'%g ',zeros(1,nbs)); ...
fprintf(fid,'%% start parameter value\n');
fprintf(fid,'  ');fprintf(fid,'%g ',ones(1,nbs)); ...
fprintf(fid,'%% end parameter value\n');
fprintf(fid,'  ');fprintf(fid,'%d ',dl(6,:)); ...
fprintf(fid,'%% left hand region\n');
fprintf(fid,'  ');fprintf(fid,'%d ',dl(7,:)); ...
fprintf(fid,'%% right hand region\n');
fprintf(fid,'];\n');
fprintf(fid,'\n');
fprintf(fid,'bs1=bs(:)'';\n');
fprintf(fid,'\n');
fprintf(fid,'if find(bs1<1 | bs1>nbs),\n');
fprintf(fid,'  error(''Non-existent boundary segment number'')\n');
fprintf(fid,'end\n');
fprintf(fid,'\n');
fprintf(fid,'if nargin==1,\n');
fprintf(fid,'  x=d(:,bs1);\n');
fprintf(fid,'  return\n');
fprintf(fid,'end\n');
fprintf(fid,'\n');
fprintf(fid,'x=zeros(size(s));\n');
fprintf(fid,'y=zeros(size(s));\n');
fprintf(fid,'[m,n]=size(bs);\n');
fprintf(fid,'if m==1 & n==1,\n');
fprintf(fid,'  bs=bs*ones(size(s)); %% expand bs\n');
fprintf(fid,'elseif m~=size(s,1) | n~=size(s,2),\n');
fprintf(fid,'  error(''bs must be scalar or of same size as s'');\n');
fprintf(fid,'end\n');
fprintf(fid,'\n');
fprintf(fid,'if ~isempty(s),\n');
fprintf(fid,'\n');

for i=1:nbs,
  fprintf(fid,'%% boundary segment %d\n',i);
  fprintf(fid,'ii=find(bs==%d);\n',i);
  fprintf(fid,'if length(ii)\n');
  x0=dl(2,i);
  x1=dl(3,i);
  y0=dl(4,i);
  y1=dl(5,i);
  if dl(1,i)==1, % Circle fragment
    xc=dl(8,i);
    yc=dl(9,i);
    r=dl(10,i);
    a0=atan2(y0-yc,x0-xc);
    a1=atan2(y1-yc,x1-xc);
    if a0>a1,
      a0=a0-2*pi;
    end
    fprintf(fid,'x(ii)=%.17g*cos(%.17g*s(ii)+(%.17g))+(%.17g);\n',r,a1-a0,a0,xc);
    fprintf(fid,'y(ii)=%.17g*sin(%.17g*s(ii)+(%.17g))+(%.17g);\n',r,a1-a0,a0,yc);
  elseif dl(1,i)==2, % Line fragment
    fprintf(fid,'x(ii)=(%.17g-(%.17g))*(s(ii)-d(1,%d))/(d(2,%d)-d(1,%d))+(%.17g);\n',x1,x0,i,i,i,x0);
    fprintf(fid,'y(ii)=(%.17g-(%.17g))*(s(ii)-d(1,%d))/(d(2,%d)-d(1,%d))+(%.17g);\n',y1,y0,i,i,i,y0);
  elseif dl(1,i)==4 % Ellipse fragment
    xc=dl(8,i);
    yc=dl(9,i);
    r1=dl(10,i);
    r2=dl(11,i);
    phi=dl(12,i);
    t=[r1*cos(phi) -r2*sin(phi); r1*sin(phi) r2*cos(phi)];
    rr0=t\[x0-xc;y0-yc];
    a0=atan2(rr0(2),rr0(1));
    rr1=t\[x1-xc;y1-yc];
    a1=atan2(rr1(2),rr1(1));
    if a0>a1,
      a0=a0-2*pi;
    end
    fprintf(fid,'t=[%.17g %.17g\n',t(1,1),t(1,2));
    fprintf(fid,'%.17g %.17g];\n',t(2,1),t(2,2));
    fprintf(fid,'nth=100;\n');
    fprintf(fid,'th=linspace(%.17g,%.17g,nth);\n',a0,a1);
    fprintf(fid,'rr=t*[cos(th);sin(th)];\n');
    fprintf(fid,'theta=pdearcl(th,rr,s(ii),d(1,%d),d(2,%d));\n',i,i);
    fprintf(fid,'rr=t*[cos(theta);sin(theta)];\n');
    fprintf(fid,'x(ii)=rr(1,:)+(%.17g);\n',xc);
    fprintf(fid,'y(ii)=rr(2,:)+(%.17g);\n',yc);
  else
    error('PDE:wgeom:InvalidSegType', 'Unknown segment type.');
  end
  fprintf(fid,'end\n');
  fprintf(fid,'\n');
end

fprintf(fid,'end\n');
fclose(fid);

