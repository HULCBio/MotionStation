function [lType, varargout]=getparentloop(c, varargin)
%GETPARENTLOOP finds current loop type context
%   With 1 argument, it assumes Simulink loop and returns 
%  'Model' 'System' 'Block' 'Signal' or ''.
%
%   the optional second argument allows to pass a Nx2 cell array:
%   the first column will contain N keywords to search component
%   names for, the other one will contain N strings, one of
%   which (with the matching keywords) will be returned.  
%   A keyword is matched if a component name starts with it.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:34 $

if nargin < 2
   loopParents={'csl_mdl_loop';
      			 'csl_sys_loop';
			       'csl_blk_loop';
      			 'csl_sig_loop'};
   
   loopNames={'Model'
   		     'System'
      		  'Block'
     			  'Signal'};
else
   loopParents = varargin{1}(:,1);
   loopNames = varargin{1}(:,2);
end

exeStack=subsref(c,substruct('.','rptcomponent','.','stack'));
parentTypeIndex = -1;
parentPointer = [];

if length(exeStack)>0
   nearestParent = -1; 
   %we are executing and can use the stack
   parentTypes=get(exeStack.h,'tag');
   parentTypesStr = strvcat(parentTypes(1:end-1));
   %component classes are stored in the handle tags
   %the last member of parentTypes is the current component
   %foundTypes=find(ismember(parentTypes(1:end-1),loopParents));
   for j = 1:length( loopParents )
      levelMatch = strmatch( loopParents{j}, parentTypesStr );
      if isempty( levelMatch), levelMatch = -1; end
      if nearestParent < levelMatch(end)
         parentTypeIndex = j;
         nearestParent = levelMatch(end);
      end
   end
   if parentTypeIndex > 0,
      parentDefaultName = parentTypes{nearestParent};
      if nargout > 1,
         parentPointer=exeStack(nearestParent);
      end
   end
else
   %we are in design-mode and must use getparent
   parentPointer=getparent(c);
   while isa(parentPointer,'rptcp') & ~isempty(parentPointer)
      parentType=get(parentPointer,'tag');
      for j = 1:length( loopParents )
         if strmatch( loopParents{j}, parentType )
            parentTypeIndex = j;
            parentDefaultName = parentType;
            break;
         end
      end
      if parentTypeIndex>0, break;
      else
         parentPointer=getparent(parentPointer);
      end
   end
   if parentTypeIndex <= 0
      parentPointer = []; 
   end
end

if nargout > 1, varargout{1} = parentPointer; end

if parentTypeIndex>0
   lType=loopNames{parentTypeIndex(1)};
   if isempty( lType )
      lType = parentDefaultName;
   end
else
   lType='';
end