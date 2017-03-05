var exec = require("cordova/exec");

var ZuznowNativeSpinner = function(options){
	exec(null, null, "ZuznowNativeSpinner", "init", []);
};

ZuznowNativeSpinner.prototype.show = function(timeout, successCallback, errorCallback){
	if (timeout){
		exec(successCallback, errorCallback, "ZuznowBase", "showWithTimeout", [timeout]);

	} else {
		exec(successCallback, errorCallback, "ZuznowBase", "show", []);
	}
};

ZuznowNativeSpinner.prototype.hide = function(successCallback, errorCallback){
	exec(successCallback, errorCallback, "ZuznowBase", "hide", []);
};

ZuznowNativeSpinner.prototype.setAutomaticSpinner = function(useAutomaticSpinner,successCallback, errorCallback){
	exec(successCallback, errorCallback, "ZuznowBase", "setAutomaticSpinner", [useAutomaticSpinner]);
};


module.exports = new ZuznowNativeSpinner();
