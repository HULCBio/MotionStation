function ie=pdesde(e,sdl)
%PDESDE Indices of exterior edges adjacent to a set of subdomains.
%
%       I=PDESDE(E,SDL) given edge data E, extracts indices of
%       outer boundary edges of the set of subdomains.
%
%       If SDL is not given, a list of all subdomains is assumed.

%       A. Nordmark 12-20-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:53 $

ne=size(e,2);

nsd=max(max(e(6:7,:)));
bsd=2*ones(1,nsd);

if nargin==2
  bsd(sdl)=ones(size(sdl)); % 1 if SD in list, 2 otherwise
else % nargin==1
  bsd=ones(1,nsd);
end

bsd=[0 bsd];

% We include an edge if on side is in sdl and the other is the exterior
dd=zeros(2,ne);
dd(1,:)=bsd(e(6,:)+1);
dd(2,:)=bsd(e(7,:)+1);

ie=find(sum(dd)==1);

