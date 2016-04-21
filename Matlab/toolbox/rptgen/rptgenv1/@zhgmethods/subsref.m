function B=subsref(A,S)
%SUBSREF gets fields from the ZHGMETHODS information structure
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:49 $

hgData=rgstoredata(A);

whichField=S(1).subs;

if ~isstruct(hgData)
   hgData=initialize(A,hgData);
   rgstoredata(A,hgData);
elseif ~isfield(hgData,whichField)
   hgData=setfield(hgData,whichField,[]);   
   rgstoredata(A,hgData);
end

B=getfield(hgData,S(1).subs);

if isempty(B)
   B=LocBestGuess(A,whichField);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fieldVal=LocBestGuess(z,whichField)

switch whichField
case 'Figure'
   fieldVal = get(0,'CurrentFigure');
   if ~isempty(fieldVal)
      %We don't want any "bad" figures becoming
      %the current figure.  Make sure that the
      %figure's tag is not on the exclude list
      currTag=get(fieldVal,'tag');
      badFigList=excludefiguretags(z);
      if any(strcmp(badFigList,currTag))
         fieldVal=[];
      end
   end
case 'Axes'
   currFig=get(0,'CurrentFigure');
   fieldVal=get(currFig,'CurrentAxes');
case 'Object'
   currFig=get(0,'CurrentFigure');
   fieldVal=get(currFig,'CurrentObject');
case 'PreRunOpenFigures'
   fieldVal=findall(allchild(0),'type','figure');
end
