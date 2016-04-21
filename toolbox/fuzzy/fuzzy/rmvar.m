function [out,errorStr]=rmvar(fis,varType,varIndex,warningDlgEnabled)
%RMVAR  Remove variable from FIS.
%   fis2 = RMVAR(fis,'varType',varIndex) removes the specified
%   variable from the fuzzy inference system associated with the 
%   FIS matrix fis.
%
%   [fis2,errorStr] = RMVAR(fis,'varType',varIndex) returns any necessary
%   error messages in the string errorStr.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addvar(a,'input','food',[0 10]);
%           getfis(a)
%           a=rmvar(a,'input',1);
%           getfis(a)
%
%   See also ADDMF, ADDVAR, RMMF.

%   Ned Gulley, 2-2-94  Kelly Liu, 7-22-96
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.30 $  $Date: 2002/04/20 20:17:38 $

out=[];
if nargin<4
   warningDlgEnabled = false;
end
numInputs=length(fis.input);
numOutputs=length(fis.output);
numRules=length(fis.rule);

% Error checking
errorStr=[];
if any(varIndex<=0 | varIndex~=round(varIndex))
   errorStr = 'Variable identifiers must be positive integers.';
elseif any(varIndex>numInputs) && strcmpi(varType(1),'i')
   errorStr = 'Specified input variable does not exist.';
elseif any(varIndex>numOutputs) && strcmpi(varType(1),'o')
   errorStr = 'Specified output variable does not exist.';
end
if ~isempty(errorStr)
   if nargout<2, 
      error(errorStr); 
   else
      return
   end
end

switch lower(varType(1)),
case 'i',
   % Check if the variable is currently being used in any rule
   if warningDlgEnabled & numRules>0 
      usedlist=[];
      for i=1:numRules,
         if any(fis.rule(i).antecedent(varIndex)~=0)
            usedlist=[usedlist, i];
         end
      end
      if ~isempty(usedlist)
         anws=questdlg({['The deleted variable is currently used in rules ' mat2str(usedlist) '.'],...
               ['Do you really want to remove it?']}, '', 'Yes', 'No', 'No');
         if strcmp(anws, 'No')
            out=fis;
            return
         end
      end
   end
   
   % Delete variables
   fis.input(varIndex)=[];
   for i=1:numRules,
      fis.rule(i).antecedent(varIndex)=[];
   end
   
   % Delete rules with no antecedent
   for i=numRules:-1:1
      if all(fis.rule(i).antecedent==0)
         fis.rule(i)=[];
      end
   end 
   
case 'o',
   % Make sure the variable is not currently being used in the rules
   if warningDlgEnabled & numRules>0 
      usedlist=[];
      for i=1:numRules,
         if any(fis.rule(i).consequent(varIndex)~=0)
            usedlist=[usedlist, i];
         end
      end
      if ~isempty(usedlist)
         anws=questdlg({['The deleted variable is currently used in rules ' mat2str(usedlist) '.'],...
               ['Do you really want to remove it?']}, '', 'Yes', 'No', 'No');
         if strcmp(anws, 'No')
            out=fis;
            return
         end
      end
   end
   
   % Delete variables
   fis.output(varIndex)=[];
   for i=1:numRules,
      fis.rule(i).consequent(varIndex)=[];
   end
   
   % Delete rules with no consequent
   for i=numRules:-1:1
      if all(fis.rule(i).consequent==0)
         fis.rule(i)=[];
      end
   end
end

out=fis;