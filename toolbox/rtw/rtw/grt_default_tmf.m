function [tmf,envVal] = grt_default_tmf
%GRT_DEFAULT_TMF Returns the "default" template makefile for use with grt.tlc
%
%       See get_tmf_for_target in the toolbox/rtw/private directory for more 
%       information.

%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.12 $

[tmf,envVal] = get_tmf_for_target('grt');

%end grt_default_tmf.m