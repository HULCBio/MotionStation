%  [rate,P] = decay(pds,options)
%
% �|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ��V�X�e����2�����������v�Z
%
% DECAY�́A�p�����[�^�x�N�g��p�̒l�͈̔͂ŁA���̂悤��Lyapunov�s�� Q >
% 0�ɂ��āAt���ŏ������܂��B
%
%        A(p)*Q*E(p)' + E(p)*Q*A(p)'  <   t * E(p)*Q*E(p)'
%
% �V�X�e���́Atmin < 0�Ȃ��2���I�Ɉ���ł��B
%
% ����:
%   PDS       �|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ��V�X�e��(PSYS
%             ���Q��)�B
%   OPTIONS   �I�v�V������2�v�f�x�N�g���B
%             OPTIONS(1)=0 :  �������[�h(�f�t�H���g)
%                       =1 :  �ł��ێ琫�̂Ȃ����[�h
%             OPTIONS(2)   :  P�̏������̌��E�l(�f�t�H���g = 1e9)�B
%  �o��:
%   RATE      ������
%   P         Lyapunov�s��P = inv(Q)
%
% �Q�l�F    QUADSTAB, MUSTAB, PDLSTAB.



%  Copyright 1995-2002 The MathWorks, Inc. 
