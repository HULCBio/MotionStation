function  sf_mark_block_as_tainted(sfBlkH),
% sf_mark_block_as_tainted
%   sf_mark_block_as_tainted
%   Neuters a Stateflow block if running in demo mode. 
%

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:59:41 $

    set_param(sfBlkH, 'openFcn', 'sf(''Private'', ''sf_demo_disclaimer'');');
    set_param(sfBlkH, 'preSaveFcn', 'sf(''Private'', ''sf_demo_disclaimer'');error(''Preventing save to avoid model curruptions'');');
    if isempty(get_param(sfBlkH, 'ReferenceBlock')), 
        set_param(sfBlkH, 'ForegroundColor', 'red');
    else,
        set_param(sfBlkH, 'BackgroundColor', 'red');
    end;
	set_param(sfBlkH,'MaskType', 'INVALID');
	set_param(sfBlkH, 'userdata', []);

