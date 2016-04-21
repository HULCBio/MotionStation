function val = get(A,prop)
%FIGOBJ/GET Get figobj property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2004/01/15 21:12:38 $

switch prop
case 'Selection'
   val = A.DragObjects.Items;
case 'MyHGHandle'
   val = get(A.aChild,'Parent');
case 'HGHandle'
   val = get(A.aChild,'Parent');
case 'MyHandle'
   figHG = get(A.aChild,'Parent');
   figUD = getscribeobjectdata(figHG);
   try
      val = figUD.HandleStore;
   catch
      error('HGOBJ has no handle...');
   end
case 'Figure'
   figHG = get(A.aChild, 'Parent');
   val = figHG;
case 'IsSelected'
    %Figures can not be dragged
    val = 0;
otherwise
   figHG = get(A.aChild, 'Parent');
   val = get(figHG, prop);
end   
