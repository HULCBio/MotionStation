%function pert = randel(blk,nrm,opt)
%
% �w�肵���m�������������_���ȃu���b�N�\�����ۓ�(���Ȃ킿�A�ő���ْl)
% ���쐬���܂��B�u���b�N�\���͈���BLK�ɂ���Ďw�肳��A�m�����͈���NRM��
% ����Ďw�肳��܂��B
%
% ���f�u���b�N�ł́A�m������NRM�Ɠ������A�����u���b�N�́A���̂悤�Ɏw
% �肳�ꂽ�m�����������܂�(�f�t�H���g��'i'�ł�)�B
%
% opt = 'i'�̏ꍇ�A�����u���b�N��NRM�ȉ��̃m�����������܂��Bopt = 'b'��
% �ꍇ�A�����u���b�N��NRM�Ɠ������m�����������܂��B
%
% �Q�l: CRAND, DYPERT, SYSRAND.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
