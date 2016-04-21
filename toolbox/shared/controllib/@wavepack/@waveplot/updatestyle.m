function updatestyle(this,varargin)
%UPDATESTYLE  Updates wave styles when style preferences change.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:43 $

% RE: PostSet listener for @stylemanager's list of styles (Styles property)
Styles = this.StyleManager.Styles;
Nr = length(this.Waves);
Ns = length(Styles);
for ct=1:Nr
   this.Waves(ct).applystyle(Styles(1+rem(ct-1,Ns)))
end