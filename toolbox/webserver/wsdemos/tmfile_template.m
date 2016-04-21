function tmfile_template()
%TMFILE_TEMPLATE Standalone test function template.
%   TMFILE_TEMPLATE does setup and calls MFILE_TEMPLATE.
%   Creates the output file, OUTPUT_TEST.HTML.  Use this
%   template driver program to create your own standalone
%   test program.
%
%   Use this test driver with the MATLAB debugger to step
%   through your program.
%

%   Author(s): M. Greenstein, 05-18-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.4 $   $Date: 2001/04/25 18:49:27 $

% STEP 1
% Set up input variables as they would come in from
% the HTML input form created from INPUT_TEMPLATE.HTML.
outstruct.my_input_variable_1 = some appropriate test value;

% STEP 2
% Call your application function that was created from
% <MFILE_TEMPLATE.M>.  Replace <MFILE_TEMPLATE> with the
% name of your application M-file.  Provide a test output
% file name for the optional argument by replacing <TEST_OUTPUT.HTML>
% with your test output HTML file name.
retstr = <MFILE_TEMPLATE>(outstruct, '<TEST_OUTPUT.HTML>');

% STEP 3
% Examine the file you supplied for <TEST_OUTPUT.HTML> in your
% web browser.

