function [tmf,envVal] = grt_malloc_default_tmf
%GRT_MALLOC_DEFAULT_TMF Returns the "default" template makefile for use with 
%grt_malloc.tlc
%
%       See get_tmf_for_target in the toolbox/rtw/private directory for more 
%       information.

%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.9 $

[tmf,envVal] = get_tmf_for_target('grt_malloc');

%end grt_malloc_default_tmf.m
