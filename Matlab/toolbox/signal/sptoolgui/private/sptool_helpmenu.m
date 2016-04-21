function mh = sptool_helpmenu(toolname,toolhelp_cb,toolhelp_tag,whatsthis_cb,whatsthis_tag)
% SPTOOL_HELPMENU Creates the string to be passed to makemenu to create the Help menu
%                 for SPTool clients, i.e., Signal Browser, Spectrum Viewer, 
%                 Filter Designer, and Filter Viewer.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:03:33 $ 
 

mh={'Help'                             ' '                                'helpmenu'
    sprintf('>&%s Help',toolname)            toolhelp_cb                        toolhelp_tag
	sprintf('>Signal Processing &Toolbox Help') 'sptool(''help'',''helptoolbox'')' 'helptoolbox'
    '>------'                          ' '                                ' '
    '>What''s This?'                   whatsthis_cb                       whatsthis_tag
    '>------'                          ' '                                ' '
    sprintf('>Demos')                           'sptool(''help'',''helpdemos'')'   'helpdemos'
    '>------'                          ' '                                ' '
    sprintf('>About Signal Processing Toolbox') 'sptool(''help'',''helpabout'')'   'helpabout'
	 
};

% [EOF] sptool_helpmenu.m