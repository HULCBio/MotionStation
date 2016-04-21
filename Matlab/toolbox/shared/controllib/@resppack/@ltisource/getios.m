function [inames,onames] = getios(src)
%GETIOS  Returns input and output names.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:48 $
inames = src.Model.InputName;
onames = src.Model.OutputName;
