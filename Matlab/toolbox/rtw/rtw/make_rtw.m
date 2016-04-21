function make_rtw(varargin)
% MAKE_RTW Executes the Real-Time Workshop Build procedure for a block diagram.
%
%       MAKE_RTW first invokes the Target Language Compiler to generate the
%       code and then invokes the language specific make procedure.
%
%       Calls rtw_<target_language>, tlc_<target_language>

%  Note: This is a UDD class version of make_rtw.
%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.136.4.1 $


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.136.4.1 $  $Date: 2002/09/23 16:26:50 $

%  initiate an object of RTW.makertw class
h = RTW.makertw;

%  call make_rtw method of RTW.makertw class
%  Note: varargin must be kept untouched.
h.make_rtw(varargin{:});
