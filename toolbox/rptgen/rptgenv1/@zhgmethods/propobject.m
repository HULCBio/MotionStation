function out=propobject(c,action,varargin)
%PROPOBJECT returns properties of figures
%   FLIST  = PROPOBJECT(ZHGMETHODS,'GetFilterList');
%   PLIST  = PROPOBJECT(ZHGMETHODS,'GetPropList',FILTERNAME);
%   PVALUE = PROPOBJECT(ZHGMETHODS,'GetPropValue',OBJHANDLES,PROPNAME);

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:46 $

switch action
case 'GetFilterList'
   out={'Uicontrol','UIcontrol Properties'
    'Uimenu',       'UImenu Properties'
    'Uicontextmenu','UIcontextmenu Properties'
    'Image',        'Image Properties'
    'Light',        'Light Properties'
    'Line',         'Line Properties'
    'Patch',        'Patch Properties'
    'Surface',      'Surface Properties'
    'Text',         'Text Properties'};   
case 'GetPropList'
   hStruct=tempfigure(zhgmethods);
   out=fieldnames(get(getfield(hStruct,varargin{1})));
   delete(hStruct.Figure);
case 'GetPropValue'
   Property=varargin{2};
   objHandles=varargin{1};
   
   switch Property
   case {'Parent'}
      out=feval(['LocProp' Property],objHandles);
   otherwise
      out=LocGetParam(objHandles,Property);
   end %case Property
end %primary case



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocGetParam(objHandles,Property);


try
   out=get(objHandles,Property);
   if length(objHandles)==1
      out={out};
   end
catch
   for i=length(objHandles):-1:1
      try
         out{i,1}=get(objHandles(i),Property);
      catch
         out{i,1}='N/A';
      end
   end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocPropParent(objHandles)

valCells=LocGetParam(objHandles,'Parent');

z=zhgmethods;
for i=1:length(valCells)
   valCells{i}=objname(z,valCells{i},logical(0));
end