% WPDEC2 �@2�����E�F�[�u���b�g�p�P�b�g����
% [T,D] = WPDEC2(X,N,'wname',E,P) �́A'wname' �ɂ��ݒ肳�ꂽ(WFILTERS �Q��)��
% ��̃E�F�[�u���b�g��p�������x�� N �ł̍s�� X �̃E�F�[�u���b�g�p�P�b�g�č\����
% �Ή�����c���[�\�� T �ƃf�[�^�\�� D (MAKETREE�Q��)���o�͂��܂��B
% 
% E �́A�G���g���s�[�̃^�C�v������������ł�(WENTROPY �Q��)�B
% E = 'shannon'�A'threshold'�A'norm'�A'log energy'�A'sure'�A'user'
% P �́A�I�v�V�����p�����[�^�ł��B
% E �̒l���A
%  'shannon'�A�܂��́A'log energy' �̂Ƃ��́AP �͗p�����܂���B
%  'threshold'�A�܂��́A'sure' �̂Ƃ��́AP �̓X���b�V���z�[���h�l�ł�(0 < =  P)�B
%  'norm' �̂Ƃ��́AP �ׂ͂����ł�(1 < =  P < 2)�B
%  'user' �̂Ƃ��́AP �̓��[�U����`�����֐��̖��O������������ł��B
%
% [T,D] = WPDEC2(X,N,'wname') �́A[T,D] = WPDEC2(X,N,'wname','shannon') �Ɠ�����
% ���B
%
% �Q�l�F MAKETREE, WAVEINFO, WDATAMGR,  WENTROPY
%        WPDEC, WTREEMGR.



%   Copyright 1995-2002 The MathWorks, Inc.
