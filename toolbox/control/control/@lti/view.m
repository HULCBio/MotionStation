function [ViewFig,ViewObj] = view(varargin)
%VIEW  View LTI system responses.
%
%   VIEW(SYS1,SYS2,...,SYSN) opens an LTI Viewer containing the step
%   response of the LTI models SYS1,SYS2,...,SYSN.  You can specify a
%   distinctive color, line style, and marker for each system, as in
%      sys1 = rss(3,2,2);
%      sys2 = rss(4,2,2);
%      view(sys1,'r-*',sys2,'m--');
%
%   VIEW(PLOTTYPE,SYS1,SYS2,...,SYSN) further specifies which responses 
%   to plot in the LTI Viewer.  PLOTTYPE may be any of the following strings 
%   (or a combination thereof):
%      'step'           Step response
%      'impulse'        Impulse response
%      'bode'           Bode diagram
%      'bodemag'        Bode magnitude diagram
%      'nyquist'        Nyquist plot
%      'nichols'        Nichols plot
%      'sigma'          Singular value plot
%      'pzmap'          Pole/zero map
%      'iopzmap'        Pole/zero map for each I/O pair
%   For example, 
%      view({'step';'bode'},sys1,sys2)
%   opens an LTI Viewer showing the step and Bode responses of the LTI 
%   models SYS1 and SYS2.
%   
%   VIEW(PLOTTYPE,SYS,EXTRAS) allows you to specify the additional 
%   input arguments supported by the various response types.
%   See the HELP text for each response type for more details on the 
%   format of these extra arguments.  You can also use this syntax 
%   to plot the output of LSIM or INITIAL in the LTI Viewer, as in
%      view('lsim',sys1,sys2,u,t,x0)
%
%   See also LTIVIEW, STEP, IMPULSE, LSIM, INITIAL, (IO)PZMAP,
%            BODE(MAG), NYQUIST, NICHOLS, SIGMA. 

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2002/11/11 22:21:53 $
[hfig,ViewObj] = ltiview(varargin{:});
if nargout
   ViewFig = hfig;
end