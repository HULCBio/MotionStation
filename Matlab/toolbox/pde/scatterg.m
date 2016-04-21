function [x,y]=scatterg(bs,s)
%SCATTERG   Gives geometry data for the scatterg PDE model
%
%   NE = SCATTERG gives the number of boundary segment
%
%   D = SCATTERG(BS) gives a matrix with one column for each boundary segment
%   specified in BS.
%   Row 1 contains the start parameter value.
%   Row 2 contains the end parameter value.
%   Row 3 contains the number of the left hand region.
%   Row 4 contains the number of the right hand region.
%
%   [X,Y ]= SCATTERG(BS,S) gives coordinates of boundary points. BS specifies the
%   boundary segments and S the corresponding parameter values. BS may be
%   a scalar.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:45 $

nbs=8;

if nargin==0,
  x=nbs; % number of boundary segments
  return
end

d=[
  0 0 0 0 0 0 0 0 % start parameter value
  1 1 1 1 1 1 1 1 % end parameter value
  1 1 1 1 1 1 1 1 % left hand region
  0 0 0 0 0 0 0 0 % right hand region
];

bs1=bs(:)';

if find(bs1<1 | bs1>nbs),
  error('PDE:scatterg:InvalidBs', 'Non existent boundary segment number.')
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
  error('PDE:scatterg:SizeBs', 'bs must be scalar or of same size as s.');
end

if ~isempty(s),

% boundary segment 1
ii=find(bs==1);
if length(ii)
x(ii)=interp1([d(1,1),d(2,1)],[0.72928932188134521 0.80000000000000004],s(ii));
y(ii)=interp1([d(1,1),d(2,1)],[0.49999999999999994 0.57071067811865472],s(ii));
end

% boundary segment 2
ii=find(bs==2);
if length(ii)
x(ii)=interp1([d(1,2),d(2,2)],[0.80000000000000004 0.87071067811865488],s(ii));
y(ii)=interp1([d(1,2),d(2,2)],[0.57071067811865472 0.5],s(ii));
end

% boundary segment 3
ii=find(bs==3);
if length(ii)
x(ii)=interp1([d(1,3),d(2,3)],[0.87071067811865488 0.80000000000000004],s(ii));
y(ii)=interp1([d(1,3),d(2,3)],[0.5 0.42928932188134517],s(ii));
end

% boundary segment 4
ii=find(bs==4);
if length(ii)
x(ii)=interp1([d(1,4),d(2,4)],[0.80000000000000004 0.72928932188134521],s(ii));
y(ii)=interp1([d(1,4),d(2,4)],[0.42928932188134517 0.49999999999999994],s(ii));
end

% boundary segment 5
ii=find(bs==5);
if length(ii)
x(ii)=0.44999999999999996*cos(1.6891379103341819*s(ii)+(-3.2993814316421739))+(0.80000000000000004);
y(ii)=0.44999999999999996*sin(1.6891379103341819*s(ii)+(-3.2993814316421739))+(0.5);
end

% boundary segment 6
ii=find(bs==6);
if length(ii)
x(ii)=0.44999999999999996*cos(1.5313491322818016*s(ii)+(-1.610243521307992))+(0.80000000000000004);
y(ii)=0.44999999999999996*sin(1.5313491322818016*s(ii)+(-1.610243521307992))+(0.5);
end

% boundary segment 7
ii=find(bs==7);
if length(ii)
x(ii)=0.44999999999999996*cos(1.5313491322818016*s(ii)+(-0.078894389026190434))+(0.80000000000000004);
y(ii)=0.44999999999999996*sin(1.5313491322818016*s(ii)+(-0.078894389026190434))+(0.5);
end

% boundary segment 8
ii=find(bs==8);
if length(ii)
x(ii)=0.44999999999999996*cos(1.5313491322818011*s(ii)+(1.4524547432556112))+(0.80000000000000004);
y(ii)=0.44999999999999996*sin(1.5313491322818011*s(ii)+(1.4524547432556112))+(0.5);
end

end

