%HTMLREP Substitute values for variable names in HTML document.
%   OUTSTRING = HTMLREP(INSTRUCT, INFILE) replaces all MATLAB 
%   variables in INFILE, an HTML document, with corresponding
%   values of variables of the same name in INSTRUCT. Variables
%   can be character strings, matrices, or cell arrays containing
%   strings and scalars.  String and scalar variables are 
%   replaced by straight substitution. Output is returned in
%   OUTSTRING.  
%
%   Variable names in INFILE must be enclosed in dollar
%   signs, e.g., $varname$.  In cases where you are not doing
%   variable replacement, you will need to supply two dollar signs
%   when you want actual dollar signs to appear.  For example,
%   use $$1000 to have $1000 displayed.
%  
%   OUTSTRING = HTMLREP(INSTRUCT, INFILE, OUTFILE) also writes 
%   output to the HTML document OUTFILE (for standalone testing or
%   for writing out an HTML document).
%
%   OUTSTRING = HTMLREP(INSTRUCT, INFILE, OUTFILE, ATTRIBUTES) 
%   works the same as the previous (3 argument) form but in
%   addition honors valid optional attributes.  
%
%      INSTRUCT is a structure containing variable names (field 
%      names) and corresponding values.
%
%      INFILE is an HTML template file with MATLAB variable
%      names enclosed in dollar signs.
%
%      OUTFILE is an optional name of a file for output
%      (for standalone testing or HTML document creation).
%
%      ATTRIBUTES is a MATLAB string (enclosed in ' ') with
%      the listed attributes separated by spaces. Attributes:
%
%         'noheader' - Suppresses the output of the HTML header 
%             'Content-type: text/html\n\n' to outfile and outstring.
%
%         'extendmemory' - Enables dynamic memory extension beyond
%              256KB.  This attribute is designed only for use with 
%              HTMLREP independently of the MATLAB Web Server.  Using 
%              it with the MATLAB Web Server will cause unpredictable
%              results with output larger than 256KB.
%
%   HTML tables and select lists can be generated dynamically
%   from matrices or cell arrays containing strings and scalars.
%
%   1. Tables can be generated using the special MATLAB 
%      "AUTOGENERATE" HTML table attribute with the matrix 
%      or cell array name as the value.  For example, the 
%      following HTML code will automatically generate all 
%      the HTML needed to display the entire matrix, 
%      MSQUARE, in an HTML table:
%
%         <TABLE BORDER="1" CELLSPACING="1" AUTOGENERATE="$MSQUARE$">
%            <TR>
%               <TD ALIGN="RIGHT">
%               </TD>
%            </TR>
%         </TABLE>
%   
%      At least one of each of the tags listed above is required.
%
%      HTMLREP uses the HTML code from the <TABLE> tag to the 
%      </TABLE> tag as a template for generating the entire table. 
%      If different column attributes are required, additional pairs
%      of cell tags (<TD> and </TD>) can be included up to the
%      number of columns in the matrix or cell array.  For example,
%      adding these tags:
%
%         <TD ALIGN="CENTER">
%         </TD>
%
%      after the </TD> tag above would cause the second column to
%      be center justified.
%
%      If there are more columns in the matrix or cell array than
%      <TD> </TD> pairs, the last pair will be used for all the 
%      subsequent columns.
%
%   2. Select lists can also be generated using the special MATLAB 
%      "AUTOGENERATE" HTML select attribute with the vector, matrix 
%      or cell array name as the value.  For example, the following
%      HTML code will automatically generate all the HTML needed
%      to display the entire vector, MYLIST, in an HTML
%      select list.  (Remember that select lists must appear inside
%      HTML <FORM> and </FORM> tags.)
%
%         <SELECT NAME="NAMELIST" SIZE=10 AUTOGENERATE=$MYLIST$ MULTIPLE>
%            <OPTION SIZE=6>
%         </SELECT>
%
%      HTMLREP uses the HTML code from the <SELECT> tag to the 
%      </SELECT> tag as a template for generating the entire select 
%      list.  One of each of the tags listed above is required.
%
%      If MYLIST is a matrix or cell array, HTMLREP uses only the
%      first column vector to construct the select list.
%

%   Author(s): M. Greenstein, 03/16/98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.14 $   $Date: 2001/04/25 18:49:32 $
