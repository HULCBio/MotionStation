% File input and output.
%
% File import/export functions.
%   dlmread       - Read ASCII delimited file.
%   dlmwrite      - Write ASCII delimited file.
%   importdata    - Load data from a file into MATLAB.
%   daqread       - Read Data Acquisition Toolbox (.daq) data file.
%   matfinfo      - Text description of MAT-file contents.
%
% Spreadsheet support.
%   xlsread       - Get data and text from a spreadsheet in an Excel workbook.
%   xlswrite      - Stores numeric array or cell array in Excel workbook.
%   xlsfinfo      - Determine if file contains Microsoft Excel spreadsheet.
%   wk1read       - Read spreadsheet (WK1) file. 
%   wk1write      - Write spreadsheet (WK1) file.
%   wk1finfo      - Determine if file contains Lotus WK1 worksheet.
%   str2rng       - Convert spreadsheet range string to numeric array.
%   wk1wrec       - Write a WK1 record header.
%
% Internet resource.
%   urlread       - Returns the contents of a URL as a string.
%   urlwrite      - Save the contents of a URL to a file.
%   ftp           - Create an FTP object.
%   sendmail      - Send e-mail.
%
% Zip file access.
%   zip           - Compress files into a zip file.
%   unzip         - Extract the contents of a zip file.
%
% Formatted file I/O.
%   fgetl         - Read line from file, discard newline character.
%   fgets         - Read line from file, keep newline character. 
%   fprintf       - Write formatted data to file.
%   fscanf        - Read formatted data from file.
%   textscan      - Read formatted data from text file.
%   textread      - Read formatted data from text file.
%
% File opening and closing.
%   fopen         - Open file.
%   fclose        - Close file.
%
% Binary file I/O.
%   fread         - Read binary data from file.
%   fwrite        - Write binary data to file.
%
% File positioning.
%   feof          - Test for end-of-file.
%   ferror        - Inquire file error status. 
%   frewind       - Rewind file.
%   fseek         - Set file position indicator. 
%   ftell         - Get file position indicator. 
%
% File name handling
%   fileparts     - Filename parts.
%   filesep       - Directory separator for this platform.
%   fullfile      - Build full filename from parts.
%   matlabroot    - Root directory of MATLAB installation.
%   mexext        - MEX filename extension for this platform. 
%   partialpath   - Partial pathnames.
%   pathsep       - Path separator for this platform.
%   prefdir       - Preference directory name.
%   tempdir       - Get temporary directory.
%   tempname      - Get temporary file.
%
% XML file handling
%   xmlread       - Parse an XML document and return a Document Object Model node.
%   xmlwrite      - Serialize an XML Document Object Model node.
%   xslt          - Transform an XML document using an XSLT engine.
%
% Serial port support.
%   serial        - Construct serial port object.
%   instrfindall  - Find all serial port objects with specified property values.
%   freeserial    - Release MATLAB's hold on serial port.
%   instrfind     - Find serial port objects with specified property values.
%
% Timer support.
%   timer         - Construct timer object.
%   timerfindall  - Find all timer objects with specified property values.
%   timerfind     - Find visible timer objects with specified property values.
%
% Command window I/O
%   clc           - Clear command window.
%   home          - Send the cursor home.
%
% Soap support.
%   callSoapService     - Send a SOAP message off to an endpoint.
%   createSoapMessage   - Creates the SOAP message, ready to send to the server.
%   parseSoapResponse   - Convert the response from a SOAP server into MATLAB types.
%
% See also GENERAL, LANG, AUDIOVIDEO, IMAGESCI, GRAPHICS, UITOOLS.

% Obsolete functions.
%   csvread     - Read a comma separated value file.
%   csvwrite    - Write a comma separated value file.
%   dataread    - Read formatted data from string or file.
%   fileread    - Return contents of file as string vector.
%   wk1const      - WK1 record type definitions.
%   filemarker          - Character that separates a file and a within-file function name.
%   createClassFromWsdl - createClassFromWsdl
%   instrcb             - Wrapper for serial object M-file callback.

%   Copyright 1984-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.4  $Date: 2004/03/26 13:26:18 $ 
