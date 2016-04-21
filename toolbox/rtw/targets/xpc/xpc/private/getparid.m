function pname = getparid(block, param,modelname)
% GETPARINDEX xPCTarget private function

%Group:        Parameter
%
%Syntax:       index = getparindex('blockpath', 'parametername')
%
%getparindex retruns the index into the parameter list, starting
%from the sought after path (block path) and parameter names.
%I.e. getparindex is used to set a parameter according to the
%block name. Therefore it is guaranteed, that the information
%stays correct, even after regenerating the xPC Target-application.
%The block path is made up of the model name, possible sub
%model names and the block name. getparindex can only be called,
%if the current path corresponds to the xPC Target-project
%directory, resp. if the file modelpar.m lies in the current
%directory.
%
%Example:
%Inside the test model, the submodel sub1 is contained,
%that itself contains the submodel sub2, that contains
%the block testblock. Then the block path is:
%test/sub1/sub2/test block
%If the sought after parameter is called partest,
%the syntax is:
%getparindex('test/sub1/sub2/testblock', 'partest')
%
%See also:     showpar, setpar, getpar

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $ $Date: 2004/04/08 21:04:29 $


eval(['pt = ', modelname, 'pt;'], 'error(''Model does not exist'')');
npar   = length(pt);

blocks=cellstr(strvcat(pt(:).blockname));
params=cellstr(strvcat(pt(:).paramname));

blockindex = strmatch(block, blocks, 'exact');
paramindex = strmatch(param, params, 'exact');
numb       = intersect(blockindex, paramindex) - 1;

pname = ['P', num2str(numb)];
