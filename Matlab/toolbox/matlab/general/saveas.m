function saveas( h, name, format )
%SAVEAS Save Figure or model to desired output format.
%   SAVEAS(H,'FILENAME')
%   Will save the Figure or model with handle H to file called FILENAME. 
%   The format of the file is determined from the extension of FILENAME.
%
%   SAVEAS(H,'FILENAME','FORMAT')
%   Will save the Figure or model with handle H to file called FILENAME. 
%   in the format specified by FORMAT. FORMAT can be the same values as
%   extensions of FILENAME. The FILENAME extension does not have to be 
%   the same as FORMAT.  Given FORMAT overrides FILENAME extension.
%
%   Valid options for FORMAT are:
%
%   'fig'  - save figure to a single binary FIG-file.  Reload using OPEN. 
%   'm'    - save figure to binary FIG-file, and produce callable
%            M-file for reload.
%   'mfig' - same as M.
%   'mmat' - save figure to callable M-file as series of creation commands 
%            with param-value pair arguments.  Large data is saved to MAT-file.
%            Note: MMAT Does not support some newer graphics features. Use
%                  this format only when code inspection is the primary goal.
%                  FIG-files support all features, and load more quickly. 
%
%   Allowable options also include devices allowed by PRINT.
%
%   Examples:
%
%   Write current figure to MATLAB fig file
%
%       saveas(gcf, 'output', 'fig')
%
%   Write current figure to windows bitmap file
%
%       saveas(gcf, 'output', 'bmp')
%
%   See Also LOAD, SAVE, OPEN, PRINT

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/10 17:03:16 $ 

%Input validation
if nargin < 2 
    error( 'Require handle to Figure/model and filename.' )
end

if ~ishandle(h)
    error( 'Invalid handle.' )
end

if ishghandle(h)
    while ~isfigure(h) & ~isempty(h)
        h = get(h,'Parent');
    end
    if isempty(h)
        error('Invalid figure handle.')
    end
else
    if ~strcmp( 'block_diagram', get_param( h, 'type' ) ) ...
            & ~strcmp( 'SubSystem', get_param( h, 'blocktype' ) )
        error( 'Invalid Simulink handle.' )
    end
end


if ~isstr(name) | isempty(name)
    error( 'Invalid filename.' );
end

% since this is a callback from the figure menu, it is possible that
% uimenufcn will give a bogus filename (one with a * in it) if we get
% any *'s in the filename, error out gracefully.
% might want to generalize this to the same set of chars windows prevents
% in filenames - could be crippling on unix though.
if any(name == '*')
    error( [ 'Invalid filename: ' name ', * is not a valid filename character.'] )
end

% Make sure we can write given file. Note fileparts returns leaf directory in
% name return argument if given filename is only a path, i.e. 'c:\temp'.
[fp,fn,fe]=fileparts(name);

% NOTE: this does not allow to say:
% saveas(gcf, 'foo.', '-fig')
% maybe that's OK...
% william - 11/98
if ~isempty(fe) & strcmp(fe, '.')
    error(['Invalid extension: ' name]);
end
if isempty(fe)
   fe = '.fig';
end
if isempty(fn) 
    error( [ 'Invalid filename: ' name ] );
end
if ~isempty(fp) 
    if exist(fp) ~= 7
        error( [ 'Invalid or missing path: ' name ] )
    end
end

if nargin == 2
    if isempty(fe) | strcmp(fe,'.')
        error( [ 'No format or filename extension specified: ' name ])
    end
    format = fe(2:end); %Do not want the '.'
end

%For some formats we have helper SAVEAS... functions
% make sure format is defined to prevent recursion into this file
if ~isempty(format) & any( exist( ['saveas' format] ) == [2 3 5 6] )
    feval( ['saveas' format], h, name )
    
else    
    %If FORMAT is specified, look first to see if it is an extension
    %we know is that of a PRINT output format. If not, look to see if
    %it is a PRINT supported device format specifier.
    [ops,dev,ext] = printtables;
    i = strmatch( format, ext );
    
    if length(i) >= 1
        %Handle special cases, more then one device, i.e. format='ps'
        i = i(1);
        
    elseif isempty(i)
        i = strmatch( format, dev, 'exact'  );
        if isempty(i)
            i = strmatch( format, dev  );
            if ~isempty(i)
                %Need to handle cases of multiple devices, i.e. format='ljet'
                i = i(1);
            end
        end
    end
    
    %FORMAT is a PRINT support ext or driver
    if isempty(i)
        error( [ 'Unsupported format or extension: ' format ] )
    else
        print( h, name, ['-d' dev{i}] )
        return
    end
    
end
