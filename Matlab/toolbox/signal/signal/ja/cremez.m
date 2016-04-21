% CFIRPM ���f��������`�ʑ��̓����b�v��FIR�t�B���^�݌v
%
% CFIRPM �́A���f���ɂȂ�\���̂���FIR�t�B���^�݌v�ɑ΂��āA�ݒ肳���
% �C�ӂ̎��g���̈�̐����ݒ�ł��܂��B�����b�v��FIR�t�B���^�݌v���s��
% ���̂ɁAChebyshev(�܂��́A�~�j�}�b�N�X)�t�B���^�덷���œK�����܂��B
%
% B = CFIRPM(N,F,'fresp',W)�́A�֐�fresp�ɂ���ďo�͂�����]������g��
% �����ɍœK�ߎ����钷��(N+1)��FIR�t�B���^���o�͂��܂��B���̃V���^�b�N�X
% ���g�����ƂŁA�֐�CFIRPM�͓����ŁA�ȉ��̎��̌`�Ŋ֐�fresp���g���܂��B
%
%    [DH,DW] = fresp(N,F,GF,W);
%
% �����ŁAN�̓t�B���^�̎����ł��BF�́A-1��1�̊ԂŁA�P���ɕ\�������g��
% �ш�G�b�W�̃x�N�g���ł��B�����ŁA1�̓T���v�����O���g����1/2(Nyquist��
% �g��)�ł��B���g���ш�́Ak����̏ꍇ�AF(k)����F(k+1)�܂ł͈̔͂ŁA��
% �܂�k����̏ꍇ�AF(k+1)�`F(k+2)�̋�Ԃ́A�J�ڑш�A���邢�́A�œK��
% �̍ۂɔz������Ȃ��̈�ł��B
% 
% GF�́ACFIRPM �ɂ���Đݒ肳�ꂽ�e���g���ш��Ő��`�ɕ�Ԃ��ꂽ�O���b
% �h�_�̃x�N�g���ł��B�܂��AGF�́A�����֐���]�����Ȃ���΂Ȃ�Ȃ����g��
% �O���b�h�����肵�܂��B
%
% W �́A�œK���̍ۂɗp������ш斈��1�̎��������̏d�݂�ݒ肷��v
% �f����Ȃ�x�N�g���ł��BW�́ACFIRPM�̎g�p�ɂ����āA�I�v�V�����ł��B��
% �ݒ�̏ꍇ�́A'fresp'�ɓn�����O�ɒP�ʏd�݂ɐݒ肳��܂��BDH �� DW �́A
% �e�X�O���b�hGF���̊e���g���Ōv�Z������]���镡�f���g�������ƍœK�d��
% �x�N�g���ł��B
%
% �ȉ��̊֐�fresp�ɑ΂��āA���g�������֐���O�����Ē�`�ł��܂��B
%
%     'lowpass'  'bandpass' 'multiband'      'hilbfilt'
%     'highpass' 'bandstop' 'differentiator' 'invsinc'
%
% ����ɏ��𓾂邽�߂ɂ́A PRIVATE/LOWPASS �Ȃǂ̃w���v���Q�Ƃ��Ă���
% �����B
%
% B = CFIRPM(N,F,{'fresp',P1,P2,...},W)�́A�I�v�V�������� P1,P2...������
% �֐�fresp�ɓn���܂��B
%
% B = CFIRPM(N,F,A,W)�́AB  = cfirpm(N,F,{'multiband',A},W)�Ɠ����ł��B
% �����ŁAA�́AF�̒��̑ш�G�b�W�ɑ΂���U���������܂񂾃x�N�g���ł��B
%
% B = CFIRPM(..., SYM)�́A�݌v�̃C���p���X�����ɑΏ̐��𐧖�Ƃ��ĉۂ���
% ���B�����ŁASYM �́A���̕������ݒ肷�邱�Ƃ��ł��܂��B
%
%  'none' - ����́A�C�ӂ̕��̑ш�G�b�W���g����ʉ߂�����ꍇ���A���邢
%           �́A'fresp'����ăf�t�H���g�l���^�����Ȃ��ꍇ�̃f�t�H���g
%           �l�ł��B
%
%  'even' - �����������̃C���p���X�����ł��B����́A�n�C�p�X�A���[�p�X
%           �o���h�p�X�A�o���h�X�g�b�v�A����сA�}���`�o���h�݌v�̏ꍇ��
%           �f�t�H���g�l�ł��B
%
%  'odd'  - ��������̃C���p���X�����ł��B����́AHilbert�ϊ��q����
%           �є�����݌v�̏ꍇ�̃f�t�H���g�l�ł��B
%
%  'real' - ���g�������ɑ΂��鋤��Ώ̂ł��B
%
% �e�X�̎��g�������֐� 'fresp'�́ASYM�ɑ΂���f�t�H���g�l��񋟂��܂��B
% ����ɏ��𓾂邽�߂ɂ́A private/lowpass �Ȃǂ̃w���v���Q�Ƃ��Ă���
% �����B'none'�ȊO�̔C�ӂ� SYM �I�v�V������ݒ肵���ꍇ�A�ш�G�b�W�͐�
% �̎��g����ɂ̂ݐݒ肵�܂��B���Ȃ킿�A���̎��g���̈�͑Ώ̐��ɂ�蓾��
% ��܂��B
%
% B = CFIRPM(..., 'skip_stage2')�́Acfirpm���W����Remez�덷�����ɂ����
% �œK�������߂��Ȃ������Ɣ��肵���ꍇ�ɂ̂ݎ��s������2�i�œK���A��
% �S���Y���𖳌��ɂ��܂��B���̃A���S���Y���𖳌��ɂ���ƌv�Z���x�����シ
% ��ꍇ������܂����A���x���ቺ����\��������܂��B�f�t�H���g�ł́A��
% 2�i�œK���͗L���ł��B
%
% B = CFIRPM(..., DEBUG)�́A�t�B���^�݌v�ߒ��̌��ʂ̕\�����s�Ȃ��܂��B��
% ���ŁADEBUG�́A'trace', 'plots', 'both',�܂���, 'off'�̂����ꂩ1���
% �肷�邱�Ƃ��ł��܂��B�f�t�H���g�ł́A'off'�ɐݒ肳��܂��B
%
% B = CFIRPM(...,{LGRID})�ł́A{LGRID}�́A��̐�������Ȃ�1�s1��̃Z��
% �z��ŁA���g���O���b�h�̊Ԋu���R���g���[�����܂��B���̊Ԋu�́A��܂��ɁA
% 2^nextpow2(L-GRID*N)�_�������܂��BLGRID�̃f�t�H���g�l��25�ł��B
%
% SYM, DEBUG, 'skip_stage2',����сA{LGRID}�I�v�V�����̔C�ӂ̑g�������
% �肷�邱�Ƃ��ł��܂��B
%
% [B,ERR] = CFIRPM(...)�́A�ő僊�b�v���̍���ERR���o�͂��܂��B
%
% [B,ERR,RES] = CFIRPM(...)�́ACFIRPM���v�Z�����I�v�V�������ʂ̍\����RES
% ���o�͂��A���̓��e���܂܂�Ă��܂��B
%
%   RES.fgrid : �t�B���^�݌v�œK���ɗp������g���O���b�h�x�N�g��
%   RES.des   : RES.fgrid���̊e�_�ɑ΂����]������g������
%   RES.wt    : RES.fgrid���̊e�_�ɑ΂���d��
%   RES.H     : RES.fgrid�̊e�_�̎��ۂ̎��g������
%   RES.error : RES.fgrid�̊e�_�̌덷 
%   RES.iextr : ���ʂȎ��g��������RES.fgrid���̃C���f�b�N�X
%   RES.fextr : ���ʂȎ��g���̃x�N�g��
%
% �Q�l�F   FIRPM, FIR1, FIRLS, FILTER,  PRIVATE/LOWPASS,
%          PRIVATE/HIGHPASS,   PRIVATE/BANDPASS, PRIVATE/BANDSTOP,
%          PRIVATE/MULTIBAND,  PRIVATE/INVSINC,  PRIVATE/HILBFILT,
%          PRIVATE/DIFFERENTIATOR.
% 



%   Copyright 1988-2002 The MathWorks, Inc.
