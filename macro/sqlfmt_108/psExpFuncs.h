/*************************************
 * psExpFuncs.c
 * DLL �֐��v���g�^�C�v
 *************************************/
#ifndef PSEXPFUNCS_H
#define PSEXPFUNCS_H

#ifdef __cplusplus
	extern "C" {
#endif

/*
 * �R�}���h�c�[���� SqlFmt �Ɠ����������Ƃ�^�C�v�̊֐��B
 * �t�@�C������f�B���N�g���w�肪�ȗ�����Ă���ꍇ��
 * �N���b�v�{�[�h��̕�����𐮌`����B
 */
	extern
	__declspec(dllexport) int __cdecl
iPerformInCompatibleForm(
	const char *szParam0   /* in */
	, const char *szParam1 /* in */
	, const char *szParam2 /* in */
	, const char *szParam3 /* in */
);

/*
 * �z�X�g����i�Ăяo���j�����\�ߌĂяo���O�ɏ�������������o�b�t�@��
 * ���`�ς݂̕����R�s�[����B���`��ɕ�����o�b�t�@���̍ő咷�𒴂����
 * ��0��߂��A�ُ�I������B
 * �R�s�[����I�[�o�[�w�b�h�����邽�߁AiFmtStmt() ���
 * ���\�[�X�g�p�̖��ʂ�����B
 */
	extern
	__declspec(dllexport) int __stdcall
iCopyToPreparedStr(
	const char *szStmtOrg /* in : �I���W�i���i���`�O�j�̕� */
	, const char *szIdtStr /* in : �C���f���g�Ɏg�p���镶���� */
	, const unsigned iMinNumComma /* in : ���ʓ��Ɏw�肵�����ȉ��̃J���}�̏ꍇ�́A���s���Ȃ� */
	, const unsigned iMinPartSize /* in : ���ʓ��Ɏw�肵���o�C�g���ȓ��̕�����̏ꍇ�́A���s���Ȃ� */
	, char *const szStmtFmt /* out : ���`��̕����i�[���镶����o�b�t�@ */
	, unsigned *const iStrLen /* out : ���`��̕��̃o�C�g�� */
	, const size_t iStmtFmt /* in : ������o�b�t�@�̃o�C�g��(�i�[�\�ő咷) */
);

/*
 * �z�X�g����i�Ăяo���j�����\�ߌĂяo���O�ɏ�������������o�b�t�@��
 * ���`�ς݂̕����R�s�[����B���`��ɕ�����o�b�t�@���̍ő咷�𒴂����
 * ��0��߂��A�ُ�I������B
 * PL/SQL ����� tStmtStyle �^�̃����o���A�N�Z�X�ł��Ȃ��̂ŃX�J���^��
 * �������g���ăX�^�C���w����s���B
 * Oracle�̊O���v���V�[�W���Ƃ��Ă̗��p��z��B
 */
	extern
	__declspec(dllexport) int  __cdecl
iCopyToPreparedVc2(
	const char *szStmtOrg /* in : �I���W�i���i���`�O�j�̕� */
	, int const iStmtOrg /* in : �I���W�i���̃o�C�g�� */
	, const char *szIdtStr /* in : �C���f���g�Ɏg�p���镶���� */
	, int const iIdtStr /* in : �C���f���g�Ɏg�p���镶����̃o�C�g�� */
	, const unsigned iMinNumComma /* in : ���ʓ��Ɏw�肵�����ȉ��̃J���}�̏ꍇ�́A���s���Ȃ� */
	, const unsigned iMinPartSize /* in : ���ʓ��Ɏw�肵���o�C�g���ȓ��̕�����̏ꍇ�́A���s���Ȃ� */
	, char *const szStmtFmt /* out : ���`��̕����i�[���镶����o�b�t�@ */
	, int *const iStrLen /* out : ���`��̕��̃o�C�g�� */
);

/*
 * ���I�Ɋm�ۂ��ꂽ������o�b�t�@�֐��`�ς݂̕����i�[���A���̃|�C���^��߂��B
 * �|�C���^�ϐ��̓z�X�g����ŏ��������̃A�h���X�𓖊֐��֓n���B
 * ���֐������s��́A�K���߂��ꂽ�|�C���^�� free ���Ȃ���΂Ȃ�Ȃ��B
 * �K�v�ȕ��������\�[�X���m�ۂ��Ȃ����߁A�����Ƃ��p�t�H�[�}���X���悢�B
 */
	extern
	__declspec(dllexport) int  __stdcall
iFmtStmt(
	const char *szStmtOrg /* in : �I���W�i���i���`�O�j�̕� */
	, char **const szStmtFmt /* out: ���`��̕��̓q�[�v�֊i�[�����B�g�p��͕K�� free ����B*/
	, tStmtStyle *const rStmtStyle /* in/out : ���`��̕��X�^�C�����`���鐔�l */
);

#ifdef __cplusplus
	}
#endif /* __cplusplus */

#endif /* PSEXPFUNCS_H */

