function outName = rtw_cgt_name_conv(inName,direction)
% RTW automatically converts .cgt files to .tlc file.  The convension
% is file.cgt converts to file_cgt.tlc.  This function perfoms the
% necessary convertion in either direction: 'tlc2cgt' and 'cgt2tlc'.
%
% A conversion is not performed if it does not match the convension.
% For example, rt_cgt_name_conv('foo.tlc','cgt2tlc') returns foo.tlc.
%
% Args:
%   inName    - File name to convert
%   direction - 'tlc2cgt' or 'cgt2tlc'
%
% Returns:
%   outName   - Converted file name

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
  
  [path,file,ext] = fileparts(inName);

  if isequal(direction,'cgt2tlc')
    if isequal(ext,'.cgt')
      outName = fullfile(path,[file,'_cgt.tlc']);
    else
      outName = inName;
    end
  elseif isequal(direction,'tlc2cgt')
    if isequal(ext,'.tlc')
      file = regexprep(file,'_cgt$', '');
      outName = fullfile(path,[file,'.cgt']);
    else
      outName = inName;
    end
  else
    error(['Unrecognized second arguement: ', direction])
  end
    
  