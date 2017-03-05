package com.zuznow.base;


import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaInterface;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.view.View;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;

public class ZuzWebViewClientHelper {

	CordovaInterface cordova;
    LinearLayout progress;
	boolean automatic_spinner;
	String failUrl = null;
	
     

    static final String localPathV1_Remote = "s1.mob-server.com/files/phonegap/remoteToLocal/";
    
    public ZuzWebViewClientHelper(CordovaInterface cordova, LinearLayout progress, boolean automatic_spinner) {
		this.cordova = cordova;
		this.progress = progress;
		this.automatic_spinner = automatic_spinner;
	}

	private int getResourceId(String name, String type) {
		String pName =cordova.getActivity().getPackageName();
		Resources r = cordova.getActivity().getResources();
		int id = r.getIdentifier(name, type, pName);
		return id;
	}

    
    public boolean shouldOpenUrlInsideApp(WebView view, String url) {
		if(url.indexOf("zuzapp_external_url=true") == -1)
		{
			return true;
		}		
		return false;
	}
    
    public boolean openUrlExternal(String url){
    	try {
    		//this url should open external
    		url = url.replace("&zuzapp_external_url=true", "");
			url = url.replace("?zuzapp_external_url=true&", "?");
			url = url.replace("?zuzapp_external_url=true", "");
    		
    		Activity a = cordova.getActivity();			
			a.startActivity(new Intent(Intent.ACTION_VIEW,Uri.parse(url)));			
		} catch (Exception e1) {
			return false;
		}
    	return true;
    }
    
    public WebResourceResponse loadWebResource(WebView view, String url) {
		
		String scheme = url.startsWith("https://") ? "https://" : "http://"; 

		String tokenremote = scheme+localPathV1_Remote;
		WebResourceResponse response = null;
		String assetPath = null;
		 if(url != null && url.startsWith(tokenremote) ) {
			 assetPath = "www/"+url.substring(url.indexOf(tokenremote) + tokenremote.length(), url.length());			
		}
		
		if(assetPath != null){ //load local from assets
			String type="";
			if(url.endsWith(".js"))
			{
				type = "application/javascript";
			}
			else if(url.endsWith(".css"))
			{
				type = "text/css";
			}
			else if(url.endsWith(".png"))
			{
				type = "image/png";
			}
			try {
				response = new WebResourceResponse(
						type,
						"UTF8",
						view.getContext().getAssets().open(assetPath)
						);
			} catch (Exception e) {
				return null;
			}			
		}
		else
		{
			return null;
		}
		return response;
	}
    
    public void onPageStarted (WebView view, String url, Bitmap favicon){    
		
	}
    
   	public void onPageFinished (WebView view, String url){
		if(progress != null){
			progress.setVisibility(View.GONE);
		}		
	}	
	
   	public boolean onReceivedError(WebView view, int errorCode,
			String description, String failingUrl) {
		if(progress != null){
			progress.setVisibility(View.GONE);
		}			
		if ((errorCode == WebViewClient.ERROR_HOST_LOOKUP)||
				(errorCode == WebViewClient.ERROR_CONNECT)
				){ 
			//check if we have network connection, we get error also for resources
			boolean online = isOnline();
			if(!online){
				failUrl = view.getOriginalUrl();
				showMessage("Please check your network connection and try again","Problem connecting");
				
				String redirect_url = failingUrl;				
				
				String noConnectionStr = "<div><p>Unable to load information. Please check your network connection and click to reload. </p></div>";
				String summary = "<html><head><meta name='viewport' content='width=320' /></head><body style='width:320px;height:480px;' onclick='location.href=\""+redirect_url+"\";'><table height=100% width=100%><tbody><tr><td valign=middle>"+noConnectionStr+"</td></tr></tbody></table></body></html>";
								
				view.loadData(summary, "text/html", null);							
			}
			return true;
		}
		if (errorCode == WebViewClient.ERROR_UNSUPPORTED_SCHEME) {				
			view.goBack();
			return true;
		}
		return false;
	}
	
	public void onProgressChanged(WebView view, int newProgress){
		if(newProgress < 90){
			if (automatic_spinner) {
				progress.setVisibility(View.VISIBLE);
			}
		}
		else{
			progress.setVisibility(View.GONE);
		}
	}

	public void updateOrientationConfiguration(boolean fullView) {
	    if (fullView) {
	    	cordova.getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR);
	    } else {
	    	cordova.getActivity().setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
	    }
	}

	public synchronized void showMessage(final String message, final String title) {
    	final CordovaInterface cordova = this.cordova;
    	final String reloadUrl = this.failUrl;

        Runnable runnable = new Runnable() {
            public void run() {

                AlertDialog.Builder builder = new AlertDialog.Builder(cordova.getActivity());
                builder.setMessage(message);
                builder.setTitle(title);
                builder.setCancelable(true);
                builder.setPositiveButton("Retry", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                    	dialog.dismiss();
                    	//reload the page
                    	try {
							((CordovaActivity)cordova.getActivity()).loadUrl(reloadUrl);
						} catch (Exception e) 	{

						}
                    }
                });

                builder.create();
                builder.show();

            };
        };
        this.cordova.getActivity().runOnUiThread(runnable);
 }

	public boolean isOnline() {
	    ConnectivityManager cm = (ConnectivityManager) cordova.getActivity().getBaseContext()
	            .getSystemService(Context.CONNECTIVITY_SERVICE);

	    NetworkInfo i = cm.getActiveNetworkInfo();
	    if ((i == null) || (!i.isConnected())) {
	        return false;
	    }
	    return true;
	}

}
