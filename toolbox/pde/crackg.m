function [x,y]=crackg(bs,s)
%CRACKG Gives geometry data for the crackg PDE model
%
%   NE=CRACKG gives the number of boundary segment
%
%   D=CRACKG(BS) gives a matrix with one column for each boundary segment
%   specified in BS.
%   Row 1 contains the start parameter value.
%   Row 2 contains the end parameter value.
%   Row 3 contains the number of the left hand region.
%   Row 4 contains the number of the right hand region.
%
%   [X,Y]=CRACKG(BS,S) gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $

nbs=8;

if nargin==0,
  x=nbs; % number of boundary segments
  return
end

d=[
  0 0 0 0 0 0 0 0 % start parameter value
  1 1 1 1 1 1 1 1 % end parameter value
  0 0 1 1 1 0 0 1 % left hand region
  1 1 0 0 0 1 1 0 % right hand region
];

bs1=bs(:)';

if find(bs1<1 | bs1>nbs),
  error('PDE:crackg:InvalidBs', 'Non existent boundary segment number.')
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
  error('PDE:crackg:SizeBs', 'bs must be scalar or of same size as s.');
end

if ~isempty(s),

% boundary segment 1
ii=find(bs==1);
if length(ii)
x(ii)=interp1([d(1,1),d(2,1)],[0.5 0.5],s(ii));
y(ii)=interp1([d(1,1),d(2,1)],[0.80000000000000004 -0.80000000000000004],s(ii));
end

% boundary segment 2
ii=find(bs==2);
if length(ii)
x(ii)=interp1([d(1,2),d(2,2)],[0.5 -0.5],s(ii));
y(ii)=interp1([d(1,2),d(2,2)],[-0.80000000000000004 -0.80000000000000004],s(ii));
end

% boundary segment 3
ii=find(bs==3);
if length(ii)
x(ii)=interp1([d(1,3),d(2,3)],[0.050000000000000003 0.050000000000000003],s(ii));
y(ii)=interp1([d(1,3),d(2,3)],[0.40000000000000002 -0.40000000000000002],s(ii));
end

% boundary segment 4
ii=find(bs==4);
if length(ii)
x(ii)=interp1([d(1,4),d(2,4)],[0.050000000000000003 -0.050000000000000003],s(ii));
y(ii)=interp1([d(1,4),d(2,4)],[-0.40000000000000002 -0.40000000000000002],s(ii));
end

% boundary segment 5
ii=find(bs==5);
if length(ii)
x(ii)=interp1([d(1,5),d(2,5)],[-0.050000000000000003 0.050000000000000003],s(ii));
y(ii)=interp1([d(1,5),d(2,5)],[0.40000000000000002 0.40000000000000002],s(ii));
end

% boundary segment 6
ii=find(bs==6);
if length(ii)
x(ii)=interp1([d(1,6),d(2,6)],[-0.5 -0.5],s(ii));
y(ii)=interp1([d(1,6),d(2,6)],[-0.80000000000000004 0.80000000000000004],s(ii));
end

% boundary segment 7
ii=find(bs==7);
if length(ii)
x(ii)=interp1([d(1,7),d(2,7)],[-0.5 0.5],s(ii));
y(ii)=interp1([d(1,7),d(2,7)],[0.80000000000000004 0.80000000000000004],s(ii));
end

% boundary segment 8
ii=find(bs==8);
if length(ii)
x(ii)=interp1([d(1,8),d(2,8)],[-0.050000000000000003 -0.050000000000000003],s(ii));
y(ii)=interp1([d(1,8),d(2,8)],[-0.40000000000000002 0.40000000000000002],s(ii));
end

end

