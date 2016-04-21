function hy = yextent(this,VisFilter,Depth)
%YEXTENT  Gathers all handles contributing to Y limits.
% 
%  The 4D array VISFILTER specify the visible data cells 
%  in the response plot.  YEXTENT returns the array of HG
%  handles contributing to the Y data extent. This array
%  has size [S1 S2 S3] where
%    * S1 = size(VISFILTER,1) (# of major rows)
%    * S2 = max. number of HG objects/row
%    * S3 = size(VISFILTER,3) (# of minor rows)

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:25 $

% REVISIT: Use handles rather than double handles when empty handle arrays
% behave

% Account for RowIndex and ColumnIndex
nr = size(VisFilter,1);
VisFilter = VisFilter(this.RowIndex,this.ColumnIndex,:,:);

% Loop over views (each yextent is Nr1*Nobj*Nr2*1) 
s = [size(VisFilter) 1];
h = zeros(s(1),0,s(3));
for v=this.View(strcmp(get(this.View,'Visible'),'on'))'
   h = cat(2, h , double(v.yextent(VisFilter)));
end

% Loop over characteristics
if (nargin<3 | Depth>0) & ~isempty(this.Characteristics)
   for c=find(this.Characteristics,'Visible','on')'
      for v=c.View(isvisible(c.View))'
         h = cat(2, h , double(v.yextent(VisFilter)));
      end
   end
end

% Return array wrt full-size grid
% REVISIT: handles(nr,size(h,2),s(3));  hy(this.RowIndex,:,:) = h;
hy = -ones(nr,size(h,2),s(3));
hy(this.RowIndex,:,1:size(h,3)) = h;