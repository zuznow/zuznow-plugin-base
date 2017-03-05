package com.zuznow.base;

import org.apache.cordova.engine.SystemWebViewClient;
import org.apache.cordova.engine.SystemWebViewEngine;

import android.graphics.Bitmap;
import android.net.Uri;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;

public class ZuzWebViewClient extends SystemWebViewClient {
	
	private ZuzWebViewClientHelper helper;

	public ZuzWebViewClient(SystemWebViewEngine parentEngine, ZuzWebViewClientHelper helper) {
		super(parentEngine);
		this.helper = helper;
	}
	
	@Override
	public boolean shouldOverrideUrlLoading(WebView view, String url) {
		String scheme = Uri.parse(url).getScheme();
		if(!scheme.startsWith("http")){
			return super.shouldOverrideUrlLoading(view, url);
		}

		if(helper.shouldOpenUrlInsideApp(view, url)){
			return super.shouldOverrideUrlLoading(view, url);
		}
		
		boolean open = helper.openUrlExternal(url);
		if(open){
			return true;
		}
		else{
			return super.shouldOverrideUrlLoading(view, url);
		}
	}
	

	@Override
	public WebResourceResponse shouldInterceptRequest(WebView view, String url) {
		WebResourceResponse response = helper.loadWebResource(view, url);
		if(response == null){
			response = super.shouldInterceptRequest(view, url);
		}
		return response;
	}
	
	@Override
	public void onPageStarted (WebView view, String url, Bitmap favicon){ 
		super.onPageStarted (view, url, favicon);
		helper.onPageStarted (view, url, favicon);
	}
	
	@Override
	public void onPageFinished (WebView view, String url){
		helper.onPageFinished(view, url);
		super.onPageFinished(view, url);
	}
	
	@Override
	public void onReceivedError(WebView view, int errorCode,
			String description, String failingUrl) {
		boolean handeled = helper.onReceivedError(view, errorCode,description, failingUrl);
		if(!handeled){
			super.onReceivedError(view, errorCode, description, failingUrl);
		}
	}

}
