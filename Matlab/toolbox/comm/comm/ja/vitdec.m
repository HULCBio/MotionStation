% VITDEC   Viterbi�A���S���Y�����g���āA��ݍ��ݕ������f�[�^�𕜍�
%
% DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,DECTYPE) �́AViterbi �A���S
% ���Y�����g���āA�x�N�g�� CODE �𕜍����܂��BCODE �́AMATLAB �\���� 
% TRELLIS �Őݒ肳�ꂽ��ݍ��ݕ�����̏o�͂Ɖ��肵�Ă��܂��B�L����
% TRELLIS �\���̂Ɋւ��ẮAPOLY2TRELLIS ���Q�Ƃ��Ă��������BCODE �̒���
% �e�V���{���́Alog2(TRELLIS.numOutputSymbols)�r�b�g����\������ACODE �́A
% ��܂��͕����̃V���{�����܂�ł��܂��BDECODE �́ACODE �Ɠ���������
% �x�N�g���ŁA���̃V���{���̊e�X�́Alog2(TRELLIS.numInputSymbols)�r�b�g
% �ō\������Ă��܂��BTBLEN �́A�g���[�X�o�b�N�̐[����ݒ肷�鐳�̐���
% �X�J���ł��B
%    
% OPMODE �́A������̉��Z���[�h���`���܂��B
% 'trunc' : ������́A�[����Ԃ���X�^�[�g���Ă���Ɖ��肵�Ă��܂��B
%           ������́A�ŗǌv�ʂ��g���āA��Ԃ���g���[�X�o�b�N���܂��B
% 'term'  : ������́A�ŏ����Ō�����ׂă[����Ԃł���Ɖ��肵�Ă��܂��B
%           ������́A�I�[���[����Ԃ���g���[�X�o�b�N���܂��B
% 'cont'  : ������́A�I�[���[����Ԃ���X�^�[�g���Ă���Ɖ��肵�Ă��܂��B
%           ������́A�ŗǌv�ʂ��g���āA��Ԃ���g���[�X�o�b�N���܂��B
%           TBLEN �V���{���ɓ������x�ꂪ��荞�܂�܂��B
%    
% DECTYPE �́ACODE �ɕ\�������r�b�g�����`���܂��B
% 'unquant' : ������́A�����t�������͒l��ΏۂƂ��Ă��܂��B
%             +1 �́A�_���[���A-1 �͘_��1��\���܂��B
% 'hard'    : ������́A2�l���͒l��ΏۂƂ��Ă��܂��B
% 'soft'    : ���̃V���^�b�N�X���Q�Ƃ��Ă��������B
%
% DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,'soft',NSDEC) �́A0�� 
% 2^NSDEC-1 �̊Ԃ̐�������\���������̓x�N�g�� CODE �𕜍����܂��B
% �����ŁA0 �͍ł��M������ 0�A2^NSDEC-1�͍ł��M������ 1��\���Ă��܂��B
% NSDEC �́A����^�C�v��'soft' �̏ꍇ�̂݁A�K�v�Ȉ����ł��邱�Ƃɒ���
% ���Ă��������B
%    
% DECODED = VITDEC(..., 'cont', ..., INIT_METRIC,INIT_STATES,INIT_INPUTS)
% �́A������Ԍv�ʁA�����g���[�X�o�b�N��ԁA�����g���[�X�o�b�N���͂�����
% �������^���܂��BINIT_METRIC �̒��̊e�����́A�Ή������Ԃ̏������
% �v�ʂ�\���Ă��܂��BINIT_STATES �� INIT_INPUTS �́A������̏����g���[�X
% �o�b�N�����������݂��ɐݒ肵�܂��B�����́A���� TRELLIS.numStates �s 
% TBLEN ��̍s��ɂȂ�܂��BINIT_STATES �́A0���� TRELLIS.numStates-1 
% �܂ł̐����ŁAINIT_INPUTS �́A0���� TRELLIS.numInputSymbols-1 �܂ł�
% �����ō\������Ă��܂��B�Ō� 3 �̈����S�Ăɂ��ăf�t�H���g�l���g��
% �ɂ́A[],[],[] �̂悤�ɐݒ肵�Ă��������B
%    
% [DECODED FINAL_METRIC FINAL_STATES FINAL_INPUTS] = VITDEC(..., 'cont',  ...) 
% �́A���������̍Ō�ŁA��Ԍv�ʁA�g���[�X�o�b�N��ԁA�g���[�X�o�b�N����
% ���o�͂��܂��BFINAL_METRIC �́A�ŏI��Ԍv�ʂɑΉ����� TRELLIS.numStates 
% �v�f�����x�N�g���ł��BFINAL_STATES �� FINAL_INPUTS �́A
% TRELLIS.numStates �s TBLEN ��̍s��ł��B
%    
% ���F
%  t = poly2trellis([3 3],[4 5 7;7 4 2]);  k = log2(t.numInputSymbols);
%  msg = [1 1 0 1 1 1 1 0 1 0 1 1 0 1 1 1];
%  code = convenc(msg,t);    tblen = 3;
%  [d1 m1 p1 in1]=vitdec(code(1:end/2),t,tblen,'cont','hard');
%  [d2 m2 p2 in2]=vitdec(code(end/2+1:end),t,tblen,'cont','hard',....
%      m1,p1,in1);
%  [d m p in] = vitdec(code,t,tblen,'cont','hard');
%    
% �����������ꂽ���b�Z�[�W���Ad ��[d1 d2] �ɏo�͂���܂��B�y�A�Am,m2 ��
% p,p2�Ain,in2 ���܂������ł��Bd �́Amsg �̒x������o�[�W�����ŁA����
% ���߂ɁAmsg(1:end-tblen*k) �� d(tblen*k+1:end) �͓����ɂȂ�܂��B
%    
% �Q�l�F CONVENC, POLY2TRELLIS, ISTRELLIS.


% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:22 $
% Author : Katherine Kwong
% Calls vit.c
