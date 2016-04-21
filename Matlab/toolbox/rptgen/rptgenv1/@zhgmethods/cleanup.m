function cleanup(z)
%CLEANUP remove persistent information after generation
%   CLEANUP(ZHGMETHODS) performs the following actions:
%   1) Deletes all figures created during generation
%      which are not on the list of "safe" figures
%      defined in zslmethods/excludefiguretags

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:37 $

%Get a list of figures which existed before generation
oldFigures=subsref(z,substruct('.','PreRunOpenFigures'));

%Get a list of all current figures
curFigures=findall(allchild(0),'type','figure');

% new(bad) figures are the ones that did not exist before rg run
badFigures=setdiff(curFigures,oldFigures);
badFigureTags=get(badFigures,'tag');

%Safe figures are figures which should not be deleted
%by the Report Generator.
safeFigureTags=excludefiguretags(z);

%find indices of all tags which are members of safe figure tags
safeIndices = find(ismember(badFigureTags,safeFigureTags));

%remove safe figures from list of bad figures
badFigures(safeIndices)=[];

%delete bad figures

delete(badFigures);
