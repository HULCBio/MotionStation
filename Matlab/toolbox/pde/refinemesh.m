function [p1,e1,t1,u1]=refinemesh(g,p,e,t,u,it,mode)
%REFINEMESH Refine a triangular mesh.
%
%       [P1,E1,T1]=REFINEMESH(G,P,E,T) returns a refined version
%       of the triangular mesh specified by the geometry G, point matrix P,
%       edge matrix E, and triangle matrix T.
%
%       G describes the geometry of the PDE problem. G can
%       either be a Decomposed Geometry Matrix or the name of Geometry
%       M-file. See either DECSG or PDEGEOM for details.
%
%       The triangular mesh is given by the mesh data P, E, and T.
%       Details can be found under INITMESH.
%
%       [P1,E1,T1,U1]=REFINEMESH(G,P,E,T,U) refines the mesh and also
%       extends the function U to the new mesh by linear interpolation.
%       The number of rows in U should correspond to the number of
%       columns in P, and U1 will have as many rows as there are
%       points in P1. Each column of U is interpolated separately.
%
%       An extra input argument is interpreted as a list of
%       subdomains to refine, if it is a row vector, or a list of
%       triangles to refine, if it is a column vector.
%
%       The default refinement method is regular refinement, where
%       all of the specified triangles are divided into four triangles
%       of the same shape. Longest edge refinement, where
%       the longest edge of each specified triangle is bisected, can
%       be demanded by giving 'longest' as a final parameter. Using
%       'regular' as the final parameter results in regular refinement.
%       Some triangles outside of the specified set may also be refined,
%       in order to preserve the triangulation and its quality.
%
%       See also INITMESH, PDEGEOM

%       A. Nordmark 4-26-94, AN 6-21-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.13.4.1 $  $Date: 2003/11/18 03:12:44 $


np=size(p,2);
ne=size(e,2);
nt=size(t,2);

if nargout==4,
  intp=1;
else
  intp=0;
end

if nargin-intp==4,
  it=(1:nt)';                           % All triangles
  mode='regular';
end

if (~intp) && nargin==5,
  it=u;
  if ischar(it),
    mode=it;
    it=(1:nt)';                         % All triangles
  else
    mode='regular';
  end
end

if (~intp) && nargin==6,
  mode=it;
  it=u;
end

if intp && nargin==6,
  if ischar(it),
    mode=it;
    it=(1:nt)';                         % All triangles
  else
    mode='regular';
  end
end

if strcmp(mode,'regular')==0 && strcmp(mode,'longest')==0,
  error('PDE:refinemesh:InvalidRefineMode', 'Unknown refinement mode.');
end

if size(it,1)>1,                        % Triangles
  it=it';
else                                    % Subdomains
  it=pdesdt(t,it);
end

% Cannot use matrix indices that exceeds the size of a signed int
[comp,maxsize]=computer;
indexproblem=np^2>maxsize;

% Find longest side of each triangle
ls=3*ones(1,nt);
d1=(p(1,t(1,:))-p(1,t(2,:))).^2+(p(2,t(1,:))-p(2,t(2,:))).^2;
d=(p(1,t(2,:))-p(1,t(3,:))).^2+(p(2,t(2,:))-p(2,t(3,:))).^2;
ii=find(d>d1);
ls(ii)=1*ones(size(ii));
d1=max(d,d1);
d=(p(1,t(3,:))-p(1,t(1,:))).^2+(p(2,t(3,:))-p(2,t(1,:))).^2;
ii=find(d>d1);
ls(ii)=2*ones(size(ii));
% Permute so longest side is 3
ii=find(ls==1);
d=t(1,ii);
t(1,ii)=t(2,ii);
t(2,ii)=t(3,ii);
t(3,ii)=d;
ii=find(ls==2);
d=t(1,ii);
t(1,ii)=t(3,ii);
t(3,ii)=t(2,ii);
t(2,ii)=d;

itt1=ones(1,nt);
itt1(it)=zeros(size(it));
it1=find(itt1);                         % Triangles not yet to be refined
it=find(itt1==0);                       % Triangles whos longest side is to be bisected

% Make a connectivity matrix, with edges to be refined.
% -1 means no point is yet allocated
ip1=t(1,it);
ip2=t(2,it);
if strcmp(mode,'regular'),
  ip3=t(3,it);
end
A=sparse(ip1,ip2,-1,np,np);
if strcmp(mode,'regular'),
  A=A+sparse(ip2,ip3,-1,np,np);
  A=A+sparse(ip3,ip1,-1,np,np);
end
A=-((A+A.')<0);
newpoints=1;

% loop until no additional hanging nodes are introduced
while newpoints,
  newpoints=0;
  n=length(it1);
  ip1=t(1,it1);
  ip2=t(2,it1);
  ip3=t(3,it1);
  m1=zeros(1,n);
  m2=m1;
  m3=m1;
  for i=1:n,
    m3(i)=A(ip1(i),ip2(i));
    m1(i)=A(ip2(i),ip3(i));
    m2(i)=A(ip3(i),ip1(i));
  end
  ii=find(m3);
  if length(ii)>0,
    itt1(it1(ii))=zeros(size(ii));
  end
  ii=find((m1 | m2) & (~m3));
  if length(ii)>0,
    A=A+sparse(ip1(ii),ip2(ii),-1,np,np);
    A=-((A+A.')<0);
    newpoints=1;
    itt1(it1(ii))=zeros(size(ii));
  end
  it1=find(itt1);                       % Triangles not yet fully refined
  it=find(itt1==0);                     % Triangles fully refined
end

% Find edges to be refined
if ~indexproblem
  ie=full(A(e(1,:)+(e(2,:)-1)*np))==-1;
else
  ie=l_extract(A,e(1,:),e(2,:))==-1;
end

ie1=find(ie==0);                        % Edges not to be refined
ie=find(ie);                            % Edges to be refined

% Get the edge "midpoint" coordinates
[x,y]=pdeigeom(g,e(5,ie),(e(3,ie)+e(4,ie))/2);
% Create new points
p1=[p [x;y]];
if intp,
  u1=[u;(u(e(1,ie),:)+u(e(2,ie),:))/2];
end
ip=(np+1):(np+length(ie));
np1=np+length(ie);
% Create new edges
e1=[e(:,ie1) ...
        [e(1,ie);ip;e(3,ie);(e(3,ie)+e(4,ie))/2;e(5:7,ie)] ...
        [ip;e(2,ie);(e(3,ie)+e(4,ie))/2;e(4,ie);e(5:7,ie)]];
% Fill in the new points
if ~indexproblem
  A(e(1,ie)+np*(e(2,ie)-1))=ip;
  A(e(2,ie)+np*(e(1,ie)-1))=ip;
else
  A=l_assign(A,[e(1,ie) e(2,ie)],[e(2,ie) e(1,ie)],[ip ip]);
end

% Generate points on interior edges
[i1,i2]=find(A==-1 & A.'==-1);
i=find(i2>i1);
i1=i1(i);
i2=i2(i);
p1=[p1 ((p(1:2,i1)+p(1:2,i2))/2)];
if intp,
  u1=[u1;(u(i1,:)+u(i2,:))/2];
end
ip=(np1+1):(np1+length(i));
np1=np1+length(i);
% Fill in the new points
if ~indexproblem
  A(i1+np*(i2-1))=ip;
  A(i2+np*(i1-1))=ip;
else
  A=l_assign(A,[i1 i2],[i2 i1],[ip ip]);
end

% Lastly form the triangles
ip1=t(1,it);
ip2=t(2,it);
ip3=t(3,it);
if ~indexproblem
  mp1=full(A(ip2+np*(ip3-1)));
  mp2=full(A(ip3+np*(ip1-1)));
  mp3=full(A(ip1+np*(ip2-1)));
else
  mp1=l_extract(A,ip2,ip3);
  mp2=l_extract(A,ip3,ip1);
  mp3=l_extract(A,ip1,ip2);
end

% Find out which sides are refined
bm=1*(mp1>0)+2*(mp2>0);
% The number of new triangles
nt1=length(it1)+length(it)+sum(mp1>0)+sum(mp2>0)+sum(mp3>0);
t1=zeros(4,nt1);
t1(:,1:length(it1))=t(:,it1);           % The unrefined triangles
nnt1=length(it1);
if isempty(bm)
	i = bm;
else
	i=find(bm==3);                          % All sides are refined
end
t1(:,(nnt1+1):(nnt1+length(i)))=[t(1,it(i));mp3(i);mp2(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(2,it(i));mp1(i);mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(3,it(i));mp2(i);mp1(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[mp1(i);mp2(i);mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
if isempty(bm)
	i = bm;
else
	i=find(bm==2);                          % Sides 2 and 3 are refined
end
t1(:,(nnt1+1):(nnt1+length(i)))=[t(1,it(i));mp3(i);mp2(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(2,it(i));t(3,it(i));mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(3,it(i));mp2(i);mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
if isempty(bm)
	i = bm;
else
	i=find(bm==1);                          % Sides 3 and 1 are refined
end
t1(:,(nnt1+1):(nnt1+length(i)))=[t(2,it(i));mp1(i);mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(3,it(i));t(1,it(i));mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(3,it(i));mp3(i);mp1(i);t(4,it(i))];
nnt1=nnt1+length(i);
if isempty(bm)
	i = bm;
else
	i=find(bm==0);                          % Side 3 is refined
end
t1(:,(nnt1+1):(nnt1+length(i)))=[t(3,it(i));t(1,it(i));mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);
t1(:,(nnt1+1):(nnt1+length(i)))=[t(2,it(i));t(3,it(i));mp3(i);t(4,it(i))];
nnt1=nnt1+length(i);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function k=l_extract(A,i,j)

if numel(i)~=numel(j)
  error('PDE:refinemesh:ijNumel', 'i and j must have the same number of elements.')
end

k=zeros(size(i));

for l=1:numel(i)
  k(l)=A(i(l),j(l));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A=l_assign(A,i,j,k)

if numel(i)~=numel(j) || numel(i)~=numel(k) 
  error('PDE:refinemesh:ijkNumel', 'i, j, and k must have the same number of elements.')
end

for l=1:numel(i)
  A(i(l),j(l))=k(l);
end
