% RPMAK   rp�^�̗L���X�v���C���̑g����
%
% RPMAK(BREAKS,COEFS), RPMAK(BREAKS,COEFS,D), RPMAK(BREAKS,COEFS,SIZEC) 
% �͂��ׂāA3�Ԗڂ̓��͈��������݂��邩�ǂ����ŉ��߂��ꂽ COEFS �𔺂���
% ���͂ɂ���Ďw�肳�ꂽ�L���X�v���C����rp-�^���o�͂��܂��B
%
% �L���X�v���C����rp-�^�Ƃ��ĕW������邱�ƁA���Ȃ킿�A���ꂪ�X�v���C��
% �̍ŏI�v�f�ɂ���ė^�����A���q���c��v�f�ŋL�q�����悤�ȗL���X�v
% ���C���ł��邱�Ƃ������āA����́A������ RPMAK(BREAKS,COEFS), 
% RPMAK(BREAKS,COEFS,D+1), RPMAK(BREAKS,COEFS,SIZEC) �̏o�͂ł��B
%
% ���ɁA���͂̌W���́A�����炩�� d>0 �ɑ΂���(d+1)�v�f�̃x�N�g���l��
% �Ȃ���΂Ȃ炸�AN�����̒l�����������̂ɂ͂Ȃ�܂���B
%
% �Ⴆ�΁Appmak([-5 5],[1 -10 26]) �́A��� [-5 .. 5] �ő����� t |-> t^2+1 
% ��pp-�^��^�������Appmak([-5 5], [0 0 1]) �́A2���̑����� t |-> 1 ��
% pp-�^��^���܂��B�����ŁA�R�}���h
%
%      runge = rpmak([-5 5],[0 0 1; 1 -10 26],1);
%
% �́A���Ԋu�̃T�C�g�ł̑������̕�ԂɊւ���Runge�̗��ŗL���ȗL���֐� 
% t |-> 1/(t^2+1) �ɑ΂����� [-5 .. 5] �ł�rp-�^��^���܂��B
%
% �Q�l : RPBRK, RSMAK, PPMAK, SPMAK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
