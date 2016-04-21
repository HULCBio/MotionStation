function coewrite(Hq,radix,filename)
%COEWRITE Write a XILINX CORE Generator(tm) coefficient (.COE) file.
%   COEWRITE has been replaced by the DFILT.DFFIR/COEWRITE method. COEWRITE
%   still works but will be removed in the future. Use the
%   DFILT.DFFIR/COEWRITE method instead.  Type help DFILT/COEWRITE for
%   details.
%
%   See also DFILT/COEWRITE, DFILT.
%

%   Author(s): P. Costa
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/03/15 22:18:23 $ 

error(nargchk(1,3,nargin));
if nargin < 2, radix = []; end
if isempty(radix), radix = 16; end
if nargin < 3, filename = []; end

prefix = 'XILINX .COE files can only be generated for';
if ~isfir(Hq),
    error([prefix ' FIR filters.']);
end

if ~isfixed(Hq.coefficientformat),
    error([prefix ' fixed-point coefficients.']);
end

if nsections(Hq) ~=1,
    error([prefix ' single section filters.']);
end

if ~isreal(Hq),
    error([prefix ' filters with real coefficients.']);
end

export2XilinxCOE(Hq,radix,filename);    

%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
function export2XilinxCOE(Hq,radix,filename)

file = 'untitled.coe';
ext = 'coe';
dlgStr = 'Export quantized coefficients to .COE file';

if isempty(filename),
    % Put up the file selection dialog
    [filename, pathname] = lcluiputfile(file,dlgStr);
else
    % File will be created in present directory
    s = pwd;
    pathname = [s filesep];
end

if ~isempty(filename),
    if isempty(findstr(filename,'.')), filename=[filename '.' ext]; end
    deffile = [pathname filename];
 
    save2coefile(Hq, radix, deffile);
end


%------------------------------------------------------------------------
function save2coefile(Hq, radix, file)

% Unix returns a path that sometimes includes two paths (the
% current path followed by the path to the file) seperated by '//'.
% Remove the first path.
indx = findstr(file,[filesep,filesep]);
if ~isempty(indx)
    file = file(indx+1:end);
end

% Write the coefficients out to a .COE file.
fid = fopen(file,'w');

% Display header information
strheader = sptfileheader('XILINX CORE Generator(tm) Distributed Arithmetic FIR filter coefficient (.COE) File', ...
    'filterdesign', ';');
fprintf(fid,'%s\n',strheader);

% Display the Radix
fprintf(fid, 'Radix = %d; \n',radix); % 'Radix' is a .COE file keyword

% Display the coefficient wordlength
fprintf(fid,'Coefficient_Width = %d; \n',Hq.coefficientformat.wordlength);

% Get the coefficients from the QFILT object
q = get(Hq,'CoefficientFormat');
qcoeffs = Hq.QuantizedCoefficients{1};
qcoeffs = qcoeffs(:);

switch radix,
case 2,   HqCoeff = num2bin(q,qcoeffs);
case 10,  HqCoeff = num2str(num2int(q,qcoeffs)); 
case 16,  HqCoeff = num2hex(q,qcoeffs);
otherwise
    error('Invalid radix.');
end

% Display the Coefficients
fprintf(fid,'%s','CoefData = '); % 'CoefData' is a .COE file keyword
[r,c] = size(HqCoeff);
for i = 1:r-1;
    fprintf(fid,'%s,\n', HqCoeff(i,:));   
end

% Add the semicolon to the last coefficient
fprintf(fid,'%s;\n',HqCoeff(r,:)); 

fclose(fid);

% Launch the MATLAB editor (to display the generated file)
edit(file);


%------------------------------------------------------------------------
function [filename, pathname] = lcluiputfile(file,dlgStr)
% Local UIPUTFILE: Return an empty string for the "Cancel" case

[filename, pathname] = uiputfile(file,dlgStr);

% filename is 0 if "Cancel" was clicked
if filename == 0, filename = ''; end


% [EOF]
