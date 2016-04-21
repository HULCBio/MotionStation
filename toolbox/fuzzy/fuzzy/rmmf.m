function [out,errorStr]=rmmf(fis,varType,varIndex,mfFlag,mfIndex, warningDlgEnabled)
%RMMF   Remove membership function from FIS.
%   fis2 = RMMF(fis,varType,varIndex,'mf',mfIndex, warningDlgEnabled) removes the
%   specified membership function from the fuzzy inference system
%   associated with the FIS matrix fis. The boolean variable 'warningDlgEnabled'
%   specifies if confirmation should be requested. The variable 'varType'
%   can be either 'input' or 'output'. After deletion of a membership
%   function, all rules that contain no input or output membership
%   functions are removed from fis.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           subplot(2,1,1), plotmf(a,'input',1)
%           a=rmmf(a,'input',1,'mf',2);
%           subplot(2,1,2), plotmf(a,'input',1)
%
%   See also ADDMF, ADDRULE, ADDVAR, PLOTMF, RMVAR.

%   Ned Gulley, 2-2-94   Kelly Liu 7-22-96
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.26 $  $Date: 2002/04/14 22:19:16 $

out=[];
errorStr=[];

numInputs=length(fis.input);
numOutputs=length(fis.output);

numInputMFs = [];
for i=1:numInputs
   numInputMFs(i)=length(fis.input(i).mf);
end
totalInputMFs=sum(numInputMFs);

numOutputMFs=[];
for i=1:length(fis.output)
   numOutputMFs(i)=length(fis.output(i).mf);
end
totalOutputMFs=sum(numOutputMFs);

numRules=length(fis.rule);

if nargin<6
   warningDlgEnabled=false;
end

switch lower(varType(1)),  
case 'i'
   if  numInputs==0,
      errorStr=sprintf('There are no input variables with membership functions to remove.');
      error(errorStr);
   end
   
case 'o',
   if numOutputs==0,
      errorStr=sprintf('There are no output variables with membership functions to remove.');
      error(errorStr);
   end
otherwise,
   return;
end


% Get the rule matrix

if ~isempty(fis.rule)
   ruleList=getfis(fis, 'ruleList');
elseif isempty(mfIndex),
   errorStr='No membership function was selected!';
   if nargout<2,
      error(errorStr)
   else
      out=[]; return
   end
end

%
% For removal of an input membership function
%
if strcmp(varType,'input'),
   if varIndex>numInputs,
      errorStr = sprintf('There are only %i input variables.', numInputs);
      if nargout<2,
         error(errorStr)
      else
         out=[]; return
      end
   end
   
   currNumMFs=numInputMFs(varIndex);
   if currNumMFs==0,
      errorStr=sprintf('No membership functions left to remove');
      if nargout<2,
         error(errorStr)
      else
         out=[]; return
      end
   end
   
   if max(mfIndex) > currNumMFs,
      errorStr = sprintf('There are only %i membership functions for this variable.', currNumMFs);
      if nargout<2,
         error(errorStr)
      else
         out=[]; return
      end
   end
   
   % Find out which rules these membership functions are used in
   if numRules>0,
      RulemfIndex = cat(1,fis.rule.antecedent);
      RulemfIndex = RulemfIndex(:,varIndex); %RulemfIndex = vector of MF's from varIndex
      hasDeletedMF = ismember(RulemfIndex,mfIndex); % mfIndex = indices of deleted MF's
   else
      hasDeletedMF = false(0,1);
   end
   ruleWithDeletedMF = (find(hasDeletedMF))';       %indices of rules with a deleted MF
   ruleWithoutDeletedMF = (find(~hasDeletedMF))';   %indices of rules without a deleted MF
   
   if any(hasDeletedMF) && warningDlgEnabled
      array = [];
      for loop = ruleWithDeletedMF,
         array = [ array num2str(loop) ', '];
      end
      anws=questdlg({['This membership function is used in rule ' array ' now do you really want to remove it?']}, '', 'Yes', 'No', 'No');
      if strcmp(anws, 'No')
         out=fis;
         return
      end
   end
   
   % Remove the membership function(s) from the specified input variable
   mfKeep = 1:length(fis.input(varIndex).mf);
   mfKeep(mfIndex)=[];
   fis.input(varIndex).mf(mfIndex)=[];
   
   % Remove the membership function(s) from all affected rules
   for loop = ruleWithDeletedMF, 
      fis.rule(loop).antecedent(varIndex) = 0;
   end
   
   % Make sure there are MFs to re-order before proceeding.
   if ~isempty(fis.input(varIndex).mf),
      % Create a map between old and new index for non-deleted MF's
      IndexMap(mfKeep) = 1:length(fis.input(varIndex).mf);     
      
      % Reindex the MFs for rules
      for loop = ruleWithoutDeletedMF,
         if fis.rule(loop).antecedent(varIndex)>0
            fis.rule(loop).antecedent(varIndex) = IndexMap(fis.rule(loop).antecedent(varIndex));
         end
      end
   end
   
   % Remove the rule that now have no antecedents associated with them
   if ~isempty(fis.rule)
      Antecedents = cat(1, fis.rule.antecedent);
      fis.rule(all(Antecedents==0,2)) = [];
   end
   
elseif strcmp(varType,'output'),
   %For removal of an output membership function
   
   if varIndex>numOutputs,
      errorStr = sprintf('Therea are only %i output variables.', numOutputs);
      if nargout<2,
         error(errorStr)
      else
         out=[]; return
      end
   end
   
   currNumMFs=numOutputMFs(varIndex);
   if currNumMFs==0,
      errorStr = sprintf('No membership functions left to remove');
      if nargout<2,
         error(errorStr)
      else
         out=[]; return
      end
   end
   
   if mfIndex>currNumMFs,
      errorStr = sprintf('There are only %i membership functions for this variable', currNumMFs);
      if nargout<2,
         error(errorStr)
      else
         out=[]; return
      end
   end
   
   % Make sure the MF is not currently being used in the rules
   if numRules>0,
      RulemfIndex = cat(1,fis.rule.consequent);
      RulemfIndex = RulemfIndex(:,varIndex); %RulemfIndex = vector of MF's from varIndex
      hasDeletedMF = ismember(RulemfIndex,mfIndex); % mfIndex = indices of deleted MF's
   else
      hasDeletedMF = false(0,1);
   end
   ruleWithDeletedMF = find(hasDeletedMF)';      %indeces of rules with a deleted MF
   ruleWithoutDeletedMF = find(~hasDeletedMF)';   %indeces of rules without a deleted MF
      
   if any(hasDeletedMF) && warningDlgEnabled
      array = [];
      for loop = ruleWithDeletedMF,
         array = [ array num2str(loop) ', '];
      end
      anws=questdlg({['This membership function is used in rule ' array ' now,'],...
            ['do you really want to remove it?']}, '', 'Yes', 'No', 'No');
      if strcmp(anws, 'No')
         out=fis;
         return
      end
   end
      
   % Remove the membership function(s) from the specified input variable
   mfKeep = 1:length(fis.output(varIndex).mf);
   mfKeep(mfIndex)=[];
   fis.output(varIndex).mf(mfIndex)=[];
   
   % Remove the membership function(s) from all affected rules
   for loop = ruleWithDeletedMF,
      fis.rule(loop).consequent(varIndex) = 0;
   end
   
   % Make sure there are MFs to re-order before proceeding.
   if ~isempty(fis.output(varIndex).mf),
      % Create an index map to reflect the deleted MFs
      IndexMap(mfKeep) = 1:length(fis.output(varIndex).mf);
      
      % Reindex the MFs for rules
      for loop = ruleWithoutDeletedMF,
         if fis.rule(loop).consequent(varIndex)>0,
            fis.rule(loop).consequent(varIndex) = IndexMap(fis.rule(loop).consequent(varIndex));
         end
      end
   end
   
   % Remove the rule that now have no antecedents associated with them
   if ~isempty(fis.rule)
      Consequents = cat(1, fis.rule.consequent);
      fis.rule(all(Consequents==0,2)) = [];
   end
end

out=fis;

