function angles = str2angle(strings)

%STR2ANGLE converts formatted DMS angle strings to numbers
%
%  angles = STR2ANGLE(strings) converts the formatted Degrees-Minutes-Seconds
%  strings to numeric angles in units of degrees. Examples of recognized formats 
%  are 123°30'00"S, 123-30-00S, 123d30m00sS and 1233000S. The seconds field may
%  contain a fractional component in all but the last form. Strings may be a 
%  character matrix or a cell array vector of strings.
%
%  See also ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.6.4.1 $    $Date: 2003/08/01 18:20:26 $

if nargin ~= 1; error('Incorrect number of arguments'); end

ascnum = double('0'):double('9');
ascN = double('N');
ascS = double('S');
ascE = double('E');
ascW = double('W');
ascminus = double('-');
ascplus = double('+');
ascdpt = double('.');
ascspc = double(' ');


% convert cell array to a cell array vector
if iscell(strings)
   strings = strings(:);
end

% If the string came from the ANGL2STR, replace the Latex degree character substring
if ischar(strings); strings = num2cell(strings,2); end
strings = strrep(strings,'^{\circ}','°');

% Convert to character array
strings = str2mat(strings{:});

% Attempt to identify format based on the existance of certain characters in the 
% string matrix. At this point we assume that all rows of the character array
% contain strings of the same format. Later we'll verify that this is true, and
% if it is, we'll extract the numbers in a vectorized fashion. If the formats are
% mixed, we'll go row by row.

if ~isempty(findstr(strings(:)','"')) & ~isempty(findstr(strings(:)',''''))
   % [+ | -] ddd ^o mm " ss.sss [N | S] , used by NIMA
   % Don't actually check for the degrees symbol, because the 
   % character code varies across platforms
    dmsformat = 'degree character and quotes';
elseif ~isempty(findstr(strings(:)','d')) & ~isempty(findstr(strings(:)','m')) & ~isempty(findstr(strings(:)','s'))
    % 111d22m33sS    
    dmsformat = 'd,m,s as separators';
elseif length(findstr(strings(:)','-')) == 2*size(strings,1)
    % [d]dd-mm-ss[.ss](N | S), used by the FAA
    dmsformat = 'minus signs as separators';
elseif isempty(setdiff(strings(:)',[ascnum ascN ascS ascE ascW ascminus ascplus ascdpt ascspc]))
    % [d]ddmmss(N | S)
    dmsformat = 'packedDMS';
else
    % need census [+-][d]ddmmsssss
    % need ERS header (like in new etopo5) [-][d]dd:mm:ss
    error('Unrecognized angle format')
end

% Based on the identifed format, attempt to extract the DMS components in 
% a vectorized fashion. Check that all of the rows have the same format, and
% if they don't, punt and let the following block of code go row by row.
punt = 0;

switch dmsformat
case 'packedDMS'                    % dddmmss[N | S]
    
    % right justify strings
    strings = shiftspc(strings);
    
    if ~isempty(setdiff(strings(:,end),[ascN ascS ascE ascW])) % Last character not N,S,E or W
        error('Unrecognized angle format2')
    end

    if size(strings,2) < 7
        error('Unrecognized angle format3')
    end
        
    hemispheresign = ones(size(strings,1),1);
    hemispheresign( strings(:,end) == 'S' | strings(:,end) == 'W' ) = -1;
    
    s = str2num(strings(:,end-2:end-1));
    m = str2num(strings(:,end-4:end-3));
    d = str2num(strings(:,max(1,end-7):end-5));
    
    if ~isequal( size(strings,1), length(d), length(m), length(s) )
        error('Unrecognized angle format3a')
    end
    
    
case 'minus signs as separators'
    
    % right justify strings
    strings = shiftspc(strings);

    if ~isempty(setdiff(strings(:,end),[ascN ascS ascE ascW])) % Last character not N,S,E or W
        error('Unrecognized angle format4')
    end

    if size(strings,2) < 7
        error('Unrecognized angle format5')
    end
        
    hemispheresign = ones(size(strings,1),1);
    hemispheresign( strings(:,end) == 'S' | strings(:,end) == 'W' ) = -1;
    
    [i,j] = ind2sub(size(strings),find(strings(:)'=='-'));

    if size(strings,1) > 1 & (~all(diff(j(end/2+1:end)))==0 | ~all(diff(j(1:end/2)))==0)
        punt = 1;
    else

        s = str2num(strings(:,j(end)+1:end-1));
        m = str2num(strings(:,j(1)+1:j(end)-1));
        d = str2num(strings(:,1:j(1)-1));
        
        if ~isequal( size(strings,1), length(d), length(m), length(s) )
            error('Unrecognized angle format5a')
        end
    
    end
    
case 'degree character and quotes'

    % right justify strings
    strings = shiftspc(strings);
    
    if ~isempty(setdiff(strings(:,end),[ascN ascS ascE ascW])) % Last character not N,S,E or W
        error('Unrecognized angle format6')
    end

    if size(strings,2) < 7
        error('Unrecognized angle format7')
    end
        
    hemispheresign = ones(size(strings,1),1);
    hemispheresign( strings(:,end) == 'S' | strings(:,end) == 'W' ) = -1;
    
    [ip,jp] = ind2sub(size(strings),find(strings(:)'==''''));
    [ipp,jpp] = ind2sub(size(strings),find(strings(:)'=='"'));

    if size(strings,1) > 1 & (~all(diff(jp))==0 |  ~all(diff(jpp))==0) 
        punt = 1;
    else

        s = str2num(strings(:,jp(1)+1:jpp(1)-1));
        m = str2num(strings(:,jp(1)-2:jp(1)-1));
        d = str2num(strings(:,1:jp(1)-4));
        
        if ~isequal( size(strings,1), length(d), length(m), length(s) )
            error('Unrecognized angle format8')
        end
            
    end

case 'd,m,s as separators'

    % right justify strings
    strings = shiftspc(strings);
    
    if ~isempty(setdiff(strings(:,end),[ascN ascS ascE ascW])) % Last character not N,S,E or W
        error('Unrecognized angle format9')
    end

    if size(strings,2) < 7
        error('Unrecognized angle format10')
    end
        
    hemispheresign = ones(size(strings,1),1);
    hemispheresign( strings(:,end) == 'S' | strings(:,end) == 'W' ) = -1;
    
    [id,jd] = ind2sub(size(strings),find(strings(:)'=='d'));
    [im,jm] = ind2sub(size(strings),find(strings(:)'=='m'));
    [is,js] = ind2sub(size(strings),find(strings(:)'=='s'));

    if size(strings,1) > 1 & (~all(diff(jd))==0 | ~all(diff(jd))==0 | ~all(diff(s))==0) 
        punt = 1;
    else

        s = str2num(strings(:,jm(1)+1:js(1)-1));
        m = str2num(strings(:,jd(1)+1:jm(1)-1));
        d = str2num(strings(:,1:jd(1)-1));
        
        if ~isequal( size(strings,1), length(d), length(m), length(s) )
            error('Unrecognized angle format11')
        end
    
    end

end

    

% if strings are not all of the same format, go row by row

if punt
    angles = zeros(size(strings,1),1);
    for i=1:size(strings,1)
        angles(i) = str2angle(strings(i,:));
    end
else
    angles = hemispheresign .* dms2deg(mat2dms(d,m,s));
end


