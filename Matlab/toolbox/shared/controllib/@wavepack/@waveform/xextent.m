function hx = xextent(this,VisFilter,Depth)
%XEXTENT  Gathers all handles contributing to X limits.
% 
%  The 4D array VISFILTER specify the visible data cells 
%  in the response plot.  XEXTENT returns the array of HG
%  handles contributing to the X data extent. This array
%  has size [S1 S2 S3] where
%    * S1 = max. number of HG objects/column
%    * S2 = size(VISFILTER,2) (# of major columns)
%    * S3 = size(VISFILTER,4) (# of minor columns)

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:24 $

% Account for RowIndex and ColumnIndex
nc = size(VisFilter,2);
VisFilter = VisFilter(this.RowIndex,this.ColumnIndex,:,:);

% Loop over views (each yextent is Nobj*Nc1*1*Nc2)
s = [size(VisFilter) 1 1];
h = zeros(0,s(2),1,s(4));
for v = this.View(strcmp(get(this.View, 'Visible'), 'on'))'
  h = cat(1, h , double(v.yextent(VisFilter)));
end

% Loop over characteristics
if (nargin<3 | Depth>0) & ~isempty(this.Characteristics)
   for c=find(this.Characteristics,'Visible','on')'
      for v=c.View(isvisible(c.View))'
         h = cat(1, h , double(v.yextent(VisFilter)));
      end
   end
end

% Return array wrt full-size grid
hx = -ones(size(h,1),nc,1,s(4));
hx(:,this.ColumnIndex,:,1:size(h,4)) = h;
