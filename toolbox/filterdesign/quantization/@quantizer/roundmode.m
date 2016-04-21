function m = roundmode(q)
%ROUNDMODE  Round mode of a quantizer object.
%   ROUNDMODE(Q) returns the round mode of quantizer object Q.  The round mode
%   of a quantizer object can be one of the strings:
%
%     ceil       - Round towards plus infinity.
%     convergent - Like "round" except ties round to even numbers.
%     fix        - Round towards zero.
%     floor      - Round towards minus infinity.
%     round      - Round towards nearest.  Ties round up in absolute value. 
%
%   [M1, M2, ...] = ROUNDMODE(Q1, Q2, ...) returns the roundmodes of quantizer
%   objects Q1, Q2, ....
%
%   Example:
%     q = quantizer;
%     roundmode(q)
%   returns the default round mode 'floor'.
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/SET.

%   Thomas A. Bryan, 14 July 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:34:03 $

m = get(q,'roundmode');
