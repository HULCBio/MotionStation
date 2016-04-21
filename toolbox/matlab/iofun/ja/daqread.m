% DAQREAD   Data Acquisition Toolbox �� (.daq) �f�[�^�t�@�C���̓ǂݍ���
%
% DATA = DAQREAD('FILENAME') �́AFILENAME �̃f�[�^���W�t�@�C����ǂݍ�
% �݁ADATA �� M�~N �̃f�[�^�s��Ƃ��ďo�͂��܂��B�����ŁAM �̓T���v��
% �����w�肳��AN �̓`�����l�������w�肳��Ă��܂��B�����̃g���K���琬��
% �f�[�^�̏ꍇ�A�e�g���K����̃f�[�^�́ANaN �ɂ���ĕ�������Ă��܂��B
%
% [DATA, TIME] = DAQREAD('FILENAME') �́AFILENAME �̃f�[�^���W�t�@�C��
% ��ǂݍ��݁A���Ԃ̒l��g�Ƃ��ďo�͂��܂��BTIME �� DATA �Ɠ��������ŁA
% �ŏ��̃g���K�Ɋ֘A����e�f�[�^�T���v���̑��ΓI�Ȏ��Ԃ������x�N�g���ł��B
%
% [DATA, TIME, ABSTIME] = DAQREAD('FILENAME') �́A�ŏ��̃g���K�̐�Ύ��� 
% ABSTIME ���o�͂��܂��BABSTIME �́ACLOCK �x�N�g���Ƃ��ĕԂ���܂��B
%
% [DATA, TIME, ABSTIME, EVENTS] = DAQREAD('FILENAME') �́A�C�x���g��
% ���O���܂ލ\���� EVENTS ���o�͂��܂��B
%
% [DATA,...] = DAQREAD('FILENAME', 'P1', V1, 'P2', V2,...) �́A�t�@�C�� 
% FILENAME �� DATA �s��̌`���� TIME �s��̌`������ǂݍ��܂��f�[�^�ʂ�
% �w�肵�܂��B
%
% �L���ȃv���p�e�B�� (P1, P2,...) �ƃv���p�e�B�l (V1, V2,...) �͈ȉ���
% �Ƃ���ł��B
%
%      Samples    -  [sample range]
%      Time       -  [time range in seconds]
%      Triggers   -  [trigger range]
%      Channels   -  [channel indices or cell array of ChannelNames]
%      DataFormat -  [ {double} | native ]
%      TimeFormat -  [ {vector} | matrix ]
%
% Samples�ATime �� Triggers �v���p�e�B�݂͌��ɔr���I�ł��B���Ȃ킿�A
% Samples�ATriggers �܂��� Time �͈�x�ɒ�`���邱�Ƃ��ł��܂��B
%
% DataFormat �� TimeFormat �v���p�e�B�ɑ΂���f�t�H���g�l�́A{} ��
% �͂܂ꂽ���̂ł��B
%
% DAQINFO = DAQREAD('FILENAME', 'info') �́AFILENAME �̃f�[�^���W�t�@�C��
% ��ǂݍ��݁A�ȉ��̏����܂ލ\���� DAQINFO ���o�͂��܂��B
%
%    DAQINFO.ObjInfo - �t�@�C�� FILENAME ���쐬���邽�߂Ɏg����
%                      �f�[�^���W�I�u�W�F�N�g�ɑ΂��Ă� PV �̑g�ݍ���
%                      �����܂܂��\���̂ł��B
%                      ����: UserData �v���p�e�B�l�͍Ċi�[����܂���B
%    DAQINFO.HwInfo  - �n�[�h�E�F�A��񂪊܂܂��\����
%
% DAQINFO �\���̂́A�ȉ��̍\���œ��邱�Ƃ��\�ł��B
% [DATA, TIME, ABSTIME, EVENTS, DAQINFO] = DAQREAD('FILENAME')
%    
% Data Acquisition Toolbox �̃f�[�^�t�@�C��(.daq)�́ALogFileName 
% �v���p�e�B�ɑ΂��Ďw�肳�ꂽ�l�� LoggingMode �v���p�e�B�� 'Disk' 
% �܂��� 'Disk&Memory' ���ݒ肳��邱�Ƃō쐬����܂��B
%
% ���:
%      data.daq �t�@�C�����炷�ׂẴf�[�^��ǂݍ��ނ��߂ɂ́A
%      �ȉ��̂悤�ɂ��܂��B
%         [data, time] = daqread('data.daq');
%
%      data.daq �t�@�C������]���̌`���ŁA2�A4��7�̃`�����l��
%      �C���f�b�N�X��1000����2000�܂ł̃T���v���݂̂�ǂݍ���
%      ���߂ɂ́A�ȉ��̂悤�ɂ��܂��B
%         data = daqread('data.daq', 'Samples', [1000 2000],...
%                                'Channels', [2 4 7], 'DataFormat', 'native');
%
%      data.daq �t�@�C�����炷�ׂẴ`�����l���ōŏ���2�Ԗڂ�
%      �g���K��\���f�[�^�݂̂�ǂݍ��ނ��߂ɂ́A�ȉ��̂悤��
%      ���܂��B
%         [data, time] = daqread('data.daq', 'Triggers', [1 2]);
%
%      data.daq �t�@�C������`�����l���̃v���p�e�B�l�𓾂邽�߂ɂ́A
%      �ȉ��̂悤�ɂ��܂��B
%         daqinfo = daqread('data.daq', 'info');
%         chaninfo = daqinfo.ObjInfo.Channel;
%     
% �Q�l : DAQHELP, GETDATA.


%    MP 6-12-98
%    Copyright 1998-2002 The MathWorks, Inc.
