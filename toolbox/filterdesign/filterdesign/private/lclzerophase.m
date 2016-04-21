function [h,w] = lclzerophase(varargin)
%LCLZEROPHASE   Locla zerophase that deletes warning.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:15:31 $

[lastm, lasti] = lastwarn;
warn=warning('off','signal:zerophase:syntaxChanged');
[h,w] = zerophase(varargin{:});
warning(warn);
lastwarn(lastm, lasti);

% [EOF]
