function varargout = hdf(varargin)
%HDF MATLAB-HDF gateway function.
%   HDF is a MEX-file interface to the HDF library developed and
%   supported by the National Center for Supercomputing
%   Applications.
%
%   Documentation is available via the NCSA HDF Home Page at
%   http://hdf.ncsa.uiuc.edu.
%
%   Currently HDF supports all or a portion of the following HDF
%   interfaces: SD, V, VS, VF, VH, AN, DFR8, DF24, H, HE, HL, and
%   HD.  In addition, a MathWorks-specific ML interface contains
%   a few utilities for managing the gateway.
%
%   Functions are also available for the HDF-EOS interfaces
%   GD, PT, and SW.  These functions are called HDFGD,
%   HDFPT, and HDFSW, respectively.
%
%   You should not use this function directly.  Instead, use the
%   functions that are interface specific.  For example, to
%   access an HDF function in the SD interface, use HDFSD.
%
%   See also HDFTOOL, HDFINFO, HDFREAD, HDFAN, HDFDF24,
%            HDFDFR8, HDFH, HDFHD, HDFHE, HDFML, HDFSD, 
%            HDFV, HDFVF, HDFVH, HDFVS, HDFGD, HDFPT, HDFSW.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:54 $
%#mex

error('MATLAB:hdf:missingMEX', 'Missing MEX-file HDF');
