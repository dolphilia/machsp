//動作対象の列挙
var support = {
    'cl':'コンソール版HSP',
    'win':'Windows版HSP',
    'linux':'Linux版HSP',
    'dish':'hspdish',
    'dishjs':'hspdish.js',
    'let':'HSPLet',
    'mac':'Mac版HSP'
};

//グループの列挙
var group = {
    'system':'システム制御',
    'object':'オブジェクト制御',
    'sysvar':'システム変数',
    'file':'ファイル操作',
    'prep':'プリプロセッサ',
    'control':'プログラム制御',
    'media':'マルチメディア',
    'memory':'メモリ管理',
    'io':'基本入出力',
    'math':'数学',
    'string':'文字列操作',
    'macro':'標準定義マクロ',
    'screen':'画面制御',
    'other':'その他'
};

//2次元配列からテーブルを作成する
var makeTable = function(array){
	var table = "";
	table += "<table>";
	for (i = 0; i < array.length; i++) {
		table += "<tr>";
		for (j = 0; j < array[i].length; j++) {
			table += "<td>";
			table += array[i][j];
			table += "</td>";
		}
		table += "</tr>";
	}
	table += "</table>";
	return table;
};

var joinArray = function(array) {
	var ret = "";
	$.each(array,function(index,value) {
		ret += '<p>'+value+'</p>';
	});
	return ret;
};

var r = '<br>';
var br = '<br><br>';

//検索用インデックス
var doclib = { //グループ
/*
	'builtin': {
		'__example__': { //命令名
		    'title': '', //命令の概要
		    'format': '', //書式（命令名 p1,p2,p3,p4）
		    'parameter': [''], //パラメータ（p1=0〜(0):パラメータ説明文<br>p2=<br>）
		    'description': [''], //説明文
		    'relation': [''] //関連する項目
		}
	}
*/
};

/*
//フォーマット
var doclib[''] = {
	'__info__': {
		'group': ''
		'type': '',
		'version': '',
		'note': '',
		'pubdate': '',
		'author': '',
		'url': '',
		'support': ['']
	}
	'': {
		'title': '',
		'format': '',
		'parameter': [''],
		'description': [''],
		'relation': ['']
	}
};
*/