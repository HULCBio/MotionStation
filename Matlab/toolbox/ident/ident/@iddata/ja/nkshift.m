% NKSHIFT �́A�f�[�^���V�t�g���܂��B
%
%   DATSHIFT = NKSHIFT(DATA,NK)
%   
%   DATA: IDDATA �I�u�W�F�N�g
%   NK: �T���v���P�ʂ̃V�t�g�ʁB���̃V�t�g�A���̃V�t�g���ɁA�ǂ�����g�p
%       �ł��܂��B
%       ���͐��Ɠ����v�f�������s�x�N�g���ł��B
%       ���̒l nk �́A���͂̒x����Ӗ����܂��B
%   DATSHIFT: nk(ku) �X�e�b�v�V�t�g�������� ku ������ IDDATA �I�u�W�F�N�g
% 
% NKSHIFT �́AIDMODEL �� InputDelay �v���p�e�B���g�������̂ł��B
% m1 = pem(dat,4,'InputDelay',nk) �́Am2 = pem(nkshift(dat,nk),4) �Ɠ���
% ���f���ł����AM1 �͎��g���������v�Z����ꍇ�ɗ��p�����x�����������
% ���܂��B
%
% MODEL �v���p�e�B NK �ƈقȂ邱�Ƃɒ��ӂ��Ă��������B
% m3 = pem(dat,4,'nk',nk) �́Ank �T���v���̒x����܂ރ��f���ł��B
% 
% Dat1 = NKSHIFT(Dat,NK,'append') �́A���͐M���Ƀ[����ǉ����邱�Ƃɂ��A
% Dat �Ɠ���������Dat1 ���쐬���܂��B
%
% NK �������̐��Ɠ����������̃Z���z��̏ꍇ�A�قȂ�x�ꂪ�e�X�Ή��������
% �ɓK�p����܂��B





%   Copyright 1986-2001 The MathWorks, Inc.
