function [result,status] = maplemex(statement,option)
%MAPLEMEX Mex-file interface to Maple.
%   Ordinarily, this function is called by the "maple" M-file.
%   It is usually not called directly from the command line.
%
%   [RESULT,STATUS] = MAPLEMEX(STATEMENT) sends the given statement
%   to the Maple OEM Kernel, which provides a result and a status
%   indicator.  An optional second input argument signals initialization
%   or directly printed output.
%
%   This function is written in C and compiled into a Mex file for each
%   supported computer architecture.  The result should be a file with
%   a name of the form "maplemex.mexx" where "mexx" is the Mex extension
%   for the particular architecture.  If such a file is not available,
%   this M-file will be executed and an error message will result.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:13:32 $

error('The Symbolic Math Toolbox is not yet available for this architecture.')
