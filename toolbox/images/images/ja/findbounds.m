% FINDBOUNDS ��ԓI�ȕϊ��ɑ΂���o�͈͂̔͂����o
% OUTBOUNDS = FINDBOUNDS(TFORM,INBOUNDS) �́A�^����ꂽ��ԓI�ȕϊ��Ɠ�
% �͈͂̔͂ɑΉ�����o�͈͂̔͂𐄒肵�܂��BTFORM �́AMAKEFORM �� CP2-
% TFORM �Ŗ߂�����ԓI�ȕϊ��̍\���̂ł��BINBOUNDS �́A2�s NUM_DIMS 
% ��̍s��ł��BINBOUNDS �̍ŏ��̍s�͊e�����̉������A2�Ԗڂ̍s��͏�
% ���������܂��BNUM_DIMS �́ATFORM ��ndims_in �t�B�[���h�Ɛ�������ۂ���
% ���܂��B
%
% OUTBOUNDS �́AINBOUNDS �Ɠ����^�����Ă��܂��B����́A���͈͂̔͂ɂ��
% �\�������ϊ����ꂽ�����`�����S�Ɋ܂ޒ��ŁA�ł������������`�𐄒肵
% �܂��BOUTBOUNDS �́A��̐���ł���̂ŁA�ϊ����ꂽ���͒����`�����S
% �Ɋ܂�ł��Ȃ��ꍇ������܂��B
%
% ����
% -----
% IMTRANSFORM �́A���[�U���^���Ȃ��ꍇ�AFINDBOUNDS ���g���āA'Output-
% Bounds'�p�����[�^���v�Z���܂��B
%
% TFORM ���A�t�H���[�h�ϊ����܂�ł���ꍇ(forward_fcn�t�B�[���h����łȂ�
% �ꍇ)�AFINDBOUNDS �́A���͈͂̔͂�\�킷�����`�̒��_��ϊ����邱�ƂŁA
% �@�\���A���̌��ʂ̍ő�l�ƍŏ��l�����߂܂��B
%
% TFORM ���A�t�H���[�h�ϊ����܂܂Ȃ��ꍇ�AFINDBOUNDS �́ANeider-Mead ��
% �K���֐� FMINSEARCH ���g���āA�o�͈͂̔͂����߂Ă��܂��B�œK���̕��@
% �����܂������ł��Ȃ��ꍇ�AFINDBOUNDS �́A���[�j���O��\�킵�AOUT-
% BOUNDS = INBOUNDS ��߂��܂��B
%
% ���
% -------
%       inbounds = [0 0; 1 1]
%       tform = maketform('affine',[2 0 0; .5 3 0; 0 0 1])
%       outbounds = findbounds(tform, inbounds)
%
% �Q�l�FCP2TFORM, IMTRANSFORM, MAKETFORM, TFORMARRAY, TFORMFWD, TFORMINV.



%   Copyright 1993-2002 The MathWorks, Inc.
