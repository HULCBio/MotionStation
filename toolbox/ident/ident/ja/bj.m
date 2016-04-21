% BJ �\���덷�@�ɂ�� Box -Jenkins ���f���̐���
%
%   M = BJ(Z,[nb nc nd nf nk])�A�܂��́A
%   M = BJ(Z,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk) 
%       (�ȗ����������̓[���Ƃ݂Ȃ���A�����̏��Ԃ́A�C�ӂł�)
%
%   M : ���肵�������U�ƍ\�������܂�ŁAIDPOLY �I�u�W�F�N�g�̌^�ŕ\��
%       �����肵�����f���Ƃ��ďo�͂��܂��BM �̏ڍׂȃt�H�[�}�b�g�́Ahelp
%       IDPOLY ���Q�Ƃ��Ă��������B
%
%   Z : IDDATA �I�u�W�F�N�g�ŕ\�������f������Ɏg�p����f�[�^�A�ڍׂ� 
%       HELP IDDATA ���Q�Ƃ��Ă��������B
%
% [nb nc nd nf nk] �́A���̂悤�ɕ\����� Box-Jenkins ���f���̎����ƒx
% ���\���܂��B
%
% 	    y(t) = [B(q)/F(q)] u(t-nk) +  [C(q)/D(q)]e(t)
%
% �ʂ̕\���Ƃ��āAM = BJ(Z,Mi) ���g�����Ƃ��ł��܂��B�����ŁAMi �́AID-
% POLY �ō쐬���ꂽ���f���A�܂��́A���肳�ꂽ���f���̂����ꂩ�ł��B
% �ŏ����́AMi �Őݒ肳�ꂽ�p�����[�^�ŏ���������܂��B
%
% M = BJ(Z,nn,Property_1,Value_1, ...., Property_n,Value_n) ���g���āA��
% �f���\���ƃA���S���Y���Ɋ֘A�������ׂẴv���p�e�B��ݒ�ł��܂��B�v��
% �p�e�B��/�l�̈ꗗ�ɂ��ẮAHELP IDPOLY�A�܂��́AIDPROPS ALGORITHM ��
% �Q�Ƃ��Ă��������B



%   Copyright 1986-2001 The MathWorks, Inc.
