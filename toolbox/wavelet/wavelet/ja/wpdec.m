% WPDEC �@1�����E�F�[�u���b�g�p�P�b�g����
% [T,D] = WPDEC(X,N,'wname',E,P) �́A����̃E�F�[�u���b�g('wname'�AWFILTERS�Q��)
% �Ń��x�� N �ɑ΂���x�N�g�� X �̃E�F�[�u���b�g�p�P�b�g�������s�����Ƃ��ɑΉ���
% ��c���[�\�� T �ƃf�[�^�\�� D (MAKETREE�Q��)���o�͂��܂��B
% 
% E �́A�G���g���s�[�̃^�C�v������������ł�(WENTROPY�Q��)�B
%   E = 'shannon'�A'threshold'�A'norm'�A'log energy'�A'user'
% 
% P �́A�I�v�V�����p�����[�^�ł��B
% E �̒l��
%  'shannon'�A�܂��́A'log energy' �̂Ƃ��́AP �͗p�����܂���B
%  'threshold'�A�܂��́A'sure' �̂Ƃ��́AP �̓X���b�V���z�[���h�l�ł�(0 < =  P)�B
%  'norm' �̂Ƃ��́AP �ׂ͂����ł�(1 < =  P < 2)�B
%  'user' �̂Ƃ��́AP �̓��[�U����`�����֐��̖��O������������ł��B
%
% [T,D] = WPDEC(X,N,'wname') �́A[T,D] = WPDEC(X,N,'wname','shannon') �Ɠ����ł��B
%
% �Q�l�F MAKETREE, WAVEINFO, WDATAMGR, WENTROPY
%        WPDEC2, WTREEMGR.



%   Copyright 1995-2002 The MathWorks, Inc.
