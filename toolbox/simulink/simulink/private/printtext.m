function printtext(varargin)
%PRINTTEXT Print text to the default printer.
%   PRINTTEXT <filename> prints <filename> to the default printer.
%   On UNIX, PRINTTEXT -Pprinter <filename> prints <filename> to the 
%   specified printer. PRINTTEXT <filename1>,<filename2>,...,<filenameN>
%   or PRINTTEXT -Pprinter <filename1>,<filename2>,...,<filenameN> will
%   also work on UNIX only.
%
%   See also PRINTOPT, PRINT.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11.6.1 $  $Date: 2002/11/19 13:03:10 $

ArgsIn=varargin;
printerName='';

if (ArgsIn{1}(1) ~= '-')
  if ~isstr( ArgsIn{1} )
    error( 'Filename argument is not a string.' )
  else
    filename = ArgsIn;
  end
    
elseif (ArgsIn{1}(2) == 'P')
  printerName = ArgsIn{1}(3:end);
  if strncmp(computer,'PC',2)
    warning('Ignoring the -P option because is not allowed on this machine.')
    printerName='';    
  end
  filename=ArgsIn(2:end);

else,
  error('Filename or printer option is not valid.');
  
end % if

if strncmp(computer,'PC',2),
  warning('Can not print text files on PC.');
  return  
  cmd='COPY /A ';
  for lp=1:length(filename),
    cmd = [cmd, '+' filename{lp}];
  end % for lp
  cmd=[cmd ' LPT1:'];  
  dos(cmd);
  
% it's unix or VMS  
else,
  lprcmd = printopt;

  if strcmp( lprcmd, 'lp -c' ) 
    notBSD = 1;
  else
    notBSD = 0;
  end
  if ~isempty( printerName )
    %If user specified a printer, add it to the printing command
    if notBSD | strcmp(computer,'HP700')
      cmdOption='-d'
    else
      cmdOption = '-P';
    end
    lprcmd = [ lprcmd ' ' cmdOption printerName ];
  end
  
  cmd=lprcmd; 

  % If we're on a MAC running 10.1, we need to enscript the file, because plain text
  % files currently cannot be printed on MAC. (rdavis: 5/31/2002)
  if ispuma
    t=[tempname '.ps'];
    for lp=1:length(filename)
      % Catching the return result will suppress echoing the output 
      % to the user.  The primary command still does this for historical
      % reasons.
      [s,r] = unix(['enscript -b '''' -o ' t ' ' filename{lp}]);
      unix([cmd ' ' t]);
      delete(t);
    end
  else
    for lp=1:length(filename),
      cmd = [cmd, ' ' filename{lp}];
    end % for lp
    unix(cmd);
  end 
end % if