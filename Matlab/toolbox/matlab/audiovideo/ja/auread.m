% AUREAD   NeXT/SUN (".au")�����t�@�C���̓ǂݍ���
% 
% Y = AUREAD(AUFILE)�́A������AUFILE�Ŏw�肳��鉹���t�@�C�������[�h���A
% ���ʂ̃T���v���f�[�^��y�ɏo�͂��܂��B�g���q��ݒ肵�Ă��Ȃ��ꍇ�A".au"
% ���t���܂��B�U���l�́A[-1,+1]�͈̔͂ŕ\�킳��܂��B���̌`���̃}���`
% �`�����l���f�[�^���T�|�[�g���܂��B8-�r�b�g mu-���A8�A16�A32�r�b�g���`�A����
% �����_��
%
% [Y,Fs,BITS] = AUREAD(AUFILE)�́A�w���c�P�ʂ̃T���v�����O���[�g(Fs)�ƃt
% �@�C�����̃f�[�^�𕄍������邽�߂Ɏg���T���v���ɑ΂���r�b�g��(BITS)��
% �o�͂��܂��B
%
% [...]  = AUREAD(AUFILE,N)�́A�t�@�C���̒��̊e�`�����l������A�ŏ���N�T
% ���v���݂̂��o�͂��܂��B
% 
% [...] = AUREAD(AUFILE,[N1 N2])�́A�t�@�C���̒��̊e�`�����l������N1����
% N2�܂ł̃T���v���݂̂����o���܂��B
% 
% SIZ  = AUREAD(AUFILE,'size')�́A���ۂ̃I�[�f�B�I�f�[�^�̑���ɁA�t�@
% �C���Ɋ܂܂��I�[�f�B�I�f�[�^�̑傫�����o�͂��܂��B���ʂ́A�x�N�g�� 
% SIZ = [samples channels]�ɂȂ�܂��B
%
% �Q�l�FAUWRITE, WAVREAD.

% Copyright 1984-2004 The MathWorks, Inc. 
