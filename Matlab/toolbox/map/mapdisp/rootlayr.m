%  ROOTLAYR  Construct mlayers cell array input for current workspace
%
%  ROOTLAYR constructs the cell array input to be used for mlayers
%  for the base workspace.  This will process each variable in
%  the workspace to determine if it is a structure.  All structures
%  are included in the cell array constructed for the MLAYERS tool.
%  The cell array is provided in the variable ans.
%
%  This is a script to allow its operation on the base workspace.
%  The recommended calling procedure is:  rootlayr;mlayers(ans).
%
%  Note:  This script will create a temporary variable MLAYERSINPUTS,
%         which is cleared upon successful completion.
%
%  See also MLAYERS

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


%  Throughout this script, the variable ans is used with structure
%  fields so as to not interfere with any variables in the original
%  workspace, other than ans.  Note that this presents a problem
%  when echoing any result during its operation.  This process
%  overwrites ans.  So, all echoes must be accomplished by disp()

clear ans
ans.var = who;      %  Get the variables in the workspace

ans.indx = [];      %  Initialize index variable
ans.i = 1;          %  Loop variable;  Use of structure precludes for loops

while ans.i <= length(ans.var)     %  Determine the structures in workspace
    if eval(['~isstruct(',ans.var{ans.i},')'])
	        ans.indx = [ans.indx; ans.i];
    end
	ans.i = ans.i+1;
end

%  Remove non-structure variables from the ans.var list

ans.var(ans.indx) = [];
ans.inputs = [];

if ~isempty(ans.var)  %  No variables in workspace

%  Remove "ans" from the ans.var list.  It will always be in this list
%  since ans is a structure in this script.

   ans.indx = strmatch('ans',char(ans.var),'exact');
   ans.var(ans.indx) = [];

   ans.inputs = cell(length(ans.var),2);     %  Build up the mlayer cell array input

   ans.i = 1;
   while ans.i <= length(ans.var)
        ans.inputs{ans.i,2} = ans.var{ans.i};
        eval(['ans.inputs{',num2str(ans.i),',1} = ',ans.var{ans.i},';'])
		ans.i = ans.i+1;
   end
end

MLAYERSINPUTS = ans.inputs;    clear ans            %  Some memory problems
ans = MLAYERSINPUTS;           clear MLAYERSINPUTS; %  with direct assignment

