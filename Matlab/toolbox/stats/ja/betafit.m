% BETAFIT   �x�[�^���z���Ă���f�[�^�ɑ΂���p�����[�^����ƐM����Ԃ��Z�o
%
% BETAFIT(X) �́A�x�N�g�� X �Őݒ肳�ꂽ�f�[�^��^���A�x�[�^���z�̃p�����[�^
% �̍Ŗސ�����o�͂��܂��B
% 
% [PHAT, PCI] = BETAFIT(X,ALPHA) �́A�f�[�^��^���āAMLE �� 100(1-ALPHA) %
% �̐M����Ԃ��o�͂��܂��B�f�t�H���g�ł́A�I�v�V�����̃p�����[�^ 
% ALPHA = 0.05 �ŁA95% �̐M����ԂɑΉ����܂��B
% 
% ���̊֐��́A���ׂĂ� X ��0�ȏ�A1�ȉ��ł��邱�Ƃ�K�v�Ƃ��܂��B���̂悤��
% �����𖞂����f�[�^�ł̋ߎ��́A���̃X�e�[�g�����g�ŁA���s�ł��܂��B
% 
%         BETAFIT(X(X>0 & X<1))
% 
% �f�[�^�l���A���x 1e-6 �͈̔͂ŁA0�܂���1�ɓ������ꍇ�A���̃X�e�[�g�����g
% �ŁA�ۂ߂�K�p�����f�[�^�ŋߎ������s���܂��B
% 
% �@      BETAFIT(MAX(1e-6, MIN(1-1e-6,X)))
% 
% �Q�l : BETACDF, BETAINV, BETAPDF, BETARND, BETASTAT, MLE. 


%   ZP. You, 3-13-99, B.A. Jones 1-27-95
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:09:03 $
