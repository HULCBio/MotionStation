function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:09 $


switch c.att.LoopType
case 'Current'
   ltString='current model';
case 'All'
   ltString='all open models';
case 'Custom'
   mdlNames={c.att.CustomModels.MdlName};
   if isempty(mdlNames{1})
      ltString='<none selected>';
   else
      ltString=singlelinetext(c,mdlNames,', ');
   end
otherwise
   ltString='<Unrecognized loop type>';
end

strout=sprintf('Model Loop - %s', xlate(ltString));
