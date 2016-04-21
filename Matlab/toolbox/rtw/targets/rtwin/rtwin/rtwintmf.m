function [tmf,envVal] = rtwintmf
%RTWINTMF Returns the "default" template makefile for use with rtwin.tlc
%
%       See get_tmf_for_target in the toolbox/rtw directory for more 
%       information.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date : $  $Author: batserve $


% warn about being obsolete
warndlg(sprintf('You are using obsolete template makefile name.\nPlease go to "RTW Options -> Target configuration" and re-select the Real-Time Windows Target using the Browse button.'), ...
        'Obsolete makefile name' ...
       );

% always return "rtwin.tmf"
tmf = 'rtwin.tmf';
envVal = '';
