% HMMVITERBI   �n��ɑ΂��čł��N���肤���ԃp�X���v�Z
%
% STATES = HMMVITERBI(SEQ,TRANSITIONS,EMISSIONS) �́A�n�� SEQ ��^���A
% �J�ڊm���s�� TRANSITIONS �ƃG�~�b�V�����m���s�� EMISSIONS �ɂ����
% �w�肳�ꂽ�B��}���R�t���f��(Hidden Markov Model) ��ʂ�ł��\����
% �����p�X���v�Z���܂��BTRANSITIONS(I,J) �́A��� I ������ J �ɑJ��
% ����m���ł��BEMISSIONS(K,L) �́A�V���{�� L ����� K ����G�~�b�g
% (emit)�����m���ł��B
%
% HMMVITERBI(...,'SYMBOLS',SYMBOLS) �́A�G�~�b�g(emit)�����V���{����
% �w�肷�邱�Ƃ��ł��܂��BSYMBOLS �́A���l�z��A�܂��̓V���{���̖��O��
% �Z���z��ł��BN ���\�ȃG�~�b�V�����̐��ł���ꍇ�A�f�t�H���g��
% �V���{���́A1���� N �̊Ԃ̐����ł��B
%
% HMMVITERBI(...,'STATENAMES',STATENAMES) �́A��Ԗ����w�肷�邱�Ƃ�
% �ł��܂��BSTATENAMES �́A���l�z��A�܂��͏�Ԃ̖��O�̃Z���z��ł��B
% �f�t�H���g�̏�Ԗ��́AM ����Ԑ��̏ꍇ�A1���� M �̊ԂɂȂ�܂��B
%
% ���̊֐��́A��ɏ��1�̃��f������n�܂�A���ɑJ�ڍs��̍ŏ��̍s��
% ����m�����g���čŏ��̃X�e�b�v�ɑJ�ڂ��܂��B�]���āA�ȉ��ŗ^����ꂽ
% ���ɂ����āA��Ԃ̏o�͂̍ŏ��̗v�f�́A0.95�̊m����1�ɁA0.05�̊m����
% 2�ɂȂ�܂��B
%
% ���:
%
% 		tr = [0.95,0.05;
%             0.10,0.90];
%           
% 		e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
%            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
%
%       [seq, states] = hmmgenerate(100,tr,e);
%       estimatedStates = hmmviterbi(seq,tr,e);
%
%       [seq, states] = hmmgenerate(100,tr,e,'Statenames',{'fair';'loaded'});
%       estimatesStates = hmmviterbi(seq,tr,e,'Statenames',{'fair';'loaded'});
%
% �Q�l : HMMGENERATE, HMMDECODE, HMMESTIMATE, HMMTRAIN.


%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2003/01/28 19:08:17 $
