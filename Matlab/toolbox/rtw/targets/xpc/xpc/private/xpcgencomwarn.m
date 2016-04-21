function xpcgencomwarn(sys)
% XPCGENCOMWARN xPC Target private function.


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/11 14:18:32 $

%   This function called from the xPC Target Build proceemits a warning if selected to build
%   xPC Target COM signals and parameters COM Interfaces
%   and the xPC Target embdedded option is not installed.

nag           = slsfnagctlr('NagTemplate');
nag.type      = 'Warning';
nag.component = 'xPC Target';
nag.msg.summary   = 'Build Warning';
nag.msg.details = sprintf([                                 ...
        'You have selected to generate the xPC Target COM ' ...
        'signals and parameters Interface Objects.'         ...
        'from the xPC Target UI optiins category under '    ...
        'the RTW options. If this option is seleceted '     ...
        'the xPC Target Embedded Option must be installed ' ...
        'for building the Component Server DLL.\n '         ...
        'For more information on this feature refer to '    ...
        'the xPC Target Embedded option section in the '    ...
        'xPC Target Users''s guide.']);
nag.sourceFullName = sys;
nag.sourceName     = sys;
    
slsfnagctlr('Push', nag);
slsfnagctlr('View');

