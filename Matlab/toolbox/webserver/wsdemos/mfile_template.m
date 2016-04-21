function retstr = mfile_template(instruct, outfile)
%FUNCTION_TEMPLATE Guide for creating MATLAB Web Server applications.
%   <FUNCTION_TEMPLATE>(INSTRUCT) where you replace the
%   "<FUNCTION_TEMPLATE>" with the name of the MATLAB Web 
%   Server application you wish to create.
%   <FUNCTION_TEMPLATE>(INSTRUCT, OUTFILE) is the same as
%   the single argument version but also includes an optional
%   argument, OUTFILE, for writing HTML output to a file (for
%   stand-alone testing).
%
%   Modify this file to create your own application.  Be sure
%   to save the modifications as <FUNCTION_TEMPLATE>.m where
%   <FUNCTION_TEMPLATE> is replaced with the name of your 
%   application M-file.
%
%   INSTRUCT is a structure created by the matweb program.
%   It contains fields corresponding to the HTML form fields
%   in the HTML form that you have created from the file
%   INPUT_TEMPLATE.HTML.  In that HTML file  there
%   should a hidden field, called "mlmfile" that references
%   the M-file that you create here.
%  

%   Author(s): M. Greenstein, 05-18-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.7 $   $Date: 2001/04/25 18:49:24 $

% STEP 1
% Initialize the return string.
retstr = char('');

% STEP 2
% Set working directory. The variables INSTRUCT.MLDIR 
% and INSTRUCT.MLID are provided automatically to all
% MATLAB Web Server applications that use the matweb program.
% Use the directory in MLDIR for writing graphics files 
% in a location that the HTTPD can read.
cd(instruct.mldir);

% STEP 3
% Get the HTML form input variables (from the HTML form that
% you created from INPUT_TEMPLATE.HTML) and use them in your
% program.  See the sample M-files in the wsdemos directory
% for examples.
my_input_variable_1 = instruct.my_input_variable_1;

% STEP 4
% Perform your MATLAB computations, graphics file creations,
% etc. here:
MATLAB computations, etc.;

% STEP 5
% Put variables that you want to put into your HTML output document
% in an output structure.  You create an HTML output document from
% OUTPUT_TEMPLATE.HTML.  See the sample M-files in the wsdemos
% directory for examples.
outstruct.my_output_variable_1 = More MATLAB computations creating ...
   scalars, matrices, cell arrays, graphics files, etc.;

% STEP 6
% Call the function HTMLREP with the output structure you just
% created and the file name you created from OUTPUT_TEMPLATE.HTML.
% Replace <OUTPUT_TEMPLATE.HTML> with the name of the HTML output
% file you created using OUTPUT_TEMPLATE.HTML.
% This call fills the string RETSTR to return and optionally 
% writes the output as a file if a valid filename is given as the
% second argument to the present function. 
templatefile = which('<OUTPUT_TEMPLATE.HTML>');
if (nargin == 1)
   retstr = htmlrep(outstruct, templatefile);
elseif (nargin == 2)
   retstr = htmlrep(outstruct, templatefile, outfile);
end
