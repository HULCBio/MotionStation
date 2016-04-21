function [tags, pos, info, file] = dicom_get_tags(file, info)
%DICOM_GET_TAGS  Find attributes tags and positions from DICOM file.
%   [TAGS, POS, INFO, FILE] = DICOM_GET_TAGS(FILE, INFO) reads the
%   attribute tags and their positions from a DICOM file.  TAGS is an
%   n-by-2 array of the group and entry values for the attributes.  POS
%   is their position in the message, relative to the start of the
%   132-byte DICOM preamble or the start of the message if there is no
%   file metadata.  INFO contains only the value for the transfer syntax,
%   if it file metadata is present.
%
%   See also DICOM_READ_ATTR_BY_POS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2003/08/23 05:53:46 $

if (dicom_has_fmeta(file))
    
    % File metadata.
    [tags1, pos1, info] = dump_file_attr(file, info);
    
else
    
    tags1 = [];
    pos1 = [];
    
end

% Find the encoding for the remaining metadata.

file = dicom_set_mmeta_encoding(file, info);

% Message metadata.
[tags2, pos2] = dump_msg_attr(file);

tags = [tags1; tags2];
pos = [pos1 pos2]';



%%%
%%% Function dump_file_attr
%%%

function [tags, pos, info] = dump_file_attr(file, info)

%
% Move to beginning of file metadata.
%

fread(file.FID, 132, 'uint8');

%
% Set up for reading.
%

file.Current_Endian = 'ieee-le';

if (has_wrong_vr_type(file))
    file.Current_VR = 'Implicit';
else
    file.Current_VR = 'Explicit';
end

%
% Read the attributes.
%

more_items = 1;
count = 0;

tags = [];
pos = [];

while (more_items)
    
    count = count + 1;
    
    fpos = ftell(file.FID);
    tag = fread(file.FID, 2, 'uint16', file.Current_Endian);

    % It is possible that FEOF marker was set after last read.  Don't
    % continue.
    if (feof(file.FID))
        
        more_items = 0;
        continue
        
    end
    
    if ((isequal(file.Current_VR, 'Explicit')) && (tag(1) ~= 65534))
        
        % Non-item/delimiter attribute.
        
        vr = char(fread(file.FID, 2, 'char', file.Current_Endian))';
        len = get_explicit_length(file, vr);
    
    else
        
        len = fread(file.FID, 1, 'uint32', file.Current_Endian);
        
    end
        
    % Store everything.

    if (tag(1) == 2)
        
        tags(count, :) = tag';
        pos(count) = fpos;
        
    else
        
        more_items = 0;
        fseek(file.FID, fpos, 'bof');
        
        continue
        
    end
    
    % Store if transfer syntax.
    if (tag(2) == 16)  % (0002,0010)
        
        data = char(fread(file.FID, len, 'char', file.Current_Endian))';
        info.TransferSyntaxUID = my_deblank(data);
        
    else
        
        if (~isequal(len, uint32(inf)))
            
            % Skip over the data.
            fseek(file.FID, len, 'cof');
            
        else
            
            % Start reading next attribute at end of this attribute's
            % length.
            
        end
    
    end

end


%%%
%%% Function dump_msg_attr
%%%

function [tags, pos] = dump_msg_attr(file)

more_items = 1;
count = 0;

tags = [];
pos = [];

while (more_items)
    
    count = count + 1;
    
    fpos = ftell(file.FID);
    tag = fread(file.FID, 2, 'uint16', file.Current_Endian);

    % It is possible that FEOF marker was set after last read.  Don't
    % continue.
    if (feof(file.FID))
        
        more_items = 0;
        continue
        
    end
    
    if ((isequal(file.Current_VR, 'Explicit')) && (tag(1) ~= 65534))
        
        % Explicit, non-item/delimiter attribute.
        
        vr = char(fread(file.FID, 2, 'char', file.Current_Endian))';
        len = get_explicit_length(file, vr);
        
    else
        
        len = fread(file.FID, 1, 'uint32', file.Current_Endian);
        
    end
    
    % Store everything.
    tags(count, :) = tag';
    pos(count) = fpos;
    
    if (isequal(tag, [32736; 16]))  % (7FE0,0010)
        
        more_items = 0;
        fseek(file.FID, fpos, 'bof');
        
        continue
        
    end

    
    if (~isequal(len, uint32(inf)))
        
        % Skip over the data.
        fseek(file.FID, len, 'cof');
        
    else
        
        % Start reading next attribute at end of this attribute's
        % length.
        
    end
    
end



%%%
%%% Function get_explicit_length
%%%

function len = get_explicit_length(file, vr)
% Read the length of an attribute in explicit VR mode.

switch (vr)
case {'OB', 'OW', 'SQ', 'UT'}
    
    fread(file.FID, 2, 'uint8');
    len = fread(file.FID, 1, 'uint32', file.Current_Endian);
    
case 'UN'
    
    % Items/delimiters don't have the two-byte padding.  Those attributes
    % should not call this function.
    
    fread(file.FID, 2, 'uint8');
    len = fread(file.FID, 1, 'uint32', file.Current_Endian);
    
case {'AE','AS','AT','CS','DA','DS','DT','FD','FL','IS','LO','LT', ...
      'PN','SH','SL','SS','ST','TM','UI','UL','US'} 
    
    len = fread(file.FID, 1, 'uint16', file.Current_Endian);
    
otherwise
    
    % PS 3.5-1999 Sec. 6.2 indicates that all unknown VRs can be
    % interpretted as being the same as OB, OW, SQ, or UN.  The size
    % of data is not known but, the reading structure is.  
    
    fread(file.FID, 2, 'uint8');
    len = fread(file.FID, 1, 'uint32', file.Current_Endian);
    
end



%%%
%%% Function my_deblank
%%%

function str = my_deblank(str)
%MY_DEBLANK  Deblank a string, treating char(0) as a blank.

if (isempty(str))
    return
end

while (str(end) == 0)
    str(end) = '';
end

str = deblank(str);



function tf = has_wrong_vr_type(file)
%HAS_WRONG_VR_TYPE  See if file metadata incorrectly uses implicit VR.

fseek(file.FID, 4, 'cof');
vr = char(fread(file.FID, 2, 'uchar')');
accept = {'AE' 'AS' 'AT' 'CS' 'DA' 'DS' 'DT' 'FL' 'FD' 'IS' 'LO' 'LT' ...
          'OB' 'OW' 'PN' 'SH' 'SL' 'SQ' 'SS' 'ST' 'TM' 'UI' 'UL' 'UN' ...
          'US' 'UT'};

switch (vr)
case accept
    tf = 0;
otherwise
    tf = 1;
end

fseek(file.FID, -6, 'cof');
