% MS2TH  �W���I��ԋ�ԃ��f���\������ THETA �t�H�[�}�b�g���쐬
% 
%          THETA = MS2TH(MS, CD, PARVAL, LAMBDA, T)
%
%   THETA   : THETA �t�H�[�}�b�g�́A���ʂ̍s��(HELP THETA �Q��)
%   MS      : ���f���\���B���R�p�����[�^�ƌŒ�p�����[�^���`�����ԋ�
%             �ԍs��W�����w�肵�܂�(MODSTRUC, CANFORM �Ő������܂�)�B
%   CD�@�@�@: �A�����ԃ��f���ɑ΂��āACD = 'c'�B���U���ԃ��f���ɑ΂��āA
%              CD = 'd' (�f�t�H���g�́ACD = 'd')
%             
%             �A�����ԃ��f���ɑ΂��āA2�̃I�v�V����������܂��B
%             CD = 'czoh'(�f�t�H���g)�́A�T���v����(u(t) = u(kT), kT<= 
%             t <kT+T)�ɂ����āA���͂��敪�I�Ɉ��ł��邱�Ƃ����肳��A
%             CD = 'cfoh'�́A�T���v���Ԃœ��͂��敪�I�ɐ��`�ł��邱�Ƃ�
%             ���肳��܂�(u(t) �́A�T���v���l�̐��`��Ԃŋ��߂��܂�)�B
%             (CSTB �� c2dm �� 'foh' �Ƃ͈قȂ�A���̏ꍇ�A�x�ꂪ�Ȃ���
%             �Ƃɒ��ӂ��Ă��������B)
%
%   PARVAL  : ���R�p�����[�^�̒l(�f�t�H���g�̓[��)
%   LAMBDA  : �C�m�x�[�V�����̋����U�s��(�f�t�H���g�͒P�ʍs��)
%   T       : �T���v�����O����(�f�t�H���g��1)�B�A�����ԃ��f���ɑ΂��ẮA
%             pem �Ő���ɗ��p�����f�[�^�̃T���v���Ԋu�ł��B
%
%   �Q�l:    ARX2TH, MF2TH, PEM, THETA.

%   Copyright 1986-2001 The MathWorks, Inc.
