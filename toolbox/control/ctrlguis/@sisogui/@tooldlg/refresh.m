function refresh(h,key)
%REFRESH  Updates popup lists.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:06:55 $

% RE: Assumes container/constraint list is non empty

switch key
case 'Containers'
    % Update container list
    List = h.getlist('ActiveContainers');
    LocalContainerPopUp(h, List, find(h.Container==List));
    
case 'Constraints'
    % Update constraint list
    List = h.ConstraintList;
    LocalConstraintsPopUp(h, List, find(h.Constraint==List));    
end 


% --------------------------------------------------------------------------- %
% Function: LocalContainerPopUp
% Purpose:  Updates container choice list.
% --------------------------------------------------------------------------- %
function LocalContainerPopUp(h, List, index)
% Clean-up the Choice list
PopUp = h.Handles.EditorSelect;
PopUp.removeAll;

% Update choice list content
for ct = 1:length(List)
  % Remove '(C)' and '(F)' from the title strings
  str = List(ct).Axes.Title;
  str = strrep(strrep(str, '(C)', ''), '(F)','');
  PopUp.add(sprintf(str));
end
PopUp.select(index-1); % Choice index begin from zero, vector index from one
PopUp.repaint;


% --------------------------------------------------------------------------- %
% Function: LocalConstraintsPopUp
% Purpose:  Updates constraints choice list.
% --------------------------------------------------------------------------- %
function LocalConstraintsPopUp(h, List, index)
% Clean-up the choice list
PopUp = h.Handles.ConstrSelect;
PopUp.removeAll;

% Update choice list content
for ct = 1:length(List)
    PopUp.add(sprintf(List(ct).describe('detail')));
end
PopUp.select(index-1); % Choice index begin from zero, vector index from one
PopUp.repaint;
