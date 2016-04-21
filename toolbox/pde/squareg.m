function [x,y]=squareg(bs,s)
%SQUAREG   Gives geometry data for the squareg PDE model
%
%   NE=SQUAREG gives the number of boundary segment
%
%   D=SQUAREG(BS) gives a matrix with one column for each boundary segment
%   specified in BS.
%   Row 1 contains the start parameter value.
%   Row 2 contains the end parameter value.
%   Row 3 contains the number of the left hand region.
%   Row 4 contains the number of the right hand region.
%
%   [X,Y]=SQUAREG(BS,S) gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $

nbs=4;

if nargin==0,
  x=nbs; % number of boundary segments
  return
end

d=[
  0 0 0 0 % start parameter value
  1 1 1 1 % end parameter value
  0 0 0 0 % left hand region
  1 1 1 1 % right hand region
];

bs1=bs(:)';

if find(bs1<1 | bs1>nbs),
  error('PDE:squareg:InvalidBs', 'Non existent boundary segment number.')
end

if nargin==1,
  x=d(:,bs1);
  return
end

x=zeros(size(s));
y=zeros(size(s));
[m,n]=size(bs);
if m==1 && n==1,
  bs=bs*ones(size(s)); % expand bs
elseif m~=size(s,1) || n~=size(s,2),
  error('PDE:squareg:SizeBs', 'bs must be scalar or of same size as s.');
end

if ~isempty(s),

% boundary segment 1
ii=find(bs==1);
if length(ii)
x(ii)=interp1([d(1,1),d(2,1)],[-1 1],s(ii));
y(ii)=interp1([d(1,1),d(2,1)],[1 1],s(ii));
end

% boundary segment 2
ii=find(bs==2);
if length(ii)
x(ii)=interp1([d(1,2),d(2,2)],[1 1],s(ii));
y(ii)=interp1([d(1,2),d(2,2)],[1 -1],s(ii));
end

% boundary segment 3
ii=find(bs==3);
if length(ii)
x(ii)=interp1([d(1,3),d(2,3)],[1 -1],s(ii));
y(ii)=interp1([d(1,3),d(2,3)],[-1 -1],s(ii));
end

% boundary segment 4
ii=find(bs==4);
if length(ii)
x(ii)=interp1([d(1,4),d(2,4)],[-1 -1],s(ii));
y(ii)=interp1([d(1,4),d(2,4)],[-1 1],s(ii));
end

end

