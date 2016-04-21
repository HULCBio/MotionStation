function [ind,newname,newno] = indname(indu,names,type,mode,datnewnam)
%INDNAME manipulates channel names
%
%   [IND,NEWNAME,NEWNO] = INDNAME(Indu,Names,Type,Mode,Datnewnam)

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:00 $

if nargin<4,mode='disp';end
if nargin>4
   if strcmp(type,'Input')
      sym = 'u';
   elseif strcmp(type,'Output')
      sym = 'y';
   else
      sym = 'Exp';
   end
end

nuinp = length(names);
kadd = nuinp+1;
if isstr(indu),indu={indu};end
indtemp=[];newname=cell(0,1);newno=[];
for kk=1:length(indu)
   tf = strmatch(indu{kk},names,'exact');
   if isempty(tf)
      if strcmp(mode,'silent')
         newname = [newname;{indu{kk}}];
         newno=[newno,kk];
      elseif strcmp(mode,'disp')
         disp(['Warning: ',type,' ',indu{kk}, ' not found'])
      elseif strcmp(mode,'add')
         tf = kadd;
         kadd = kadd + 1;
         newno=[newno,kk];
      end
   end
   indtemp=[indtemp,tf];
   newn = {indu{kk}};
   if nargin==5
      if length(datnewnam)<kk
         error(['The data set of the RHS has too few ',Type,' channels.'])
      end
      tv = datnewnam{kk};
      if length(tv)>length(sym) & ...
            tv(1:length(sym))==sym & abs(abs(tv(length(sym)+1))-53)<5
         else
         newn = {tv};      
      end
   end
   
   newname = [newname;newn];
end
ind = indtemp;
