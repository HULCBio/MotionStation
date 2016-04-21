function vrrecordcallback(fig, str)
%VRRECORDCALLBACK Recording callback function.
%   Called from VR figure to handle AVI recording.
%
%   VRRECORDCALLBACK(F, 'start') prepares AVI recording for figure F.
%   VRRECORDCALLBACK(F, 'frame') stores a frame for figure F.
%   VRRECORDCALLBACK(F, 'stop') stops AVI recording and stores the file.
%
%   Not to be used directly.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/03/02 03:08:29 $ $Author: batserve $

persistent vr_rec_aviobj;



% prepare the AVI recording
if strcmpi(str, 'start')

  % generate the filename for the .AVI file from template and world filename
  ftmpl = get(fig, 'Record2DFileName');
  wfile = get(get(fig, 'World'), 'FileName');
  file = vrsfunc('GenerateFile', ftmpl, wfile);
  if isempty(file)
    warning('VR:cantopenfile', 'Can''t open AVI file, recording suppressed.');
    vr_rec_aviobj = [];
    return
  end

  % determine the AVI codec and quality to use
  cmethod = get(fig, 'Record2DCompressMethod');
  if (strcmpi(cmethod, 'auto'))
    if ispc
      cmethod = 'Indeo5';
    else
      
      % compression is not yet supported for non-PC architectures
      cmethod = 'None';
    end
  elseif (strcmpi(cmethod, 'auto_lossless'))
    cmethod = 'None';
  end
  cqual = get(fig, 'Record2DCompressQuality');
  
  % create the AVI file
  vr_rec_aviobj = avifile(file, 'Compression', cmethod, 'Quality', cqual);



% record a frame
elseif strcmpi(str, 'frame')

  % do nothing if recording object is not available
  if isempty(vr_rec_aviobj)
    return
  end
  
  % capture the scene shot and store it to the AVI file
  vr_rec_aviobj = addframe(vr_rec_aviobj, capture(fig));



% finish AVI recording and save the file
elseif strcmpi(str, 'stop')

  % do nothing if recording object is not available
  if isempty(vr_rec_aviobj)
    return
  end

  % close the AVI file, saving it
  vr_rec_aviobj = close(vr_rec_aviobj);
  clear vr_rec_aviobj;


% any other command is invalid
else
  error('VR:badcommand', ['Unrecognized command ''' str '''.']);
end
