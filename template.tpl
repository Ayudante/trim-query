___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "displayName": "Trim Query",
  "description": "Returns a string obtained by deleting an arbitrary query from the specified variable.",
  "securityGroups": [],
  "categories": [
    "UTILITY"
  ],
  "id": "cvt_temp_public_id",
  "type": "MACRO",
  "version": 1,
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "targetURL",
    "displayName": "Target URL",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "elementURL",
        "displayValue": "Element URL (Click URL, Form URL)"
      },
      {
        "value": "pageURL",
        "displayValue": "Page URL"
      },
      {
        "value": "pageURLAll",
        "displayValue": "Page URL All (Page URL + Fragment)"
      }
    ],
    "simpleValueType": true,
    "help": "Specify a choice or URL format variable.\u003cbr\u003e\n\u003cb\u003enote:\u003c/b\u003e Do not use the excerpt of only the query without \u0027?\u0027 Or the excerpt of only the hash tag without \u0027#\u0027."
  },
  {
    "type": "GROUP",
    "name": "targetFrom",
    "displayName": "Remove from what",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "help": "Check to remove from the target variable query (\"? ~~\").",
        "alwaysInSummary": true,
        "defaultValue": true,
        "name": "query",
        "checkboxText": "Queries",
        "type": "CHECKBOX"
      },
      {
        "help": "Check to remove from the target variable fragment (\"# ~~\").",
        "defaultValue": false,
        "name": "hash",
        "checkboxText": "Fragment",
        "type": "CHECKBOX"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "select",
    "displayName": "Select to delete",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "black",
        "displayValue": "Black list"
      },
      {
        "value": "white",
        "displayValue": "White list"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "black",
    "alwaysInSummary": true
  },
  {
    "name": "targetQueries",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Delete query key",
        "name": "query",
        "type": "TEXT",
        "isUnique": true,
        "valueHint": "e.g. _ga"
      }
    ],
    "type": "SIMPLE_TABLE",
    "alwaysInSummary": true,
    "enablingConditions": [
      {
        "paramName": "select",
        "paramValue": "black",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "LABEL",
    "name": "helpTextBlack",
    "displayName": "The entered \"Delete query key\" is used judge by an exact match (\"equals\"), and if it matches, the key and value are deleted.",
    "enablingConditions": [
      {
        "paramName": "select",
        "paramValue": "black",
        "type": "EQUALS"
      }
    ]
  },
  {
    "name": "filterQueries",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Delete query key",
        "name": "query",
        "type": "TEXT",
        "isUnique": true,
        "valueHint": "e.g. _ga"
      }
    ],
    "type": "SIMPLE_TABLE",
    "alwaysInSummary": true,
    "enablingConditions": [
      {
        "paramName": "select",
        "paramValue": "white",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "LABEL",
    "name": "helpTextWhite",
    "displayName": "The input \"Delete query key\" is determined by an exact match (\"equals\"), otherwise the key and value will be deleted.",
    "enablingConditions": [
      {
        "paramName": "select",
        "paramValue": "white",
        "type": "EQUALS"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// -------- API required
const log = require('logToConsole');
// data.targetURL: (elementURL | pageURL | pageURLAll | {{variable}})
// data.query: true
// data.hash: true
// data.select: black | white
// data.targetQueries: [{"query":"_ga"},{"query":"_gac"}]
// data.filterQueries: [{"query":"_ga"},{"query":"_gac"}]

// --------- Default Settings
// ---- Start Setting
var Var = data.targetURL;					// Target URL
const select = data.select;					// Select to delete(black | white)
const delQuery = data.targetQueries;			// Delete query key(black)
const filterQuery = data.filterQueries;			// Delete query key(white)
const delTarget = [data.query, data.hash];	// Remove from what（0:Queries、1:Fragment）

// ---- Get Target URL
switch(Var){
	case 'elementURL':
		var get = require('copyFromDataLayer');
		Var = get('gtm.elementUrl');
		break;
	case 'pageURL':
		var get = require('getUrl');
		Var = get('protocol') +'://' + get('host') + get('path');
		if(get('query')){
			Var += '?' + get('query');
		}
		break;
	case 'pageURLAll':
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

// --------- Processing
if(Var !== undefined){
	// ---- Split URL
	var path = Var.split('?')[0].split('#')[0];
	var query = null;
	var hash = null;
	if(Var.indexOf('?') >= 0){	// 1st '?' to before 1st '#'
		query = Var.split('#')[0].split('?').map(function(valQuery, index){
			return index !== 0 ? valQuery : undefined;
		}).join('');
		log('query = ' + query);
	}
	if(Var.indexOf('#') >= 0){	// 1st '#' to end
		hash = Var.split('#').map(function(valQuery, index){
			return index !== 0 ? valQuery : undefined;
		}).join('');
		log('hash = ' + hash);
	}

	// ---- Target Key query remove
	const omit = function(del, target, word){	// Black List
		if(delTarget[del] && target){
			// Search & destroy
			//var queries = target.split('&');
			// hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555&bbb=tester?test=000&aaa=111&bbb=222&ccc=333
			if(del == 1 && target.indexOf('?') >= 0){	// Split query
				// query in hash
				var queries = target.split('?')[0].split('&');
				queries[queries.length - 1] += '?' + target.split('?')[1];
			}else{
				// normal hash
				var queries = target.split('&');
			}
			for(var i = queries.length - 1; i >= 0; i--){	// For Query length from end to start
				for(var j = 0; j < delQuery.length; j++){	// For Delete Query length from start to end
					if(queries[i].indexOf(delQuery[j].query + '=') == 0){
						// If: Checking Delete target is true
						queries.splice(i, 1);	// Target delete
						break;
					}
				}
			}
			if(queries.length >= 1){
				// If: Queries is be.
				target = queries.join('&');
			}else{
				// If: Queries is none.
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
	const filtering = function(del, target, word){	// White list
		if(delTarget[del] && target){
			// Search & destroy
			if(del == 1 && target.indexOf('?') >= 0){	// Split query
				// query in hash
				var queries = target.split('?')[0].split('&');
				queries[queries.length - 1] += '?' + target.split('?')[1];
			}else{
				// normal hash
				var queries = target.split('&');
			}
			for(var i = queries.length - 1; i >= 0; i--){	// For Query length from end to start
				let flag = false;
				for(var j = 0; j < filterQuery.length; j++){	// For Delete Query length from start to end
					if(queries[i].indexOf(filterQuery[j].query + '=') == 0){
						// If: Checking Delete target is true
						flag = true;
						break;
					}
				}
				if(!flag){
					queries.splice(i, 1);	// Target delete
				}
			}
			if(queries.length >= 1){
				// If: Queries is be.
				target = queries.join('&');
			}else{
				// If: Queries is none.
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

	switch(select){
		case 'black':
			omit(0, query, '?');	// Remove from queries.
			omit(1, hash, '#');	// Remove from fragment.
			break;
		case 'white':
			filtering(0, query, '?');	// Remove from queries.
			filtering(1, hash, '#');	// Remove from fragment.
			break;
	}

	// ---- Complete.
	return path;
}else{
	return undefined;
}


___WEB_PERMISSIONS___

[
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
  },
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
  }
]


___TESTS___

scenarios:
- name: Basic - Black - query
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555',
      query: true,
      hash: false,
      select: 'black',
      targetQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Basic - Black - hash
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555',
      query: false,
      hash: true,
      select: 'black',
      targetQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Basic - Black - query and hash
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555',
      query: true,
      hash: true,
      select: 'black',
      targetQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Basic - White - query
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtag',
      query: true,
      hash: false,
      select: 'white',
      filterQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Basic - White - hash
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555',
      query: false,
      hash: true,
      select: 'white',
      filterQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Basic - White - query and hash
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555',
      query: true,
      hash: true,
      select: 'white',
      filterQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Rare - White - query and hash - 2
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555?test=000&aaa=111',
      query: true,
      hash: true,
      select: 'white',
      filterQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Rare - Black - hash - 2a
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/?aaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555?test=000&aaa=111',
      query: false,
      hash: true,
      select: 'black',
      targetQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
- name: Rare - Black - hash - 2b
  code: |-
    const mockData = {
      // Mocked field values
      targetURL: 'https://example.com/test1/test2/test3/#hashtagaaa=111&bbb=222&ccc=333&aaa=444&aaabbbccc=555&bbb=tester?test=000&aaa=111&bbb=222&ccc=333',
      query: false,
      hash: true,
      select: 'black',
      targetQueries: [{'query': 'aaa'},{'query': 'bbb'}]
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);


___NOTES___

Created on 2020/1/10 20:27:38


