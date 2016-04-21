function refresh(this,Mask)
%REFRESH  Adjusts visibility of @waveform's HG components.
%
%  REFRESH(WF,Mask) updates the visibility of the graphical 
%  components making up the waveform WF (low-level HG objects).  
%  The optional argument MASK  specifies the visibility of each 
%  data cell (see REFRESHMASK for details).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:17 $

% Visibility mask (relative to the full axes grid)
if strcmp(this.Visible,'off')
   Mask = false;
elseif nargin==1
   Mask = refreshmask(this);
else
   % Extract mask for waveform's subgrid from supplied mask
   Mask = Mask(this.RowIndex,this.ColumnIndex,:,:);
end

% Update visibility of resp. view objects
% RE: Effective visibility of waveform curves is function of data cell 
%     visibility (Mask) and View visibility (factored in by REFRESH)
for ct = 1:length(this.View)
   this.View(ct).refresh(Mask)
end

% Update visibility of "wave characteristics" views
% REVISIT: next line should work when this.Characteristics initialized to handle(0,1)
% for c = find(this.Characteristics,'Visible','on')'
for c = this.Characteristics(strcmp(get(this.Characteristics,'Visible'),'on'))'
   refresh(c,Mask)
end

