function [tmf,envVal] = accel_default_tmf
%ACCEL_DEFAULT_TMF Returns the "default" template makefile for use with accel.tlc
%
%       See get_tmf_for_target in the toolbox/rtw/private directory for more 
%       information.

%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.5 $

[tmf,envVal] = get_tmf_for_target('accel');

%end accel_default_tmf.m