% ARMAX	   �\���덷�@�ɂ�� ARMAX ���f���̐���
%
%   M = ARMAX(Z,[na nb nc nk])  
%   M = ARMAX(Z,'na',na,'nb',nb,'nc',nc,'nk',nk)
%
%   M : ���肳�ꂽ�����U�ƍ\���̏��Ƌ��ɁAIDPOLY �I�u�W�F�N�g�t�H�[�}
%       �b�g�ŁA���肵�����f���o�́BM �̐��m�ȃt�H�[�}�b�g�́Ahelp IDP-
%       OLY ���Q�Ƃ��Ă��������B
%
%   Z : IDDATA �I�u�W�F�N�g�t�H�[�}�b�g�ŋL�q���ꂽ����Ɏg�p����f�[�^
%       �ڍׂ́AIDDATA ���Q�ƁB
%
%   [na nb nc nk] �́AARMAX ���f���̎����ƒx��ł��B
%
%	   A(q) y(t) = B(q) u(t-nk) + C(q) e(t)
%
% �����̓f�[�^�̏ꍇ�Anb��nk�͓��̓`���l�����Ɠ��������̍s�x�N�g���ł��B
%
% �ʂ̕\���Ƃ��āAM = ARMAX(Z,Mi) ���g�����Ƃ��ł��܂��B�����ŁAMi �́A
% ���肳�ꂽ���f���A�܂��́AIDPOLY �ō쐬���ꂽ���f���̂ǂ��炩�ł��B��
% �����́AMi �ŗ^����ꂽ�p�����[�^�ŏ���������܂��B
%
% M = ARMAX(Z,nn,Property_1,Value_1, ...., Property_n,Value_n) ���g���āA
% ���f���\���ƃA���S���Y���Ɋ֘A�������ׂẴv���p�e�B��ݒ�ł��܂��B�v
% ���p�e�B��/�l�̈ꗗ�ɂ��ẮAHELP IDPOLY�A�܂��́AIDPROPS ALGORITHM 
% ���Q�Ƃ��Ă��������B



%   Copyright 1986-2001 The MathWorks, Inc.
