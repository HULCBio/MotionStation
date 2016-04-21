function ctx_add_note
%
% Stateflow context menu callback to create a note object at the current pointer position
% on the editor
%

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:56:30 $ 

[chartId, figPos] = sf('CtxEditorId');
noteId = sf( 'new','state' ...
   ,'.position', [figPos, 25, 25] ...
   ,'.chart',chartId ...
   ,'.isNoteBox',1 ...
   ,'.labelString','' ...
   ,'.noteBox.italic',1 ...
 );
subviewerId = sf('get', chartId, '.viewObj');
sf('RebuildHierarchy', subviewerId);
sf('EditLabelOfObject',noteId); % EMM - debug flag - if you pass an extra parameter we do everything short of getting into edit mode!
