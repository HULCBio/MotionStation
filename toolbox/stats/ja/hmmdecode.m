% HMMDECODE   �n��̌���̏�Ԋm�����v�Z
%
% PSTATES = HMMDECODE(SEQ,TRANSITIONS,EMISSIONS) �́A�J�ڊm���s�� 
% TRANSITIONS �� �G�~�b�V�����m���s�� EMISSIONS �ɂ���Ďw�肳�ꂽ�B��
% �}���R�t���f��(Hidden Markov Model)����n�� SEQ �̌���̏�Ԋm�� 
% PSTATES ���v�Z���܂��BTRANSITIONS(I,J) �́A��� I ������ J �ɑJ��
% ����m���ł��BEMISSIONS(K,SYM) �́A�V���{�� SYM ����� K ����G�~�b�g
% (emit)�����m���ł��B�n�� SEQ �̌���̊m���́A�m�� P(i = k | SEQ 
% �X�e�b�v�̏��)�ł��BPSTATES �́A���f�����̊e��Ԃɑ΂��āASEQ ����� 
% 1�̍s�Ɠ��������̔z��ł��BPSTATES �� (i,j) �̗v�f�́A���f���� SEQ ��
% j�Ԗڂ̃X�e�b�v�ŁA��� i ���ɂ���m����^���܂��B
%
% [PSTATES, LOGPSEQ] = HMMDECODE(SEQ,TR,E) �́A�J�ڍs�� TR �� �G�~�b�V����
% �s�� E ��^���āA�n�� SEQ �̊m���̑ΐ��ł��� LOGPSEQ ���o�͂��܂��B
%
% [PSTATES, LOGPSEQ, FORWARD, BACKWARD, S] = HMMDECODE(SEQ,TR,E) �́AS ��
% ����ăX�P�[�����ꂽ�n��̑O��������ь������m�����o�͂��܂��B
% ���ۂ̑O�����m���́A�ȉ��̏������g�����ƂŖ߂����Ƃ��ł��܂��B:
%        f = FORWARD.*repmat(cumprod(s),size(FORWARD,1),1);
% ���ۂ̌������m���́A�ȉ��̏������g�����ƂŖ߂����Ƃ��ł��܂��B:
%       bscale = fliplr(cumprod(fliplr(S)));
%       b = BACKWARD.*repmat([bscale(2:end), 1],size(BACKWARD,1),1);
%
% HMMDECODE(...,'SYMBOLS',SYMBOLS) �́A�G�~�b�g(emit)�����V���{����
% �w�肷�邱�Ƃ��ł��܂��BSYMBOLS �́A���l�z��A�܂��̓V���{���̖��O��
% �Z���z��ł��BN ���\�ȃG�~�b�V�����̐��ł���ꍇ�A�f�t�H���g��
% �V���{���́A1���� N �̊Ԃ̐����ł��B
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
%       pStates = hmmdecode(seq,tr,e);
%
%       [seq, states] = hmmgenerate(100,tr,e,'Symbols',...
%                 {'one','two','three','four','five','six'});
%       pStates = hmmdecode(seq,tr,e,'Symbols',...
%                 {'one','two','three','four','five','six'});
%
% �Q�l : HMMGENERATE, HMMESTIMATE, HMMVITERBI, HMMTRAIN.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2003/01/28 19:08:21 $
