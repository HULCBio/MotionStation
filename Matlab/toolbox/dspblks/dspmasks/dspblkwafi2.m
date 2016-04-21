function varargout = dspblkwafi2(action,varargin)
% DSPBLKWAFI2 Wave Audio File Input block helper function.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/12/23 22:30:21 $

sys = bdroot;
blk = gcb;
if nargin==0, action='dynamic'; end

switch action
case 'init'
   % Setup default values:
   samples=1;nchans=1;fs=1;bits=1;bps=1;
   mode = '';
   err = '';
   
   % Append WAV extension if no extension specified:
   fName = deblank(get_param(blk,'FileName'));
   [p,n,e] = fileparts(fName);
   if isempty(e),
      e = '.wav';
      fName = [fName e];
   end

   % prepend the full path to the file - why?
   % the m-file code (eg, this file) can find the wav file if it
   % is simply on the MATLAB path.  That's great.  However, the
   % S-Function itself wants to open the file for reading, and it
   % does *not* consult the MATLAB path.  If you're not in the
   % directory (and the full path is not specified in the block dialog),
   % then the S-Function will fail to find the file.
   % If a full path was specified in the mask, then we don't want to 
   % use WHICH, because it will nullify the fName when the 
   % specified path is not in the MATLAB path.
   %
   % So, we simply get the full path to the file,
   % ONLY if the name was specified without a path:
   if isempty(p)
       fName = which(fName);
   end
   
   % Name for display:
   % - don't show path
   % - show the file extension no matter what
   dName = [n e];
   
   % Get file parameters:
   try
      [siz,fs,bits,opts] = wavread(fName,'size');
      nchans  = siz(2);
      mode    = ['(' num2str(fs) 'Hz/' num2str(nchans) 'Ch/' num2str(bits) 'b)'];
   catch
      err = lasterr;
   end
   
   outputFirstSample = int32(strcmp(get_param(blk,'firstSampleOutput'), 'on'));
   outputLastSample = int32(strcmp(get_param(blk, 'lastSampleOutput'), 'on'));
   
   portLabels = [];
   
   i = 1;
   portLabels(i).port = i;
   portLabels(i).txt = 'Out';
   
   if outputFirstSample == 1,
       i=i+1;
       portLabels(i).port = i;
       portLabels(i).txt = 'First';
   end
   
   if outputLastSample == 1,
       i=i+1;
       portLabels(i).port = i;
       portLabels(i).txt = 'Last';
   end

   for j=i+1:3, portLabels(j) = portLabels(i); end
   
   varargout = {fName,dName,fs,nchans,mode,err,bits,outputFirstSample,outputLastSample,portLabels};
   
case 'icon'
   % Icon drawing
   varargout = {};
   
case 'dynamic'
    % updating things in the mask based on button clicks, etc.
    loopOrNot  = strcmp(get_param(blk,'bLoop'),'on');
    orig_ena   = get_param(blk,'maskenables');
    new_ena    = orig_ena;
    
    if loopOrNot,
        enaLoopNTimes = 'on';
        enaLoopMode   = 'on';
    else
        enaLoopNTimes = 'off';
        enaLoopMode   = 'off';
    end
    
    new_ena{6} = enaLoopNTimes;
    new_ena{7} = enaLoopMode;
    if ~isequal(orig_ena, new_ena),
        set_param(blk,'maskenables',new_ena);
    end
    
otherwise,
   error('Unknown action specified');
end

% [EOF] dspblkwafi2.m
