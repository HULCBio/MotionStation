function [ii,ic]=pdesdp(p,k,t,sdl)
%PDESDP Indices of points in a set of subdomains.
%
%       [I,C]=PDESDP(P,E,T,SDL). Given mesh data P,E,T and a list of
%       subdomain numbers SDL, the function returns all points
%       belonging to those subdomains. A point may belong to several
%       subdomains, and the points belonging to the domains in SDL are
%       divided into two disjoint sets: I contains indices of the
%       points that wholly belong to the subdomains listed in SDL, and
%       C lists points that also belongs to the other subdomains.
%
%       C=PDESDP(P,E,T,SDL) returns indices of points that belong to
%       more than one of the subdomains in SDL.
%
%       If SDL is not given, a list of all subdomains is assumed.

%       A. Nordmark 4-25-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:20 $

np=size(p,2);
i=zeros(1,np);

nsd=max(t(4,:));
bsd=zeros(1,nsd);
if nargin==4,
  bsd(sdl)=ones(size(sdl)); % 1 if SD to be refined, 0 otherwise
else
  bsd=ones(1,nsd);
end

if nargout==2,
  it=find(bsd(t(4,:)));
  nit=length(it);

  i(t(1,it))=ones(1,nit);
  i(t(2,it))=ones(1,nit);
  i(t(3,it))=ones(1,nit);
end

nbs=max(k(5,:)); % Number of boundary segments
dd=zeros(2,nbs);
dd(:,k(5,:))=k(6:7,:);

ddd=dd(:);
j=find(ddd==0);
ddd(j)=(nsd+1)*ones(size(j));
dd(:)=ddd;
bsd1=[2*bsd-1 0];
if nargout==2,
  bsl=find(bsd1(dd(1,:)).*bsd1(dd(2,:))<0); % Exterior common BS:s
else
  bsl=find(bsd1(dd(1,:)).*bsd1(dd(2,:))==1); % Interior common BS:s
end
bbs=zeros(1,nbs);
bbs(bsl)=ones(size(bsl)); % 1 if BS is common, 0 otherwise

ik=find(bbs(k(5,:))); % Common edges
nik=length(ik);
i(k(1,ik))=-ones(1,nik);
i(k(2,ik))=-ones(1,nik);

if nargout==2,
  ii=find(i==1);
  ic=find(i==-1);
else
  ii=find(i==-1);
end

