% GETIMGNAME   Report Generator�̃C���[�W�Ƃ��ė��p����t�@�C�������o��
% �C���[�W�ɑ΂���K�؂ȃt�@�C�������o�͂��܂��B�t�@�C�����́AReportDi-
% rectory/rName_rExt_files/image-###-DESC.ext�̌`���ł��B�����ŁA###�̓�
% �j�[�N�Ȑ����ł��B
%
%   NAME=GETIMGNAME(C,IMGINFO,DESC)
% 
%   * C�́A�C�ӂ�report generator�R���|�[�l���g�ł��B
%   * IMGINFO�́AGETIMGFORMAT���o�͂���^�C�v�̍\���̂ł��B
%   * DESC (�I�v�V����)�́A���ʂ̖ړI�̂��߂Ƀt�@�C�����ɕt������镶��
%     ��ł��BDESC���w�肳��Ȃ��ꍇ�́A'etc'���p�����܂��B
%   * NAME�́A�C���[�W�t�@�C����ۑ�����t�@�C�����ł��B  
%
%   [NAME,ISNEW]=GETIMGNAME(C,IMGINFO,DESC,SOURCEID)
%
%   * SOURCEID�́A�C���[�W�ɑ΂���Z�b�V�����Ɉˑ����Ȃ����ʎq�ł��B
%     (��@Simulink�܂���Stateflow�ł̐�΃p�X��)
%   * ISNEW�́A����sourceID�ɑΉ�����C���[�W�t�@�C�������ɑ��݂���ꍇ
%     ��logical(0)���o�͂��A�Ăяo���Ă���R���|�[�l���g���C���[�W�t�@�C
%     �����Đ�������K�v���Ȃ��A�^����ꂽ�t�@�C�����𗘗p���邱�Ƃ��ł�
%     �邱�Ƃ��Ӗ����܂��B�w�肵��SOURCEID�ɑ΂��ăC���[�W�����݂��Ȃ���
%     ���́AISNEW��logical(1)���o�͂��܂��B
%
% [IMDB,ISOK]=GETIMGNAME(C,'$SaveVariables')�́A�C���[�W�̃f�[�^�x�[�X��
% ReportDirectory/rName_rExt_files/image-list.mat�ɕۑ����܂��B
% 
%   * IMDB = �C���[�W�f�[�^�x�[�X�\����
%   * ISOK = �\���̂��ۑ����ꂽ���ǂ������o��
%
% [FNAMES,ISOK]=GETIMGNAME(C,'$ListFiles')�́A�C���[�W�̃f�[�^�x�[�X���I
% �[�v�����f�[�^�x�[�X�t�@�C�������܂ޑS�Ẵt�@�C�������o�͂��܂��B
% 
%   * FNAMES = �t�@�C�����X�g
%   * ISOK = �\���̂����[�h���ꂽ���ǂ������o��
%
% �Q�l   GETIMGFORMAT





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:52 $
%   Copyright 1997-2002 The MathWorks, Inc.
