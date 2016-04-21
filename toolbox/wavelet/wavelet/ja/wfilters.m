% WFILTERS�@ �E�F�[�u���b�g�t�B���^
% [LO_D,HI_D,LO_R,HI_R] = WFILTERS('wname') �́A������ 'wname' �ŗ^����ꂽ����
% �܂��͑o�����E�F�[�u���b�g�Ɋ֘A����4�̃t�B���^���v�Z���܂��B4�̏o�̓t�B��
% �^�́A�ȉ��̂Ƃ���ł��B
%     LO_D�A�������[�p�X�t�B���^
%     HI_D�A�����n�C�p�X�t�B���^
%     LO_R�A�č\�����[�p�X�t�B���^
%     HI_R�A�č\���n�C�p�X�t�B���^
% ���p�\�ȃE�F�[�u���b�g�� 'wname' �́A�ȉ��̂Ƃ���ł��B
%     Daubechies: 'db1'�A�܂��́A'haar'�A'db2'�A... ,'db45'
%     Coiflets  : 'coif1'�A... �A 'coif5'
%     Symlets   : 'sym2' �A... �A 'sym8'�A... ,'sym45'
%     Biorthogonal:
%         'bior1.1'�A'bior1.3' �A'bior1.5'
%         'bior2.2'�A'bior2.4' �A'bior2.6'�A'bior2.8'
%         'bior3.1'�A'bior3.3' �A'bior3.5'�A'bior3.7'
%         'bior3.9'�A'bior4.4' �A'bior5.5'�A'bior6.8'.
%     Reverse Biorthogonal: 
%         'rbio1.1'�A'rbio1.3' �A'rbio1.5'
%         'rbio2.2'�A'rbio2.4' �A'rbio2.6'�A'rbio2.8'
%         'rbio3.1'�A'rbio3.3' �A'rbio3.5'�A'rbio3.7'
%         'rbio3.9'�A'rbio4.4' �A'rbio5.5'�A'rbio6.8'.
%
% [F1,F2] = WFILTERS('wname','type') �́A���̃t�B���^���o�͂��܂��B
%   'type' = 'd' �̂Ƃ��ALO_D �y�� HI_D (�����t�B���^)
%   'type' = 'r' �̂Ƃ��ALO_R �y�� HI_R (�č\���t�B���^)
%   'type' = 'l' �̂Ƃ��ALO_D �y�� LO_R (���[�p�X�t�B���^)
%   'type' = 'h' �̂Ƃ��AHI_D �y�� HI_R (�n�C�p�X�t�B���^)
%
% �Q�l�F BIORFILT, ORTHFILT, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.
