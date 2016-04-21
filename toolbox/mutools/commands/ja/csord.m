% function [v,t,flgout,reig_min,epkgdif] = .....
%                     csord(a,epp,flgord,flgjw,flgeig)
%
% ���̊֐��́A�����t����ꂽ���fSchur�s��T���쐬���܂��B�����ŁA
%            v' * a * v  = t = |t11  t12|
%                              | 0   t22|
% �ł���AV'V = eye()�ł��B
% MATLAB�֐�SCHUR���Ăяo����܂��B����́A�����t�����Ă��Ȃ�Schur�^�s
% ����쐬���܂��B�T�u���[�`��CGIVENS�ɂ��A���fGivens��]�s����쐬���A
% ���[�U����`�������@��T�s�����ׂ܂��B���̓t���O�́A���̂悤�ɐݒ�
% ���܂��B
%
% EPP           ���[�U���ݒ肷��[���̔���(�f�t�H���g EPP=1e-9)
% FLGORD = 0    �ŗL�l�̎���������������悤�ɏo��(�f�t�H���g)
%        = 1    �ŗL�l�̎��������A�[���A���̏��ɏo��
% FLGJW  = 0    �ŗL�l�̈ʒu�Ɋւ���I�������͂���܂���(�f�t�H���g)�B
%        = 1    jw����ɌŗL�l�����݂���ΏI��(JWHAMTST���Q��)
% FLGEIG = 0    �����ʏ�ł̌ŗL�l�Ɋւ���I�������͂���܂���
%               (�f�t�H���g)�B
%        = 1    length(real(eigenvalue)>0) ~= length(real(eigenvalue)<0)
%               �̏ꍇ�A�I��
%
% �o�̓t���OFLGOUT�́A�ʏ�0�ł��B�ŗL�l��jw����ɂ���΁AFLGOUT��1�ɐݒ�
% ����܂��B���̌ŗL�l�̐��ƕ��̌ŗL�l�̐����قȂ�ꍇ�AFLGOUT��2�ɐݒ�
% ����܂��B���������ɖ��������ꍇ�́AFLGOUT ��3�ł��B�ŗL�l�̍ŏ�����
% �́AREIG_MIN�ɏo�͂���܂��BEPKGDIF�́A2�̈قȂ�jw���̃e�X�g�̔�r��
% ���B
%
% �Q�l: RIC_SCHR, SCHUR, RSF2CSF.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
