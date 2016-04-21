function ccshotcoeff(e,bwarning)
%CCSHOTCOEFF - Hot Link to Code Composer Studio for Coefficient updates
%  CCSHOTCOEFF(E,BWARN) Extracts filter coefficients from the 'E' structure
%  and transfers them directly to the memory space of a DSP chip.  The
%  E structure contains information about the target of this transfer.
%  The target DSP must have global data variables with labels that match
%  the names passed in E.  BWARN is a Boolean flag that enables or
%  disables warning dialog boxes.  Thus if BWARN is false, all warnings 
%  dialogs will be suppressed.
%
%  Note:
%  - this routine performs minimal checking on the validity of memory
%  writes to the Target DSP.  
%  - data writes are performed in 'C' form.  This means that 
%  multi-dimensional data arrays are stored in row-major format. 
%  Furthermore, they are padded with zeros to ensure an equal number
%  of elements in a given dimension.
%
% Significant E structure members
%  coeffvars       - Variable names for coefficients
%  coefflengthvars - Variable names for coefficient lengths
%  nsecs           - Number of Sections
%  brdNo           - Board Number of DSP 
%  procNo          - Processor Number of DSP
%  coeffs         -  Coefficients data
%
%  See also CCSDSP, FDATOOL
               
%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/06 01:05:02 $

error(nargchk(2,2,nargin));

canmsg = 'Cancel';
cc = ccsdsp('boardnum',e.brdNo,'procnum',e.procNo);
cc.visible(1);

if bwarning,
    sFamily = p_getProcessorType(cc,'family');
    if strcmpi(sFamily,'C5x') || strcmpi(sFamily,'C2x'),
        % Data types not supported: double-precision floating point number, int8/uint8
        if strcmp(e.DataType,'double'),
            msg = sprintf(['WARNING! \nThe %s family does not have native support ',...
                'for double-precision floating-point data types.  ',...
                'It is recommended that you cancel this request ',...
                'and use a supported data type.'],sFamily);
            resp = questdlg(msg,sprintf('IEEE Double Precision on %s',sFamily),'Continue',canmsg,canmsg);
            if strcmp(resp,canmsg),
                warning('Operation was cancelled at user''s request');
                return;
            end
        elseif strcmpi(e.DataType,'int8') || strcmpi(e.DataType,'uint8'),
            msg = sprintf(['WARNING! \nThe %s family does not have native support ',...
                'for 8-bit data types. It is recommended that you cancel ',...
                'this request and use a supported data type.'],sFamily);
            resp = questdlg(msg,sprintf('8-bit data types on %s',sFamily),'Continue',canmsg,canmsg);
            if strcmp(resp,canmsg),
                warning('Operation was cancelled at user''s request');
                return;
            end
        end
    end
end

% Read address locations of the user's specified coefficient arrays
varadd = [];
for varD = e.coeffvars,
    addV = cc.address(varD{1});
    if isempty(addV),
        error(['Unable to locate user defined variable: ''' varD{1} ''' in target (Is program loaded?)']);
    end
    varadd =[varadd; addV];
end

% Read address locations of the user's specified coefficient length arrays
varaddlen = [];
for varD = e.coefflengthvars,    
    addV = cc.address(varD{1});
    if isempty(addV),
        error(['Unable to locate user defined variable: ''' varD{1} ''' in target (Is program loaded?)']);
    end    
    varaddlen = [varaddlen; addV];
end

% OK format the data for writing - 
% the first step is to convert the cell-arrays into 1-D arrays of data values
%  which are formated for "C" data array ordering (row-major).
%   dataRM - cell array of 1-D data arays in row major format
 
% For Multi-section filters, this may require padding, conversion to row-major and dereferencing
for ivar = 1:length(e.coeffvars), 
    % First Determine maximum section size for each variable (Num, Den, etc)
    % and put it in MaxEL
    maxEl(ivar) = 1;    
    for vsec = e.coeffs,
        vsecD= vsec{1}(ivar); % Dereference
        tempEl = length(vsecD{1});
        if tempEl > maxEl(ivar),
            maxEl(ivar) = tempEl;
        end
    end
end
% OK create a 1-D and padded version of values for each coefficient
for ivar = 1:length(e.coeffvars), 
    dataTmp = [];
    dataTmpLen = [];
    for vsec = e.coeffs,
        vsecD= vsec{1}(ivar); % Dereference
        vsecDD= vsecD{1};   % Dereference
        padN = maxEl(ivar) - length(vsecDD);
        dataTmp = [dataTmp vsecDD zeros(1,padN)];
        dataTmpLen = [dataTmpLen length(vsecDD)];
    end
    dataRM{ivar} = dataTmp;         % Padded 1-d version of coefficients for variable # ivar
    dataRMLen{ivar} = dataTmpLen;   % length of valid coefficients for each section
end

% May want to issue warnings at this point concerning memory utilization
if bwarning,
    % ??    
end
    
% Write the data to the target's memory
for ivar = 1:length(e.coeffvars),
    try
        cc.write(varadd(ivar,:),dataRM{ivar},30);
    catch
        disp(lasterr);
        error(['Failed during write to ''' e.coeffvars{ivar} ''' in target']);
    end
end

if strcmpi(sFamily,'C5x')  % int => 16 bits
    for ivarlen = 1:length( e.coefflengthvars),
        try
            cc.write(varaddlen(ivarlen,:),int16(dataRMLen{ivarlen}),30);
        catch
            disp(lasterr);
            error(['Failed during write to ''' e.coeffvars{ivarlen} ''' in target']);
        end
    end
else
    % int => bits
    for ivarlen = 1:length(e.coefflengthvars),
        try
            cc.write(varaddlen(ivarlen,:),int32(dataRMLen{ivarlen}),30);
        catch
            disp(lasterr);
            error(['Failed during write to ''' e.coefflengthvars{ivarlen} ''' in target']);
        end
    end
end
    
% [EOF] ccshotcoeff.m

