%  [sys,delta] = aff2lft(affsys)
%
% ���̕������ŕ\�������A�t�B���p�����[�^�ˑ��V�X�e��AFFSYS����͂���
% ���B
%
%             E(p) dx/dt  =  A(p) x  +  B(p) u
%                      y  =  C(p) x  +  D(p) u
%
% AFF2LFT�́A���̌^�̓����Ȑ��`�����\�����o�͂��܂��B
%
%                    ___________
%                    |         |
%               |----|  DELTA  |<---|
%               |    |_________|    |
%               |                   |
%               |    ___________    |
%               |--->|         |----|
%                    |   SYS   |
%           u  ----->|_________|----->  y
%
% �����ŁA
% * �m�~�i���ȃV�X�e��SYS�́A�p�����[�^p1, ..., pK�̕��ϒl�ɑΉ����܂��B
% * DELTA�́A���̌^�̃u���b�N�Ίp�ȕs�m�����\���ł��B
%            DELTA =  blockdiag (d1*I , ... , dK*I)
%      
%           | dj |  <=  (pj_max - pj_min)/2
%
%
% �Q�l�F    PSYS, PVEC, UBLOCK, PSINFO, PVINFO, UINFO.



%   Copyright 1995-2002 The MathWorks, Inc. 
