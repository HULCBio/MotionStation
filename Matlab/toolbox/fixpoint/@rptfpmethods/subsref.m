function B=subsref(A,S)
%SUBSREF reference fields in the RPTFPMETHODS information structure
%   FIELDVAL=SUBSREF(Z,SUBSTRUCT('.','FieldName'))

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:56:19 $

d=rgstoredata(A);
if isempty(d)
   d=initialize(A);
end

B=subsref(d,S);
if isempty(B)
   d=LocGuess(A,d,S(1).subs);
   rgstoredata(A,d);
   B=subsref(d,S);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fpData=LocGuess(z,fpData,whichField)

if isfield(fpData,whichField)
   fieldVal=getfield(fpData,whichField);
   if ~isempty(fieldVal)
      return;
   end
else
   fieldVal=[];
end

switch whichField
case 'SignalInfo'
   fpData.SignalInfo=GetLoggedData(z);
otherwise
   d=initialize(z);
   fpData=setfield(fpData,whichField,getfield(d,whichField));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fpInfo=GetLoggedData(z)

global FixPtSimRanges;

idx=1;
for i=1:length(FixPtSimRanges)
   currBlk=FixPtSimRanges{i}.Path;
   currSfcn=[];
   j=1;
   fpInfo(idx)=signalstruct(z,currBlk,currSfcn,j,FixPtSimRanges{i});
   idx=idx+1;
end

if idx==1
   fpInfo=[];
end
