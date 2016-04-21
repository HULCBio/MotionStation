function [ options, devices, extensions, classes, colorDevs, destinations, descriptions] = printtables( pj )
%PRINTTABLES Method to create cell arrays of data on drivers and options available.
%   Tables are for use in input validation of arguments to PRINT command.
%
%   See also PRINT

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2004/04/01 16:12:13 $

% List of all supported devices used for input validation.
%
%The first column contains the device name
%the second column contains the default filename extension, 
%the third column indicates what type of output device is employed, 
%the fourth indicates Monochrome or Color device, and
%the last is what do do with output for that driver, P for print or X for export
%
device_table = [
    %Postscript device options
    {'ps'           'ps'   'PS'   'M'    'P'  'Postscript'}
    {'psc'          'ps'   'PS'   'C'    'P'  'Postscript Color'}
    {'ps2'          'ps'   'PS'   'M'    'P'  'Postscript Level 2'}
    {'ps2c'         'ps'   'PS'   'C'    'P'  ['Postscript' ...
					' Level 2 Color']}
    {'psc2'         'ps'   'PS'   'C'    'P'  ['Postscript' ...
					' Level 2 Color']}
    {'eps'          'eps'  'EP'   'M'    'X'  'EPS file'}
    {'epsc'         'eps'  'EP'   'C'    'X'  'EPS Color file'}
    {'eps2'         'eps'  'EP'   'M'    'X'  'EPS Level 2 file'}
    {'eps2c'        'eps'  'EP'   'C'    'X'  ''}
    {'epsc2'        'eps'  'EP'   'C'    'X'  'EPS Level 2 Color file'}
    
    %Other built-in device options
    {'hpgl'              'hgl'  'BI'   'C'    'P'  'HPGL'}
    {'ill'               'ai'   'BI'   'C'    'X'  'Adobe Illustrator file'}
    {'mfile'             ''     'BI'   'C'    'X'  ''}
    {'tiff'              'tif'  'IM'   'C'    'X'  'TIFF image'}
    {'tiffnocompression' 'tif'  'IM'   'C'    'X'  'TIFF no compression image'}
    {'bmp'               'bmp'  'IM'   'C'    'X'  ''}
    {'hdf'               'hdf'  'IM'   'C'    'X'  ''}
    {'png'               'png'  'IM'   'C'    'X'  'Portable Network Graphics file'}
 ];
if isunix && ~strcmp(get(0,'TerminalProtocol'),'x')
device_table = [ device_table ; 
    {'jpeg'              'jpg'  'GS'   'C'    'X'  'JPEG image'}
];
else
device_table = [ device_table ; 
    {'jpeg'              'jpg'  'IM'   'C'    'X'  'JPEG image'}
];
end

%GhostScript device options
device_table = [ device_table ; 
    {'laserjet'     'jet'  'GS'   'M'    'P'  'HP LaserJet'}
    {'ljetplus'     'jet'  'GS'   'M'    'P'  'HP LaserJet Plus'}
    {'ljet2p'       'jet'  'GS'   'M'    'P'  'HP LaserJet IId/IIp'}
    {'ljet3'        'jet'  'GS'   'M'    'P'  'HP LaserJet III'}
    {'ljet4'        'jet'  'GS'   'M'    'P'  'HP LaserJet 4/5L/5P'}
    {'pxlmono'      'jet'  'GS'   'M'    'P'  'HP LaserJet 5/6'}
    {'cdjcolor'     'jet'  'GS'   'C'    'P'  ['HP DeskJet 500C 24bit' ...
	 'color']}
    {'cdjmono'      'jet'  'GS'   'M'    'P'  'HP DeskJet 500C b+w'}
    {'deskjet'      'jet'  'GS'   'M'    'P'  'HP DeskJet/DeskJet Plus'}
    {'cdj550'       'jet'  'GS'   'C'    'P'  ['HP DeskJet 550C/' ...
					'560C/660C/660Cse']}
    {'djet500'      'jet'  'GS'   'M'    'P'  'HP DeskJet 500C/540C'}
    {'cdj500'       'jet'  'GS'   'C'    'P'  'HP DeskJet 500C'}
    {'paintjet'     'jet'  'GS'   'C'    'P'  'HP PaintJet'}
    {'pjetxl'       'jet'  'GS'   'C'    'P'  'HP PaintJet XL'}
    {'pjxl'         'jet'  'GS'   'C'    'P'  'HP PaintJet XL (alternate)'}
    {'pjxl300'      'jet'  'GS'   'C'    'P'  'HP PaintJet XL300'}
    {'dnj650c'      'jet'  'GS'   'C'    'P'  'HP DesignJet 650C'}
    {'bj10e'        'jet'  'GS'   'M'    'P'  'Canon BubbleJet 10e'}
    {'bj200'        'jet'  'GS'   'C'    'P'  'Canon BubbleJet 200'}
    {'bjc600'       'jet'  'GS'   'C'    'P'  'Canon Color BubbleJet 600/4000/70'}
    {'bjc800'       'jet'  'GS'   'C'    'P'  'Canon Color BubbleJet 800'}
    {'epson'        'ep'   'GS'   'M'    'P'  'Epson'}
    {'epsonc'       'ep'   'GS'   'C'    'P'  'Epson LQ-2550'}
    {'eps9high'     'ep'   'GS'   'M'    'P'  'Epson 9-pin'}
    {'ibmpro'       'ibm'  'GS'   'M'    'P'  'IBM Proprinter'}
    {'ln03'         'ln3'  'GS'   'M'    'P'  'DEC LN03'}
    {'pcxmono'      'pcx'  'GS'   'M'    'X'  ''}
    {'pcxgray'      'pcx'  'GS'   'C'    'X'  ''}
    {'pcx16'        'pcx'  'GS'   'C'    'X'  ''}
    {'pcx256'       'pcx'  'GS'   'C'    'X'  ''}
    {'pcx24b'       'pcx'  'GS'   'C'    'X'  'Paintbrush 24-bit file'}
    {'bmpmono'      'bmp'  'GS'   'M'    'X'  ''}
    {'bmp16m'       'bmp'  'GS'   'C'    'X'  ''}
    {'bmp256'       'bmp'  'GS'   'C'    'X'  ''}
    {'pngmono'      'png'  'GS'   'M'    'X'  ''}
    {'pnggray'      'png'  'GS'   'C'    'X'  ''}
    {'png16m'       'png'  'GS'   'C'    'X'  ''}
    {'png256'       'png'  'GS'   'C'    'X'  ''}
    {'pbm'          'pbm'  'GS'   'C'    'X'  'Portable Bitmap file'}
    {'pbmraw'       'pbm'  'GS'   'C'    'X'  ''}
    {'pgm'          'pgm'  'GS'   'C'    'X'  'Portable Graymap file'}
    {'pgmraw'       'pgm'  'GS'   'C'    'X'  ''}
    {'ppm'          'ppm'  'GS'   'C'    'X'  'Portable Pixmap file'}
    {'ppmraw'       'ppm'  'GS'   'C'    'X'  ''}
    {'pkm'          'pkm'  'GS'   'C'    'X'  'Portable inKmap file'}
    {'pkmraw'       'pkm'  'GS'   'C'    'X'  ''}
    {'sgirgb'       'sgi'  'GS'   'C'    'X'  ''}
    {'tifflzw'      'tif'  'GS'   'C'    'X'  ''}
    {'tiffpack'     'tif'  'GS'   'C'    'X'  ''} 
    {'tiff24nc'     'tif'  'GS'   'C'    'X'  ''}
    {'pdfwrite'     'pdf'  'GS'   'C'    'X'  'Portable Document Format'} 
];

if strcmp( computer, 'PCWIN' )
    platform_device_table = [
        {'win'      ''      'MW'    'M'    'P'  'Windows'}
        {'winc'     ''      'MW'    'C'    'P'  'Color Windows'}
        {'meta'     'emf'   'MW'    'C'    'X'  'Enhanced metafile'}
        {'bitmap'   'bmp'   'MW'    'C'    'X'  'Bitmap file'}
        {'setup'    ''      'MW'    'M'    ''   ''}
    ];
    
else %Unix
    %no Unix specific Ghostscript devices
    platform_device_table = {};
end

device_table = [ platform_device_table ; device_table ];

%Set them in table as cell arrays of cell arrays for convience of entry,
%now break them up into individual cell arrays for ease of use.
devices = device_table(:, 1 );
extensions = device_table(:, 2 );
classes = device_table(:, 3 );
colorDevs = device_table(:, 4 );
destinations = device_table(:, 5 );
descriptions = device_table(:, 6 );

%
% Set up print options table
%
options = { 
    'loose'
    'tiff'
    'append'
    'adobecset'
    'cmyk'
    'r'
    'noui'
    'opengl',
    'painters'
    'zbuffer',
    'DEBUG'    %Undocumented, prints out diagnostic information
};

if strcmp( computer, 'PCWIN' )
    platform_options = { 'v' };
    
else %must be unix
    platform_options = {};
end

options = [ options ; platform_options ];
