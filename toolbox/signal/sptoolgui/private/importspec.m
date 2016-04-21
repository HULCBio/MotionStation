function varargout = importspec(action,varargin)
%IMPORTSIG  Import function for Spectrum Structures in the SPTool.
%    'version' - returns string indicating version number for exporting
%      data of this type from SPTool.
%    'make' - creates a new object
%      [err,errstr,struct] = importspec('make',{input values})
%    'valid' - test if input struc is a valid spectrum
%    'fields' - return information about the input fields and field names for
%       this type of object in the import dialog.
%     [popupString,fields,FsFlag,defaultLabel] = import*('fields')
%     struct = importspec('changeFs',struct,Fs) - change the sampling frequency
%             of struct
%     newstruct = importspec('merge',struct1,struct2) - merge struct1 and struct2
%            into new struct, retaining client specific fields of struct1 and
%            global fields of struct2

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

switch action

case 'version'
% versionString = import*('version')
%   returns the version of this component (a string).  This will be saved in
%   any exported SPT data of this type under the SPTIdentifier field
%   of the structure:
%      .SPTIdentifier.version
%      .SPTIdentifier.type  <-- obtained from popupString in the 'fields' call.
   
  % previous revisions: '1.0' - imported spectra (.P and .f) could be row 
  %                             vectors
  % previous revisions: '1.1' - Welch's (psd.m) method contained 3 "Scaling" 
  %                             options 'Unbiased', 'Peaks', & 'by Fs'; and a 
  %                             "Detrending" parameter.
  varargout{1} = '1.2';

case 'fields'

  popupString = 'Spectrum';
  flds.form = 'Spectrum';
  flds.fields = {'PSD' 'Freq. Vector'};
  FsFlag = 0;
  defaultLabel = 'spect';
  
  varargout = {popupString,flds,FsFlag,defaultLabel};
  
case 'make'
% [err,errstr,struc] = importspec('make',{input values})
% Inputs:
%   {input values} cell array -
%     first element is integer giving the value of the 'form' popup
%      (e.g. 1==TF, 2==SS, 3=ZPK, etc)
%     elements 2..N are MATLAB variables.  If FsFlag == 1, the last one
%       is the sampling frequency Fs.
%  This needs to be the only place you use to create new objects,
%  since the fields and their order have to be the same for every object!

    err = 0;
    errstr = '';
    formValue = varargin{1}{1};
    
    % initialize empty structure:
    struc.P = varargin{1}{2};
    struc.f = varargin{1}{3};
    struc.confid = [];
    struc.specs = [];
    struc.signal = 'none';
    struc.signalLabel = '';
    struc.Fs = 1;
    
    if isempty(errstr)
        if ndims(struc.P)~=2 | ~strcmp(class(struc.P),'double')
           errstr = 'The data for the spectrum must be a 2-D matrix of class ''double''.';
        end
        if any(size(struc.P)==1)
            struc.P = struc.P(:);  % make into column
        end
    end
    if isempty(errstr)
        if ndims(struc.f)~=2 | ~strcmp(class(struc.f),'double')
           errstr = ['The frequency vector for the spectrum'...
                     ' must be a 2-D matrix of class ''double''.'];
        end
        if any(size(struc.f)==1)
            struc.f = struc.f(:);  % make into column
        end
    end
    if isempty(errstr)
        if ~isequal(length(struc.P),length(struc.f))
            errstr = 'The lengths of PSD and Frequency vectors must be the same.';
        end
    end
    if isempty(errstr)
        if ~isreal(struc.f)
            errstr = 'The Frequency Vector must be real.';
        end
    end
    if isempty(errstr)
        if ~isreal(struc.P) | any(struc.P<0)
            errstr = 'The input spectral data must be real and non-negative.';
        end
    end
    
    % --------
    if isempty(errstr), err = 0; else err = 1; end
  
    if ~err
        struc = importspec('assignType',struc);
        struc.lineinfo = [];
        struc.SPTIdentifier.type = 'Spectrum';
        struc.SPTIdentifier.version = importspec('version');
    else
        struc = [];
    end
    
    struc.label = '';
    
    varargout = {err,errstr,struc};

case 'valid'
%  [valid,struc] = import*('valid',struc) - return 
%    1 if the input structure is a valid "object", 0 if not.
%    input struc assumed to have field SPTIndentifier with fields
%        .type, .version, and struc.SPTIndentifier.type is the
%        correct string
%    Updates the structure if the version is old.
%    Also sets '.type' field of struc
%  Criteria for validity:
%    - structure has the correct fields in the correct order
%    - some of the fields are checked for class information
% FOR SPECTRA:  if the signalLabel field of the input struc is not empty, 
%     the signals in SPTOOL are checked for the existance of this signal.
%     If not found, the signalLabel field is set to empty, and signal
%     field is set to 'none'.
%     If found, the signal field is set to the correct size and complex
%     flag of the found signal, and the P and f fields are cleared.

    valid = 1;   % assume valid on input
    struc = varargin{1};
    
    % first test to see if struc can be added to structure array;
    % if successful, fields are same and in same order
    [err,errstr,vanillaStruc]=importspec('make',{1 1 1});
    eval('vanillaStruc(2)=struc;','valid=0;')
    
    % now assuming the fields are all there, test their contents
    % for validity:
    if valid
        valid = isequal(class(struc.P),'double');
    end
    if valid
        valid = isequal(class(struc.f),'double');
    end

    if valid
        struc = importspec('assignType',struc);
    end
    
    % Update version 1.1 of the structure to version 1.2.
    if valid
        % NOTE: The following code is bad because we're using knowledge of 
        %       the methods in Spectrum Viewer (eg. 'Welch'). pjp 7/98
        
        indx = find(strcmp(struc.specs.methodName,'Welch'));
        
        % Set Welch's "Scaling" option to 1 if it's 3.  PSD was replaced by
        % PWELCH and PWELCH scales by Fs by default (hence, 3rd scaling 
        % option has been removed from Spectrum Viewer).
        if struc.specs.valueArrays{indx}{end} == 3;
            struc.specs.valueArrays{indx}{end} = 1;
        end        
    end
    
    if valid & ~isempty(struc.signalLabel)
%        sigs = sptool('Signals');
        %  Is the spectrum linked to a signal?
        if ~isempty(struc.signalLabel)
            % if spectrum is linked to signal, .signal field contains
            % the following 3-element vector:
            %    [size(signal.data,1) size(signal.data,2) ~isreal(signal.data)]
            % For now, assign special values which indicate that the
            % link is unresolved ... link will be resolved when it
            % is needed in the spectrum viewer (or other spectrum clients)
            % struc.signal = [-1 -1 0];
        else
            struc.signal = 'none';
        end
%         ind = findcstr({sigs.label},struc.signalLabel);
%         if isempty(ind)
%             struc.signalLabel = '';
%             struc.signal = 'none';
%         else
%             struc.signal = [size(sigs(ind).data) ~isreal(sigs(ind).data)];
%             struc.P = [];
%             struc.f = [];
%         end
    end
    
    varargout = {valid,struc};
    return

case 'assignType'
% struc = import*('assignType',struc)

  struc = varargin{1};
  struc.type = 'auto';
  varargout{1} = struc;
%----------------------------------------------------------------------------
%     struct = importspec('changeFs',struct,Fs) - change the sampling frequency
%             of struct
case 'changeFs'
    struc = varargin{1};
    newFs = varargin{2};
    oldFs = struc.Fs;
    if ~isstr(struc.signal)
        if ~isempty(struc.f)
            struc.f = struc.f*newFs/oldFs;
        end
    end
    struc.Fs = newFs;
    varargout{1} = struc;

%----------------------------------------------------------------------------
%     newstruct = importspec('merge',struct1,struct2) - merge struct1 and struct2
%            into new struct, retaining client specific fields of struct1 and
%            global fields of struct2
%     This callback is provided for when you import a new structure via
%     the import dialog and there is already a structure in the SPTool that
%     has this name.  Some of the fields (eg, 'data' and 'Fs')  
%     are global and need to be changed by this action, others which are 
%     controlled by the clients (eg, 'lineinfo', 'specs' and 'label') may not.
%
%     Both are assumed valid structures on input.
case 'merge'
    struct1 = varargin{1};
    struct2 = varargin{2};
  
    newstruct = struct2;
    
    if isempty(struct2.lineinfo)
        newstruct.lineinfo = struct1.lineinfo;
    end
    if isempty(struct2.specs)
        newstruct.specs = struct1.specs;
    end
    
    varargout{1} = newstruct;

end
