/*************************************
 * psExpFuncs.c
 * DLL 関数プロトタイプ
 *************************************/
#ifndef PSEXPFUNCS_H
#define PSEXPFUNCS_H

#ifdef __cplusplus
	extern "C" {
#endif

/*
 * コマンドツール版 SqlFmt と同じ引数をとるタイプの関数。
 * ファイル名やディレクトリ指定が省略されている場合は
 * クリップボード上の文字列を整形する。
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
 * ホスト言語（呼び出し）側が予め呼び出し前に準備した文字列バッファへ
 * 整形済みの文をコピーする。整形後に文字列バッファ長の最大長を超えると
 * 非0を戻し、異常終了する。
 * コピーするオーバーヘッドがあるため、iFmtStmt() より
 * リソース使用の無駄がある。
 */
	extern
	__declspec(dllexport) int __stdcall
iCopyToPreparedStr(
	const char *szStmtOrg /* in : オリジナル（整形前）の文 */
	, const char *szIdtStr /* in : インデントに使用する文字列 */
	, const unsigned iMinNumComma /* in : 括弧内に指定した数以下のカンマの場合は、改行しない */
	, const unsigned iMinPartSize /* in : 括弧内に指定したバイト数以内の文字列の場合は、改行しない */
	, char *const szStmtFmt /* out : 整形後の文を格納する文字列バッファ */
	, unsigned *const iStrLen /* out : 整形後の文のバイト数 */
	, const size_t iStmtFmt /* in : 文字列バッファのバイト数(格納可能最大長) */
);

/*
 * ホスト言語（呼び出し）側が予め呼び出し前に準備した文字列バッファへ
 * 整形済みの文をコピーする。整形後に文字列バッファ長の最大長を超えると
 * 非0を戻し、異常終了する。
 * PL/SQL からは tStmtStyle 型のメンバをアクセスできないのでスカラ型の
 * 引数を使ってスタイル指定を行う。
 * Oracleの外部プロシージャとしての利用を想定。
 */
	extern
	__declspec(dllexport) int  __cdecl
iCopyToPreparedVc2(
	const char *szStmtOrg /* in : オリジナル（整形前）の文 */
	, int const iStmtOrg /* in : オリジナルのバイト数 */
	, const char *szIdtStr /* in : インデントに使用する文字列 */
	, int const iIdtStr /* in : インデントに使用する文字列のバイト数 */
	, const unsigned iMinNumComma /* in : 括弧内に指定した数以下のカンマの場合は、改行しない */
	, const unsigned iMinPartSize /* in : 括弧内に指定したバイト数以内の文字列の場合は、改行しない */
	, char *const szStmtFmt /* out : 整形後の文を格納する文字列バッファ */
	, int *const iStrLen /* out : 整形後の文のバイト数 */
);

/*
 * 動的に確保された文字列バッファへ整形済みの文を格納し、そのポインタを戻す。
 * ポインタ変数はホスト言語で準備しそのアドレスを当関数へ渡す。
 * 当関数を実行後は、必ず戻されたポインタを free しなければならない。
 * 必要な分しかリソースを確保しないため、もっともパフォーマンスがよい。
 */
	extern
	__declspec(dllexport) int  __stdcall
iFmtStmt(
	const char *szStmtOrg /* in : オリジナル（整形前）の文 */
	, char **const szStmtFmt /* out: 整形後の文はヒープへ格納される。使用後は必ず free する。*/
	, tStmtStyle *const rStmtStyle /* in/out : 整形後の文スタイルを定義する数値 */
);

#ifdef __cplusplus
	}
#endif /* __cplusplus */

#endif /* PSEXPFUNCS_H */

