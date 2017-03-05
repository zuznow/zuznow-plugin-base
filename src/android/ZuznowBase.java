package com.zuznow.base;
import android.app.Activity;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewEngine;
import org.apache.cordova.PluginResult;
import org.apache.cordova.engine.SystemWebView;
import org.apache.cordova.engine.SystemWebViewEngine;
import org.json.JSONArray;
import org.json.JSONException;

import android.os.Handler;
import android.widget.ProgressBar;






public class ZuznowBase extends CordovaPlugin{


    public static final String ACTION_SET_AUTOMATIC = "setAutomaticSpinner";
    public static final String ACTION_SHOW = "show";
    public static final String ACTION_HIDE = "hide";
    public static final String ACTION_SHOW_WITH_TIMEOUT = "showWithTimeout";

    private LinearLayout progress;
    private Integer timeout;
    private Activity mActivity;
    private ZuzWebViewClientHelper helper;



    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {

        CordovaWebViewEngine webViewEngine = webView.getEngine();
        SystemWebView theView = (SystemWebView) webView.getEngine().getView();
        mActivity = cordova.getActivity();
        buildProgress();

        WebSettings settings = theView.getSettings();

        settings.setUseWideViewPort(true);
        settings.setJavaScriptCanOpenWindowsAutomatically(true);
        settings.setSupportMultipleWindows(true);
        settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NARROW_COLUMNS);
        theView.setInitialScale(1);
        boolean automatic_spinner = preferences.getBoolean("AutomaticSpinner", true);
        helper = new ZuzWebViewClientHelper(cordova, progress ,automatic_spinner);
        ZuzWebViewClient client = new ZuzWebViewClient((SystemWebViewEngine) webViewEngine, helper);
        theView.setWebViewClient(client);
        ZuzWebChromeClient chromeClient = new ZuzWebChromeClient((SystemWebViewEngine) webViewEngine, helper);
        theView.setWebChromeClient(chromeClient);

        //add progress & cordova view
        FrameLayout layoutWrapper = new FrameLayout(mActivity);
        layoutWrapper.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                1.0F));
        mActivity.setContentView(layoutWrapper);
        layoutWrapper.addView(webView.getView());
        layoutWrapper.addView(progress);


        super.initialize(cordova, webView);

    }

    protected void buildProgress(){

        progress = new LinearLayout(cordova.getActivity());
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
        params.weight = 1.0f;
        params.gravity = Gravity.CENTER;
        progress.setLayoutParams(params);
        progress.setGravity(Gravity.CENTER);
        ProgressBar progressbar = new ProgressBar(mActivity, null, android.R.attr.progressBarStyleLarge);
        progressbar.setIndeterminate(true);
        progress.addView(progressbar);
        int getLoaderBackground = mActivity.getResources().getIdentifier("loader_background","drawable", mActivity.getPackageName());
        if (getLoaderBackground != 0)
        {
            progress.setBackgroundResource(getLoaderBackground);
        }
        progress.setVisibility(View.GONE);
    }


    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        PluginResult result =  new PluginResult(PluginResult.Status.OK);

        try{
            if (ACTION_SET_AUTOMATIC.equals(action)){
                try {
                    helper.automatic_spinner = args.getBoolean(0);
                } catch (JSONException jsonEx) {
                    Log.v("ZuznowNativeSpinner", "showNativeSpinnerWithTimeout error: " + jsonEx.getMessage(), jsonEx);
                    result = new PluginResult(PluginResult.Status.JSON_EXCEPTION);
                }
            }
            else if (ACTION_SHOW.equals(action)){
                result = showNativeSpinner(args, callbackContext);
            }
            else if (ACTION_SHOW_WITH_TIMEOUT.equals(action)){
                result = showNativeSpinnerWithTimeout(args, callbackContext);
            }
            else if (ACTION_HIDE.equals(action)){
                result = hideNativeSpinner(args, callbackContext);
            }

        } catch (Exception e){
            Log.e("ZuznowNativeSpinner", "ZuznowNativeSpinner.execute: [" + action + "] Got Exception " + e.getMessage(), e);
            result = new PluginResult(PluginResult.Status.ERROR);
        }

        callbackContext.sendPluginResult(result);
        return true;
    }
//
//    private PluginResult initNativeSpinner(JSONArray args, CallbackContext callbackContext){
//        PluginResult result = null;
//        progress = ((ZuznowNativeSpinnerInterface)cordova.getActivity()).getProgress();
//        result = new PluginResult(PluginResult.Status.OK);
//
//        return result;
//    }

    private PluginResult showNativeSpinner(JSONArray args, CallbackContext callbackContext){
        PluginResult result = null;
        showSpinner();
        result = new PluginResult(PluginResult.Status.OK);

        return result;
    }

    private PluginResult showNativeSpinnerWithTimeout(JSONArray args, CallbackContext callbackContext){
        PluginResult result = null;
        try {
            timeout = args.getInt(0);
        } catch (JSONException jsonEx) {
            Log.v("ZuznowNativeSpinner", "showNativeSpinnerWithTimeout error: " + jsonEx.getMessage(), jsonEx);
            result = new PluginResult(PluginResult.Status.JSON_EXCEPTION);
        }
        showSpinner();
        Handler mHandler = new Handler();
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                hideSpinner();
            }
        }, timeout);
        result = new PluginResult(PluginResult.Status.OK);

        return result;
    }

    private PluginResult hideNativeSpinner(JSONArray args, CallbackContext callbackContext){
        PluginResult result = null;
        hideSpinner();
        result = new PluginResult(PluginResult.Status.OK);

        return result;
    }

    private void showSpinner(){
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                progress.setVisibility(View.VISIBLE);
            }
        });
    }

    private void hideSpinner(){
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                progress.setVisibility(View.GONE);
            }
        });
    }
}