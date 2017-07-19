var _langs = ["ja"];

var _lang = localStorage.getItem('_lang');
var _language;
if (_lang) {
    _language = _lang;
} else {
    _language = (window.navigator.languages && window.navigator.languages[0]) ||
        window.navigator.language ||
        window.navigator.userLanguage ||
        window.navigator.browserLanguage;
    localStorage.setItem('_lang', _language);
}

var _mergeLang = function (lang) {
    $.ajaxSetup({
        async: false
    });
    $.getJSON('/medical-record/locale/' + lang + ".json", function (data) {
        _demoMsg = $.extend(true, _demoMsg, data);
    });
    $.ajaxSetup({
        async: true
    });
}

var DEMO_MSG_LANG = "en";
var _demoMsg = {};
_mergeLang("en");
if (_language && _langs.includes(_language)) {
    _mergeLang(_language);
    DEMO_MSG_LANG = _language;
}

var _getSubdata = function (data, path) {
    var val = data;
    var segments = path.split('.');
    for (var i = 0; i < segments.length && val !== undefined; i++) {
        var seg = segments[i];
        if (seg === "") {;
        } else {
            if (typeof val === 'object') {
                val = val[seg];
            } else {
                val = undefined;
            }
        }
    }
    return val;
};

var demoMsg = function (key) {
    return _getSubdata(_demoMsg, key);
};

$(document).ready(function () {
    var _msg;
    $("[demo-msg]").each(function (i) {
        _msg = _getSubdata(_demoMsg, $(this).attr("demo-msg"));
        if (_msg) {
            $(this).html(_msg.replace(/\r?\n/g, '<br>'));
        }
    });
});
