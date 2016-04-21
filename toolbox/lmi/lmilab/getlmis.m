% lmisys = getlmis
%
% Returns the internal representation LMISYS of an LMI
% system once this LMI system has been fully described
% with LMIVAR and LMITERM.
%
% The internal representation LMISYS can be passed
% directly to the LMI solvers or any other LMI-Lab
% function.
%
% See also  SETLMIS, LMIVAR, LMITERM.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function lmis=getlmis()

global GLZ_HEAD GLZ_LMIS GLZ_LMIV GLZ_LMIT GLZ_DATA

if length(GLZ_HEAD)~=10,
  error(sprintf(['The LMI system must be first described with SETLMIS,\n' ...
                 'LMIVAR, and LMITERM']));
end

nlmi=GLZ_HEAD(1);
nvar=GLZ_HEAD(2);
nterm=GLZ_HEAD(3);
ldt=GLZ_HEAD(7);
lmis=lmipck(GLZ_LMIS(1:nlmi,:)',GLZ_LMIV(:,1:nvar),...
            GLZ_LMIT(:,1:nterm),GLZ_DATA(1:ldt));

GLZ_LMIS=[]; GLZ_LMIV=[]; GLZ_LMIT=[]; GLZ_DATA=[];
clear global GLZ_HEAD GLZ_LMIS GLZ_LMIV GLZ_LMIT GLZ_DATA


