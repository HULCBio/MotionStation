function components = sptcompp(components)
%SPTCOMPP Component registry function for SPTool.
% This function creates a structure array which the SPTool uses
% to keep track of what types of objects are available and what
% you can do to them, how they are displayed, and how they are
% imported into the SPTool.
%
% The SPTool finds all occurrences of 'sptcomp' (without the
% appended 'p') on the path and, after calling sptcompp,
% calls the others in the order they are on the path.  Each of
% these appends or alters the components structure which is 
% input.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.9 $

components(1).name = 'Signals';  % heading for the column
components(1).structName = 'Signal';  % name for a single item in the list
components(1).defaultClient = 'sigbrowse';
components(1).multipleSelection = 1;
components(1).importFcn = 'importsig';
components(1).types = {'vector' {} 
                       'array' {'fontweight','bold'} };
components(1).verbs.owningClient = 'sigbrowse';
components(1).verbs.buttonLabel = 'View';
components(1).verbs.action = 'view';

components(2).name = 'Filters';
components(2).structName = 'Filter';
components(2).defaultClient = 'filtview';
components(2).multipleSelection = 1;
components(2).importFcn = 'importfilt';
components(2).types = {'imported' {'fontangle','italic'} 
                       'design' {} };
components(2).verbs(1).owningClient = 'filtview';
components(2).verbs(1).buttonLabel = 'View';
components(2).verbs(1).action = 'view';
components(2).verbs(2).owningClient = 'filtdes';
components(2).verbs(2).buttonLabel = 'New';
components(2).verbs(2).action = 'create';
components(2).verbs(3).owningClient = 'filtdes';
components(2).verbs(3).buttonLabel = 'Edit';
components(2).verbs(3).action = 'change';
components(2).verbs(4).owningClient = 'applyfilt';
components(2).verbs(4).buttonLabel = 'Apply';
components(2).verbs(4).action = 'apply';

components(3).name = 'Spectra';
components(3).structName = 'Spectrum';
components(3).defaultClient = 'spectview';
components(3).multipleSelection = 1;
components(3).importFcn = 'importspec';
components(3).types = {'auto' {}};
components(3).verbs(1).owningClient = 'spectview';
components(3).verbs(1).buttonLabel = 'View';
components(3).verbs(1).action = 'view';
components(3).verbs(2).owningClient = 'spectview';
components(3).verbs(2).buttonLabel = 'Create';
components(3).verbs(2).action = 'create';
components(3).verbs(3).owningClient = 'spectview';
components(3).verbs(3).buttonLabel = 'Update';
components(3).verbs(3).action = 'update';

