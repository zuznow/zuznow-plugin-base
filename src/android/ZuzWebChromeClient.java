package com.zuznow.base;

import org.apache.cordova.engine.SystemWebChromeClient;
import org.apache.cordova.engine.SystemWebViewEngine;

import android.os.Message;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class ZuzWebChromeClient extends SystemWebChromeClient {
	
	private ZuzWebViewClientHelper helper;

	public ZuzWebChromeClient(SystemWebViewEngine parentEngine, ZuzWebViewClientHelper helper) {
		super(parentEngine);
		this.helper = helper;
	}	
	
	@Override
    public void onShowCustomView(View view, WebChromeClient.CustomViewCallback callback) {
        super.onShowCustomView(view, callback);
        updateOrientationConfiguration();
    }

    @Override
    public void onHideCustomView() {
    	super.onHideCustomView();
    	updateOrientationConfiguration();
    }
    
    public void updateOrientationConfiguration() {		
		boolean fullView = parentEngine.getCordovaWebView().isCustomViewShowing();
		helper.updateOrientationConfiguration(fullView);
	}
	
	@Override
	public void onProgressChanged(WebView view, int newProgress){
		helper.onProgressChanged(view,newProgress);
		super.onProgressChanged(view,newProgress);
	}
	
	@Override
	public boolean onCreateWindow(WebView view, boolean isDialog,
			boolean isUserGesture, Message resultMsg) {
		 	WebView newWebView = new WebView(view.getContext());
	        newWebView.setWebViewClient(new TempWebClient(view));
	        WebView.WebViewTransport transport = (WebView.WebViewTransport)resultMsg.obj;
	        transport.setWebView(newWebView);
	        resultMsg.sendToTarget();
	        return true;
	}
	
	public class TempWebClient extends WebViewClient {		
		public WebView OriginalWebView;

		public TempWebClient(WebView originalWebView)
		{
			OriginalWebView = originalWebView;
		}
		
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			OriginalWebView.loadUrl(url);
			OriginalWebView = null;
			view.destroy();
			return true;
		}
		
	}

}
