___INFO___

{
  "displayName": "クエリ除去",
  "description": "指定した変数から、任意のクエリを除去した文字列を返す変数です。",
  "securityGroups": [],
  "id": "cvt_temp_public_id",
  "type": "MACRO",
  "version": 1,
  "containerContexts": [
    "WEB"
  ],
  "brand": {}
}


___TEMPLATE_PARAMETERS___

[
  {
    "help": "クエリを除去したい対象の変数を選択してください。例えばリンクURLであれば、要素URLとなります。",
    "macrosInSelect": true,
    "selectItems": [
      {
        "displayValue": "要素URL",
        "value": "elementUrl"
      },
      {
        "displayValue": "ページURL（ハッシュ抜き）",
        "value": "pageUrl"
      },
      {
        "displayValue": "ページURL（ハッシュ含む）",
        "value": "pageUrlAll"
      }
    ],
    "displayName": "対象変数",
    "name": "targetVar",
    "type": "SELECT",
    "subParams": [
      {
        "help": "対象変数のクエリ（「?～～」）から除去する場合にチェックしてください。",
        "alwaysInSummary": true,
        "defaultValue": true,
        "displayName": "",
        "name": "query",
        "checkboxText": "クエリから除去",
        "type": "CHECKBOX"
      },
      {
        "help": "対象変数のハッシュ（「#～～」）から除去する場合にチェックしてください。",
        "defaultValue": false,
        "displayName": "",
        "name": "hash",
        "checkboxText": "ハッシュタグから除去",
        "type": "CHECKBOX"
      }
    ]
  },
  {
    "help": "対象変数から除去したいクエリ名を入力してください。",
    "displayName": "除去するクエリ",
    "name": "targetQueries",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "",
        "name": "query",
        "type": "TEXT"
      }
    ],
    "type": "SIMPLE_TABLE"
  }
]


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "gtm.elementUrl"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// -------- 動作確認用
var log = require('logToConsole');
log('data =', data);
// data.targetVar :"https://tagmanager.googleusercontent.com/js_sandbox.html"
// data.targetQueries:[{"query":"_ga"},{"query":"_gac"}]
// data.query:true
// data.hash:true

// --------- 実処理
// ---- 初期値の取得
var Var = data.targetVar;	// 対象変数
var delQuery = data.targetQueries;	// 除去クエリ
var delTarget = [data.query, data.hash];	// 除去対象（0:クエリ、1:ハッシュ）

// -- 対象変数の取得
switch(Var){
	case 'elementUrl':
		log('elementUrl');
		var get = require('copyFromDataLayer');
		Var = get('gtm.elementUrl');
		break;
	case 'pageUrl':
		log('pageUrl');
		var get = require('getUrl');
		Var = get('protocol') +'://' + get('host') + get('path');
		if(get('query')){
			Var += '?' + get('query');
		}
		break;
	case 'pageUrlAll':
		log('pageUrlAll');
		var get = require('getUrl');
		Var = get('protocol') +'://' + get('host') + get('path');
		if(get('query')){
			Var += '?' + get('query');
		}
		if(get('fragment')){
			Var += '#' + get('fragment');
		}
		break;
}
log(Var);

// -- URLの分割
if(Var !== undefined){
	var path = Var.split('?')[0].split('#')[0];
	var query = null;
	var hash = null;
	if(Var.indexOf('?') >= 0){
		query = Var.split('?')[1].split('#')[0];
	}
	if(Var.indexOf('#') >= 0){
		hash = Var.split('#')[1];
	}

	// ---- 除去処理
	var omit = function(del, target, word){
		if(delTarget[del] && target){
			// 検索＆除去
			var queries = target.split('&');	// クエリ毎に分割
			for(var i = queries.length - 1; i >= 0; i--){	// クエリ数分繰り返し（後ろから前）
				for(var j = 0; j < delQuery.length; j++){	// 除去クエリ数分繰り返し（前から後ろ）
					if(queries[i].indexOf(delQuery[j].query + '=') > -1){
						// 除去クエリが見つかったら
						queries.splice(i, 1);	// 対象を除去
						break;
					}
				}
			}
			if(queries.length >= 1){
				// クエリが残っていたら
				target = queries.join('&');
			}else{
				// クエリが残っていなかったら
				target = '';
			}
		}
		if(target){
			if(target.indexOf(word) !== 0){
				target = word + target;
			}
			path += target;
		}
	};

	omit(0, query, '?');	// クエリからの除去
	omit(1, hash, '#');	// ハッシュからの除去

	// ---- 処理完了
	return path;
}else{
	return undefined;
}


___NOTES___

リンクURLやページURLなどから、指定した名前のクエリを除去した文字列を返すためのカスタム変数テンプレートです。
主にリンクURLやページURLをイベント計測したい場合などに、不要となる_gaクエリなどを抜くために使用することを想定しています。

●動作概要
・「対象変数」で指定した変数から、「除去するクエリ」で指定したクエリを削除したものを返します。

●備考
・「対象変数」欄では特に需要の多い以下3つを変数登録不要で指定できます。
　　　・要素URL　（＝リンクURL）
　　　・ページURL（ハッシュ抜き）　（＝Page URL）
　　　・ページURL（ハッシュ含む）　（＝Page URL＋ハッシュ）
・「対象変数」欄では上記3項目の他、指定した任意の変数も対象に選択できます。
・除去対象はデフォルトでは「クエリ」のみとしていますが、
　「ハッシュタグから除去」にチェックを入れることでハッシュタグからも削除が可能です。
・「除去するクエリ」で指定するクエリ名は「完全一致」で判定しています。
・「除去するクエリ」で指定したクエリ名に合致する箇所がない、またはそもそも「除去するクエリ」が設定されていない場合は「対象変数」で指定した対象の値そのままが返ります。
・本テンプレートはアユダンテが1stドラフトを作成しました。

●編集履歴
【2019/06/21（更新）】
・変数の保存時に「サービスエラーが発生しました」とエラーメッセージが出て保存できないバグが発生していたため、「targetQueries」項目の入力規則を削除しました。

【2019/05/24（新規作成）】
・新規登録しました。
