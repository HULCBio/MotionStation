% POLYCONF   �������̌v�Z�ƐM����Ԃ𐄒�
%
% p ���A���� n+1 �̃x�N�g���ŁA���̗v�f���������̌W���̏ꍇ�A
% y = POLYCONF(p,x) �́Ax �ł̑������̒l���v�Z���܂��B
% 
%    y = p(1)*x^n + p(2)*x^(n-1) + ... + p(n)*x + p(n+1)
% 
% X ���s��܂��̓x�N�g���̏ꍇ�A�������́AX �̒��̂��ׂĂ̗v�f�ɑ΂���
% �������̒l���v�Z���܂��B
% 
% [y,delta] = POLYCONF(p,x,S,alpha) �́A�֐� POLYFUT �ō쐬�����
% �I�v�V�����o�� S ���g���āA�M����� Y +/- DELTA ���쐬���܂��BPOLYFIT 
% �ւ̃f�[�^���͂̒��Ɋ܂܂��덷���A���̕��U�����Ɨ��Ȑ��K���z��
% �ꍇ�AY +/- DELTA �́A�����̗\���� 100(1-ALPHA)% ���܂�ł��܂��B
% ALPHA �̃f�t�H���g�l��0.05�ŁA95% �̐M����ԂɑΉ����܂��B


%   5-11-93 B.A. Jones
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:58 $
