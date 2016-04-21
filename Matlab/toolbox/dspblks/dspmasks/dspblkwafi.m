function varargout = dspblkwafi(action,varargin)
% DSPBLKWAFI Wave Audio File Input block helper function.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 20:56:38 $

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
   
   % Name for display:
   % - don't show path
   % - display extension only if it is not '.wav'
   if strcmp(e,'.wav'),
      dName = n;
   else
      dName = [n e];
   end
   
   % Get file parameters:
   try 
      [siz,fs,bits,opts] = wavread(fName,'size');
      nchans  = siz(2);
      mode    = ['(' num2str(fs) 'Hz/' num2str(nchans) 'Ch/' num2str(bits) 'b)'];
   catch
      err = lasterr;
   end
   
   varargout = {fName,dName,fs,nchans,mode,err};
   
case 'icon'
   % Icon drawing
   varargout = {};
   
otherwise,
   error('Unknown action specified');
end

% [EOF] dspblkwafi.m
