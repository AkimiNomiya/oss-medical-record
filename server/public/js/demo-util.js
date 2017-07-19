var DEMO_UTIL = {};

var _closeDialog = function () {
    $(this).dialog("close");
};

DEMO_UTIL.errorDialog = function (title, err) {
    $("#dialog").html('<pre>' + JSON.stringify(err) + '</pre>');
    var err = (err) ? err : _closeDialog;
    $("#dialog").dialog({
        modal: true,
        title: title,
        width: 400,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        buttons: {
            "OK": function () {
                window.location.href = './index.html';
            }
        }
    });
};

DEMO_UTIL.okDialog = function (title, comment, ok) {
    $("#dialog").html('<pre>' + comment + '</pre>');
    var ok = (ok) ? ok : _closeDialog;
    $("#dialog").dialog({
        modal: true,
        title: title,
        width: 400,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        buttons: {
            "OK": ok
        }
    });
};

DEMO_UTIL.confirmDialog = function (title, comment, ok, ng) {
    $("#dialog").html('<pre>' + comment + '</pre>');
    var ok = (ok) ? ok : _closeDialog;
    var ng = (ng) ? ng : _closeDialog;
    $("#dialog").dialog({
        modal: true,
        title: title,
        width: 400,
        open: function (event, ui) {
            $(".ui-dialog-titlebar-close").hide();
        },
        buttons: {
            "OK": ok,
            "Cancel": ng
        }
    });
};

DEMO_UTIL.createRandomId = function (len) {
    var c = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let id = '';
    for (let i = 0; i < len; i++) {
        id += c[Math.floor(Math.random() * c.length)];
    }
    return id;
}