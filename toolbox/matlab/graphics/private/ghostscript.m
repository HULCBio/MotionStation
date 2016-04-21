function pj = ghostscript( pj )
%GHOSTSCRIPT Function to convert a PostScript file to another format. 
%   Ghostscript is a third-party application supplied with 
%   MATLAB. See the file ghoscript/gs.rights in the MATLAB 
%   installation area for more information on Ghostscript itself. 
%   The PRINT command calls GHOSTSCRIPT when one of the device 
%   drivers listed below is specified as the -d option. 
%
%   These devices use Ghostscript and are supported on all platforms:
%      -dlaserjet - HP LaserJet
%      -dljetplus - HP LaserJet+
%      -dljet2p   - HP LaserJet IIP
%      -dljet3    - HP LaserJet III
%      -dljet4    - HP LaserJet 4,5L and 5P
%      -dpxlmono  - HP LaserJet 5 and 6
%      -ddeskjet  - HP DeskJet and DeskJet Plus
%      -ddjet500  - HP Deskjet 500
%      -dcdjmono  - HP DeskJet 500C printing black only
%      -dpaintjet - HP PaintJet color printer
%      -dpjxl     - HP PaintJet XL color printer
%      -dpjetxl   - HP PaintJet XL color printer
%      -dbj10e    - Canon BubbleJet BJ10e
%      -dbj200    - Canon BubbleJet BJ200
%      -dbjc600   - Canon Color BubbleJet BJC-600 and BJC-4000
%      -dbjc800   - Canon Color BubbleJet BJC-800
%      -dln03     - DEC LN03 printer
%      -depson    - Epson-compatible dot matrix printers (9- or 24-pin)
%      -depsonc   - Epson LQ-2550 and Fujitsu 3400/2400/1200
%      -deps9high - Epson-compatible 9-pin, interleaved lines 
%                      (triple resolution)
%      -dibmpro   - IBM 9-pin Proprinter
%
%   These devices use Ghostscript and are supported on UNIX platforms only:
%      -dcdjcolor - HP DeskJet 500C with 24 bit/pixel color and high-
%                      quality color (Floyd-Steinberg) dithering
%      -dcdj500   - HP DeskJet 500C
%      -dcdj550   - HP Deskjet 550C
%      -dpjxl300  - HP PaintJet XL300 color printer
%      -ddnj650c  - HP DesignJet 650C
%
%   The following formats will always result in a file being left on disk
%   because they are image formats. If no name is given to the PRINT command
%   a default name will be used and echoed to the command line.
%      -dbmpmono  - Monochrome .BMP file format
%      -dbmp256   - 8-bit (256-color) .BMP file format
%      -dbmp16m   - 24-bit .BMP file format
%      -dpcxmono  - Monochrome PCX file format
%      -dpcx16    - Older color PCX file format (EGA/VGA, 16-color)
%      -dpcx256   - Newer color PCX file format (256-color)
%      -dpcx24b   - 24-bit color PCX file format, 3 8-bit planes
%      -dpbm      - Portable Bitmap (plain format)
%      -dpbmraw   - Portable Bitmap (raw format)
%      -dpgm      - Portable Graymap (plain format)
%      -dpgmraw   - Portable Graymap (raw format)
%      -dppm      - Portable Pixmap (plain format)
%      -dppmraw   - Portable Pixmap (raw format)
%      -dpdf      - Color PDF file format

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.3 $  $Date: 2004/04/10 23:29:05 $ 

error(nargchk(1,1,nargin) )

rsp_file = [tempname '.rsp'];
rsp_fid = fopen (rsp_file, 'w');
if (rsp_fid < 0)
    error('print:ghostscript', 'Unable to create response file')
end

ghostDir = fullfile( matlabroot, 'sys', 'ghostscript' );

if ~exist(ghostDir)
    error('print:ghostscript', ...
          ['Can not find the directory for Ghostscript in ' matlabroot] )
end

fprintf(rsp_fid, '-dNOPAUSE -q \n');

% To use Japanese versions of Ghostscript comment out % the following two lines.

fprintf(rsp_fid, '-I"%s"\n', fullfile( ghostDir, 'ps_files', ''));
fprintf(rsp_fid, '-I"%s"\n', fullfile( ghostDir, 'fonts', ''));

% To use Japanese versions of Ghostscript, uncomment the following six
% lines and modify the variables GhostFontDir, GhostKanjiDir and 
% GhostLibDir to correct path for your installation of GhostScript.

% GhostFontDir = 'c:\Aladdin\fonts';
% GhostKanjiDir = 'c:\Aladdin\gs6.01\kanji';
% GhostLibDir = 'c:\Aladdin\gs6.01\lib';
% fprintf(rsp_fid, '-I"%s"\n', GhostFontDir);
% fprintf(rsp_fid, '-I"%s"\n', GhostKanjiDir);
% fprintf(rsp_fid, '-I"%s"\n', GhostLibDir);

% For more information on using Japanese versions of GhostScript see 
% toolbox\matlab\graphics\ja\GHOSTSCRIPT.txt

fprintf(rsp_fid, '-sDEVICE=%s\n', pj.GhostDriver);

%If saving as a picture, not a printer format, crop the image,
%unless we are using PDF which needs a paper size.
if pj.GhostImage && ~strncmp(pj.GhostDriver,'pdf',3)
    fprintf(rsp_fid, '-g%.fx%.f\n', pj.GhostExtent(1), pj.GhostExtent(2) );

else    
    %If not the default of letter/Ansi A, set the name Ghostscript wants
    %First object is 'master' object. What do do if the others are not the same?
    gsName = getget( pj.Handles{1}(1), 'papertype' );
    if ~( strcmp(gsName,'usletter') || strcmp(gsName,'A') )
        switch gsName
        case 'uslegal',  gsName = 'legal';
        case 'a4letter', gsName = 'a4';
        case 'tabloid',  gsName = '11x17';
        case 'arch-A',   gsName = 'archA';
        case 'arch-B',   gsName = 'archB';
        case 'arch-C',   gsName = 'archC';
        case 'arch-D',   gsName = 'archD';
        case 'arch-E',   gsName = 'archE';
        case 'B',        gsName = '11x17';
        case 'C',        gsName = 'archC'; %following ANSI sizes not supported
        case 'D',        gsName = 'archD';
        case 'E',        gsName = 'archE';
        otherwise
            % PaperType is already the correct name.
            gsName = lower( gsName );
        end
        fprintf( rsp_fid, '-sPAPERSIZE=%s\n', gsName );
    end
end

%If using GS to produce a TIFF image for an EPS preview.
if pj.PostScriptPreview == pj.TiffPreview 
    res = get(0,'screenpixelsperinch');
    fprintf( rsp_fid, ['-r' int2str(res) 'x' int2str(res) '\n'] );
end

fprintf(rsp_fid, '-sOutputFile="%s"\n', pj.GhostName );
fclose(rsp_fid);

if strcmp( computer, 'PCWIN' )
    if (exist(fullfile(ghostDir,'bin','win32','gs.exe')))
        gsPath = fullfile(ghostDir,'bin','win32','');
    elseif (exist(fullfile(ghostDir,'bin','gs','gs.exe')))
        gsPath = fullfile(ghostDir,'bin','');
    else
        error('print:ghostscript', 'Can not find GhostScript executable.' )
    end

% To use Japanese versions of Ghostscript comment out the following line.

[s, r] = privdos( pj, [ 'echo quit | "' gsPath '\gs" "@' rsp_file ...
      '" "' pj.FileName '"' ] );

% To use Japanese versions of Ghostscript uncomment the following two lines and set
% the variable GhostExe to the correct path for your installation of GhostScript.

%   GhostExe = 'c:\Aladdin\gs6.01\bin\gswin32c.exe';
%   [s, r] = privdos( pj, [ 'echo quit | "' GhostExe '"  "@' rsp_file ...
%                           '" "' pj.FileName '"' ] );

% For more information on using Japanese versions of GhostScript see 
% toolbox\matlab\graphics\ja\GHOSTSCRIPT.txt

else 
  dberror = disabledberror;
  try
    [s, r] = unix( [ '"' fullfile(ghostDir,'bin',getenv('ARCH'),'gs') '"' ...
		     ' "@' rsp_file '" "' pj.FileName '" < /dev/null > /dev/null' ] );
  catch
    % Try unix with one argument if last call fails
    s = unix( [ '"' fullfile(ghostDir,'bin',getenv('ARCH'),'gs') '"' ...
		' "@' rsp_file '" "' pj.FileName '" < /dev/null > /dev/null' ] );
    r = '';
  end
  enabledberror(dberror);
end

if pj.DebugMode
    disp( ['PRINT debugging: GHOSTSCRIPT converting PS file = ''' pj.FileName '''.'] )
    disp( ['PRINT debugging: GHOSTSCRIPT response file = ''' rsp_file ''':'] )
    eval( ['type ' rsp_file] )
    disp( ['Ghostscript STDOUT: ' s ] );
    disp( ['Ghostscript STDERR: ' r ] );
else
    delete(rsp_file)
    delete(pj.FileName)    
end

if ~s && ~isempty(r) && ~strcmp(r,'GS>') && ~all(isspace(r))
  error('print:ghostscript',  'Problem converting PostScript.') 
elseif s
    error('print:ghostscript',  'Problem calling GhostScript. System returned error') 
end

%Ghostscript doesn't return an error if couldn't create file
%because of write protection. See if file was created.
fid = fopen( pj.GhostName, 'r');
if ( fid == -1 )
    error('print:ghostscript', '%s', [ 'Ghostscript could not create ''' pj.GhostName '''.' ])
else
    fclose( fid );
end
