%function [delta,lowerbnd,upperbnd] = wcperf(Mg,blk,pertsizew,npts)
%
%
% ���`�����ϊ��̏㑤�̃��[�v�ɑ΂��āA�ň��P�[�X�̐��\���v�Z���܂��B
%       
%   ����  : MG        - ���͍s��ACONSTANT/VARYING
%           BLK       - �u���b�N�\��
%           PERTSIZEW - ��̃T�C�Y
%	    NPTS      - ��_�̐� (�f�t�H���g�� 1)
%
%  �o��   : DELTA     - �ň��̏
%           LOWERBND  - ��̉��E 
%           UPPERBND  - ��̏�E 
%
% �Q�l�F MU, DYPERT



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
