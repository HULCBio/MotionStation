function c=crg_halt_gen(varargin)
%Stop Report Generation
%   This component stops the report from generating.  It acts
%   exactly the same as pressing the "stop" button during
%   generation.  This component is best used inside of an
%   "if/then" statement.
%
%   Note that when generation is halted, the SGML source file
%   is produced, but is not converted.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:57 $

%--------1---------2---------3---------4---------5---------6---------7---------8

c=rptgenutil('EmptyComponentStructure','crg_halt_gen');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
