function it=pdesdt(t,sdl)
%PDESDT Indices of triangles in a set of subdomains.
%
%       I=PDESDT(T,SDL). Given triangle data T and a list of
%       subdomain numbers SDL, I will contain indices of the triangles
%       inside that set of subdomains.
%
%       If SDL is not given, a list of all subdomains is assumed.

%       A. Nordmark 4-25-94, AN 6-14-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:20 $

nsd=max(t(4,:));
bsd=zeros(1,nsd);
if nargin==2,
  bsd(sdl)=ones(size(sdl)); % 1 if SD in list, 0 otherwise
else
  bsd=ones(1,nsd);
end

it=find(bsd(t(4,:)));

