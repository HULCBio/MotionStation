function varargout = importsig(action,varargin)
%IMPORTSIG  Import function for Signal Structures in the SPTool.
%    'version' - returns string indicating version number for exporting
%      data of this type from SPTool.
%    'make' - creates a new object
%      [err,errstr,struct] = importsig('make',{input values})
%    'valid' - test if input struc is a valid signal
%    'fields' - return information about the input fields and field names for
%       this type of object in the import dialog.
%     [popupString,fields,FsFlag,defaultLabel] = import*('fields')
%     struct = importsig('changeFs',struct,Fs) - change the sampling frequency
%             of struct
%     newstruct = importsig('merge',struct1,struct2) - merge struct1 and struct2
%            into new struct, retaining client specific fields of struct1 and
%            global fields of struct2

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

switch action

case 'version'
% versionString = import*('version')
%   returns the version of this component (a string).  This will be saved in
%   any exported SPT data of this type under the SPTIdentifier field
%   of the structure:
%      .SPTIdentifier.version
%      .SPTIdentifier.type  <-- obtained from popupString in the 'fields' call.
   
  varargout{1} = '1.0';

case 'fields'
  popupString = 'Signal';
  flds.form = 'Signal';
  flds.fields = {'Data'};
  FsFlag = 1;
  defaultLabel = 'sig';
  
  varargout = {popupString,flds,FsFlag,defaultLabel};
  
case 'make'
% [err,errstr,struc] = importsig('make',{input values})
% Inputs:
%   {input values} cell array -
%     first element is integer giving the value of the 'form' popup
%      (e.g. 1==TF, 2==SS, 3=ZPK, etc)
%     elements 2..N are MATLAB variables.  If FsFlag == 1, the last one
%       is the sampling frequency Fs.
%  This needs to be the only place you use to create new objects,
%  since the fields and their order have to be the same for every object!

    errstr = '';
    struc.data = varargin{1}{2};
    if any(size(struc.data)==1)
        struc.data = struc.data(:);  % make into column
    end
    struc.Fs = varargin{1}{3};
    if ndims(struc.data)~=2 | ~strcmp(class(struc.data),'double')
       errstr = 'The data for the signal must be a 2-D matrix of class ''double''.';
    end
    if ~all(size(struc.Fs)==1) | ~isreal(struc.Fs) | struc.Fs<=0
        errstr = 'The sampling frequency must be a positive real scalar.';
    end
    
    if isempty(errstr), err = 0; else err = 1; end
  
    if ~err
        struc = importsig('assignType',struc);
        struc.lineinfo = [];
        struc.SPTIdentifier.type = 'Signal';
        struc.SPTIdentifier.version = importsig('version');
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

% a signal is valid if it has the following fields and classes:
%    .data  - double
%    .Fs    - double
    
    valid = 1;   % assume valid on input
    struc = varargin{1};
    
    % first test to see if struc can be added to structure array;
    % if successful, fields are same and in same order
    [err,errstr,vanillaStruc]=importsig('make',{1 1 1});
    eval('vanillaStruc(2)=struc;','valid=0;')
    
    % now assuming the fields are all there, test their contents
    % for validity:
    if valid
        valid = isequal(class(struc.data),'double');
    end
    if valid
        valid = isequal(class(struc.Fs),'double');
    end
        
    if valid
        struc = importsig('assignType',struc);
    end
    
    varargout = {valid,struc};
    return

case 'assignType'
% struc = import*('assignType',struc)

  struc = varargin{1};
  [m,n]=size(struc.data);
  if min(m,n)>1
      struc.type = 'array';
  else
      struc.type = 'vector';
      struc.data = struc.data(:);
  end
  varargout{1} = struc;

%----------------------------------------------------------------------------
%     struct = importsig('changeFs',struct,Fs) - change the sampling frequency
%             of struct
case 'changeFs'
    struc = varargin{1};
    newFs = varargin{2};
    oldFs = struc.Fs;
    struc.Fs = newFs;
    varargout{1} = struc;
    
%----------------------------------------------------------------------------
%     newstruct = importsig('merge',struct1,struct2) - merge struct1 and struct2
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
        
        if ~isempty(newstruct.lineinfo)  & ...
             ( newstruct.lineinfo.columns(end) > size(newstruct.data,2) )
            newstruct.lineinfo.columns = 1;
        end
    end
    
    varargout{1} = newstruct;
    
end
