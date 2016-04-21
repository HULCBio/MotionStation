function h = plotarray(arraysize,hndl)
% Returns instance of @plotarray class
%
%   H = PLOTARRAY([M N],AXHANDLE) creates a M-by-N plot array using 
%   the HG axes supplied in AXHANDLE.
%
%   H = PLOTARRAY([M1 N1 M2 N2 ...],AXHANDLE) creates a nested array 
%   of HG axes (M1-by-N1 array of M2-by-N2 arrays...).

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:21 $

h = LocalCreateInstance(arraysize,hndl);

%------------------ Local Functions ----------------------

function h = LocalCreateInstance(arraysize,hndl)
% Creates instance of nested plot array

h = ctrluis.plotarray;
s = arraysize(1:2);
hndl = handle(hndl);
Position = hndl(1).Position;  % RE: may be changed by @plotarray constructor!

% Create missing axes
nax = prod(arraysize);
ParentFig = hndl(1).Parent;
for ct=length(hndl)+1:nax,
   % RE: Confine all new axes to space allocated to entire plot or plot cell 
   %     (subplot may delete invisible axes that stretch outside allocated space)
   hndl(ct) = handle(axes('Parent',ParentFig,...
      'Position',Position,...
      'Visible','off','ContentsVisible','off'));
end

% Recursively build nested plot array
nsub = prod(arraysize(3:end));
if nsub==1
   h.Axes = hndl(1:min(nax,end));
elseif nsub==2 & arraysize(3)==2
   % Special case for 2x1 terminal node
   for ct=prod(s):-1:1
      pax(ct) = ctrluis.plotpair(hndl(2*ct-1:2*ct));
   end
   h.Axes = pax;
else  
   for ct=prod(s):-1:1
      pax(ct) = LocalCreateInstance(arraysize(3:end),hndl((ct-1)*nsub+1:ct*nsub));
   end
   h.Axes = pax;
end
h.Axes = reshape(h.Axes,s);

% Row and column visibility
h.ColumnVisible = logical(ones(s(2),1));
h.RowVisible = logical(ones(s(1),1));
h.Position = Position;
