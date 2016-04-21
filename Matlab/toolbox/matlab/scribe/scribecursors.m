function scribecursors(varargin)
%SCRIBECURSORS Figure Pointers for annotations and plotedit.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.7 $  $  $

if nargin==1
  fig = gcf;
  n = varargin{1};
else
  fig = varargin{1};
  n = varargin{2};
end

if ischar(n)
  custompointer(fig,n)
else
  switch n
   case -1
    set(fig,'pointer','arrow');
   case 0
    set(fig,'pointer','arrow');
   case 1
    set(fig,'pointer','fleur');
   case 2
    set(fig,'pointer','topl');
   case 3
    set(fig,'pointer','topr');
   case 4
    set(fig,'pointer','botr');
   case 5
    set(fig,'pointer','botl');
   case 6
    set(fig,'pointer','left');
   case 7
    set(fig,'pointer','top');
   case 8
    set(fig,'pointer','right');
   case 9
    set(fig,'pointer','bottom');
   case 10
    custompointer(fig,'pushpin');
   case 11
    custompointer(fig,'noway');
   otherwise
    set(fig,'pointer','arrow');
  end
end

%-------------------------------------------------------
function custompointer(fig,name)
% set's figures cursor to custom thing
P = ones(16)+1;
o=NaN; w=2; k=1;

switch name
 case 'pushpin'
  P(1,:) = o;
  P(2,:) = [o o o o o w o o o o o o o w w w];
  P(3,:) = [o o o o o w w o o o o o w k k w];
  P(4,:) = [o o o o o w k w w w w w w k k w];
  P(5,:) = [o o o o o w k k k k k k k k k w];
  P(6,:) = [o o o o o w k k k k k k k k k w];
  P(7,:) = [o w w w w w k k k k k k k k k w];
  P(8,:) = [w k k k k k k k k k k k k k k w];
  P(9,:) = [o w w w w w k k k k k k k k k w];
  P(10,:)= [o o o o o w k k k k k k k k k w];
  P(11,:)= [o o o o o w k k k k k k k k k w];
  P(12,:)= [o o o o o w k w w w w w w k k w];
  P(13,:)= [o o o o o w w o o o o o w k k w];
  P(14,:)= [o o o o o w o o o o o o o w w w];
  P(15,:)= o;
  P(16,:)= o;
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[8 1])
 case 'noway'
  P(1,:) = o;
  P(2,:) = [o o o o o k k k k k o o o o o o];
  P(3,:) = [o o o k k k k k k k k k o o o o];
  P(4,:) = [o o k k k o o o o o k k k o o o];
  P(5,:) = [o k k o o o o o o o k k k k o o];
  P(6,:) = [o k k o o o o o o k k k k k o o];
  P(7,:) = [k k o o o o o o k k k o o k k o];
  P(8,:) = [k k o o o o o k k k o o o k k o];
  P(9,:) = [k k o o o o k k k o o o o k k o];
  P(10,:)= [k k o o o k k k o o o o o k k o];
  P(11,:)= [k k o o k k k o o o o o o k k o];
  P(12,:)= [o k k k k k o o o o o o k k o o];
  P(13,:)= [o k k k k o o o o o o o k k o o];
  P(14,:)= [o o k k k o o o o o k k k o o o];
  P(15,:)= [o o o k k k k k k k k k o o o o];
  P(16,:)= [o o o o o k k k k k o o o o o o];
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[9 9])
 case 'zap'
  P(1,:) = o;
  P(2,:) = [o o o o o o o o o o o o o o o k];
  P(3,:) = [o o o o o o o o o o o o o o k o];
  P(4,:) = [o o o o o o o o o o o o o k k o];
  P(5,:) = [o o o o o o o o o o o o k k o o];
  P(6,:) = [o o o o o k o o o o o k k k o o];
  P(7,:) = [o o o o o k k k o o k k k o o o];
  P(8,:) = [o o o o k k k k k k k k k o o o];
  P(9,:) = [o o o o k k k k k k k k o o o o];
  P(10,:)= [o o o k k k k k k k k k o o o o];
  P(11,:)= [o o o k k k o o k k k o o o o o];
  P(12,:)= [o o k k k o o o o o k o o o o o];
  P(13,:)= [o o k k o o o o o o o o o o o o];
  P(14,:)= [o k k o o o o o o o o o o o o o];
  P(15,:)= [o k o o o o o o o o o o o o o o];
  P(16,:)= [k o o o o o o o o o o o o o o o];
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[9 9])
  
 case 'heditbar'
  P(1,:) = [o o o o o o o o o o o o o o o o];
  P(2,:) = [o o o o o o o o w o o o o o o o];
  P(3,:) = [o o o o o o o w k w o o o o o o];
  P(4,:) = [o o o o o o w k k k w o o o o o];
  P(5,:) = [o o o o o w k k k k k w o o o o];
  P(6,:) = [o o o o w w w w k w w w w o o o];
  P(7,:) = [o o o o o o o w k w o o o o o o];
  P(8,:) = [o w w w w w w w k w w w w w w w];
  P(9,:) = [o w k k k k k k k k k k k k k w];
  P(10,:)= [o w w w w w w w k w w w w w w w];
  P(11,:)= [o o o o o o o w k w o o o o o o];
  P(12,:)= [o o o o w w w w k w w w w o o o];
  P(13,:)= [o o o o o w k k k k k w o o o o];
  P(14,:)= [o o o o o o w k k k w o o o o o];
  P(15,:)= [o o o o o o o w k w o o o o o o];
  P(16,:)= [o o o o o o o o w o o o o o o o];
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[9 9])
  
 case 'veditbar'
  P(1,:) = [o o o o o o o o o o o o o o o o];
  P(2,:) = [o o o o o o o w w w o o o o o o];
  P(3,:) = [o o o o o o o w k w o o o o o o];
  P(4,:) = [o o o o o o o w k w o o o o o o];
  P(5,:) = [o o o o o w o w k w o w o o o o];
  P(6,:) = [o o o o w w o w k w o w w o o o];
  P(7,:) = [o o o w k w o w k w o w k w o o];
  P(8,:) = [o o w k k w w w k w w w k k w o];
  P(9,:) = [o w k k k k k k k k k k k k k w];
  P(10,:)= [o o w k k w w w k w w w k k w o];
  P(11,:)= [o o o w k w o w k w o w k w o o];
  P(12,:)= [o o o o w w o w k w o w w o o o];
  P(13,:)= [o o o o o w o w k w o w o o o o];
  P(14,:)= [o o o o o o o w k w o o o o o o];
  P(15,:)= [o o o o o o o w k w o o o o o o];
  P(16,:)= [o o o o o o o w w w o o o o o o];
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[9 9])
  
 case 'blanko'
  P(1,:) = [o o o o o o o o o o o o o o o o];
  P(2,:) = [o o o o o o o o o o o o o o o o];
  P(3,:) = [o o o o o o o o o o o o o o o o];
  P(4,:) = [o o o o o o o o o o o o o o o o];
  P(5,:) = [o o o o o o o o o o o o o o o o];
  P(6,:) = [o o o o o o o o o o o o o o o o];
  P(7,:) = [o o o o o o o o o o o o o o o o];
  P(8,:) = [o o o o o o o o o o o o o o o o];
  P(9,:) = [o o o o o o o o o o o o o o o o];
  P(10,:)= [o o o o o o o o o o o o o o o o];
  P(11,:)= [o o o o o o o o o o o o o o o o];
  P(12,:)= [o o o o o o o o o o o o o o o o];
  P(13,:)= [o o o o o o o o o o o o o o o o];
  P(14,:)= [o o o o o o o o o o o o o o o o];
  P(15,:)= [o o o o o o o o o o o o o o o o];
  P(16,:)= [o o o o o o o o o o o o o o o o];
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[9 9])
  
 case 'movepoint'
  P(1,:) = [w w w w w w w o o o o o o o o o];
  P(2,:) = [w k k k k k w o o o o o o o o o];
  P(3,:) = [w k k k k w o o o o o o o o o o];
  P(4,:) = [w k k k w o o o o o o o o o o o];
  P(5,:) = [w k k w k w o o o o o o o o o o];
  P(6,:) = [w k w o w k w o o o o o o o o o];
  P(7,:) = [w w o o o w k w o o o o o o o o];
  P(8,:) = [o o o o o o w k w o o o o o o o];
  P(9,:) = [o o o o o o o w k w o o o o o o];
  P(10,:)= [o o o o o o o o w k w o o o w w];
  P(11,:)= [o o o o o o o o o w k w o w k w];
  P(12,:)= [o o o o o o o o o o w k w k k w];
  P(13,:)= [o o o o o o o o o o o w k k k w];
  P(14,:)= [o o o o o o o o o o w k k k k w];
  P(15,:)= [o o o o o o o o o w k k k k k w];
  P(16,:)= [o o o o o o o o o w w w w w w w];
  set(fig,'Pointer','custom','PointerShapeCData',P,...
          'PointerShapeHotSpot',[9 9])
end

