function showdata(a,f,tle)
%SHOWDATA Display data in interactive window.
%   SHOWDATA(A,F,T) displays the given cell array of data, A, in an interactive
%   figure window.  The unique entries for each column of data are displayed.
%   Clicking on a item in the figure displays information regarding the number
%   of matching items found and additional correlation data.   F is a cell
%   array of strings used as X axis labels.   If F is not supplied, no X axis
%   labels are displayed.   T is the figure window title string.   If T is not
%   supplied, no title is displayed.

%   Author(s): C.F.Garvin, 09-08-1998
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9 $   $Date: 2002/06/17 12:00:40 $

%Open figure window
if isempty(findobj('Tag','VQBDataWindow'))
  figure('Tag','VQBDataWindow','HandleVisibility','callback');
else
  figure(findobj('Tag','VQBDataWindow'));
  clf
end

%Get size of array
[m,n] = size(a);

%Parse individual columns into unique values, store in cell array
for i = 1:n
  if ~ischar(a{1,i})      %Numbers need to be pulled out of cell array form
    tmp{i} = unique([a{:,i}]');
    j = find(isnan(tmp{i}));      %Need to remove redundant NaN's
    L = length(j);
    if L > 1
      tmp{i}(j(2:L)) = [];
    end
  else
    tmp{i} = unique(a(:,i));
  end
end  

%Display data as text in figure
L = 0;
for i = 1:n
  l(i) = length(tmp{i});
end

%Get the number of unique fields from the field containing the most
L = max(l);

%Display the field values and stagger the spacing for fields with < L entries
for i = 1:n
  tmp{i} = flipud(tmp{i});
  for j = 1:l(i)
    k = L/l(i)*j;
    if iscell(tmp{i})
      t = text(i,k,tmp{i}{j},'Tag',['col' num2str(i)],'Userdata',tmp{i}{j});
    else
      z = num2str(tmp{i}(j));
      t = text(i,k,z,'Tag',['col' num2str(i)],'Userdata',z);
    end
    set(t,'ButtonDownFcn','showdatacallbacks(''select'')','Color',[.3 .3 .3])
  end
end

%Pad fieldnames with blank entries for display
if nargin < 2
  f = cell(n,1);
end
lab = [{''};f;{''}];

%Adjust the axes limits and labels
set(gca,'Xlim',[.9 n+1],'Ylim',[0 L+2],'Xtick',[.9,1:n+1],'Xticklabel',lab,...
  'Yticklabel',[],'Box','on','Ytick',[],'Xgrid','on','Fontweight','bold',...
  'Xaxislocation','top')

%Display title if given
if exist('tle')
  title(tle);
end

%Display instruction string
text(.4,-.05,'Click on a text object','Units','normal','Fontweight','bold');

%Store data in figure
set(gcf,'Userdata',a)


