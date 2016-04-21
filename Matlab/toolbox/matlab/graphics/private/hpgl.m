function hpgl( pj )
%HPGL Method to add control characters to beginning of HPGL files.
%   As produced by MATLAB, the HPGL files are missing control codes needed
%   for most operating systems to properly communicate with HPGL plotters.
%   These control codes are added to lines left blank in the HPGL file
%   so that users may modify them match their hardware. The control
%   codes given work with HP7475A and compatible plotters.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:09:40 $

%Add Xon/Xoff handshaking parameters to HPGL files.
% If these settings are not appropriate for you hardware,
% modify it -- the first line of the HPGL file is 80 blanks
% to make this easier.
% To make no such modifications, replace the elseif above with
% elseif 0

%Open the HPGL file we just wrote out.
[ fid, msg ] = fopen( pj.FileName, 'r+' );
if ( fid == -1 )
    error( ['Could not open HPGL file: ''' msg ''''] );
end

%The Escape code is ASCII 27
esc = setstr( 27 );

%Plotter initialization:
% Plotter On Instruction == ESC.Y;
% Set Handshake Mode 2 Instruction == ESC.I<options>;
%   3 optional arguments <blocksize>;<enquiry>;<acknowledgment>
%               blocksize == 200 bytes
%       enquiry character == defaults to NULL
%   acknowledgment string == ASCII character 17
% Set Extended Output and Handshake Mode Instruction == ESC.N<options>;
%   3 optional arguments <delay>;<trigger>
%     intercharacter delay == 50 milliseconds
%   Xoff trigger character == ASCII 19
% For more information, see your plotter manual or local hardware guru.
fprintf( fid, [esc '.Y;' esc '.I200;;17:' esc '.N50;19:;'] );

err = fseek( fid, 0, 'eof' );
if ( err == -1 )
    error('Could not seek to EOF of HPGL file');
end

%Plotter off
% Can't turn off power, just puts plotter in passive state
fprintf( fid, [esc '.Z\n'] );

fclose( fid );
