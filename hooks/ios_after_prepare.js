#!/usr/bin/env node

//copy the content of Classes to override default classes
module.exports = function(context) {

  var ConfigParser;    

		
    var fs = context.requireCordovaModule('fs');
    var path = context.requireCordovaModule('path');

	function copyFileSync( source, target ) {

		var targetFile = target;

		//if target is a directory a new file with the same name will be created
		if ( fs.existsSync( target ) ) {
			if ( fs.lstatSync( target ).isDirectory() ) {
				targetFile = path.join( target, path.basename( source ) );
			}
		}

		fs.writeFileSync(targetFile, fs.readFileSync(source));
	}
	
	function copyFolderRecursiveSync( source, target ) {
		var files = [];

		//check if folder needs to be created or integrated
		var targetFolder = path.join( target, path.basename( source ) );
		if ( !fs.existsSync( targetFolder ) ) {
			fs.mkdirSync( targetFolder );
		}

		//copy
		if ( fs.lstatSync( source ).isDirectory() ) {
			files = fs.readdirSync( source );
			files.forEach( function ( file ) {
				var curSource = path.join( source, file );
				if ( fs.lstatSync( curSource ).isDirectory() ) {
					copyFolderRecursiveSync( curSource, targetFolder );
				} else {
					copyFileSync( curSource, targetFolder );
				}
			} );
		}
	}
	
	try {
        // cordova-lib >= 5.3.4 doesn't contain ConfigParser and xml-helpers anymore
        ConfigParser = context.requireCordovaModule("cordova-common").ConfigParser;
    } catch (e) {
        ConfigParser = context.requireCordovaModule("cordova-lib/src/configparser/ConfigParser");
    }
	
    var iosRoot = path.join(context.opts.projectRoot,'platforms', 'ios');
    var confFile = path.join(context.opts.projectRoot, 'config.xml');
    var cordovaConfig = new ConfigParser(confFile);

    var name = cordovaConfig.name();

    var targetDir = path.join(iosRoot , name );
	var sourceDir = context.opts.projectRoot + "/plugins/zuznow-plugin-base/src/ios/Classes";
	
	copyFolderRecursiveSync( sourceDir, targetDir );
	
	console.log("zuznow  -- ios files apdated");
	
	//copy media files if exist
	var mediaTarget = path.join(iosRoot,name, 'Images.xcassets');
	var mediaSource = path.join(context.opts.projectRoot,'zuznow', 'ios', 'res');
	var iconsSource = path.join(mediaSource,'AppIcon.appiconset');
	if (fs.existsSync( iconsSource ) ) {
		copyFolderRecursiveSync( iconsSource, mediaTarget );
		console.log("zuznow  -- ios icons apdated!");
	}
	var launchimageSource = path.join(mediaSource,'LaunchImage.launchimage');
	if ( fs.existsSync( launchimageSource ) ) {
		copyFolderRecursiveSync( launchimageSource, mediaTarget );
		console.log("zuznow  -- ios launch images apdated!");
	}
	var loaderBackground = path.join(mediaSource,'loader-background.png');
	if ( fs.existsSync( loaderBackground ) ) {
		var projectPath  = path.join(iosRoot,name+'.xcodeproj/project.pbxproj');
		var xcode = context.requireCordovaModule('xcode');
        var proj = new xcode.project(projectPath);
		var targetLoaderResources = path.join(targetDir,'Resources');
		if ( !fs.existsSync( targetLoaderResources ) ) {
			fs.mkdirSync( targetLoaderResources );
		}
		proj.parseSync();
		var opt = {};
		opt.plugin = false;
        proj.addResourceFile("loader-background.png",opt);
		fs.writeFileSync(projectPath, proj.writeSync());
		copyFileSync( loaderBackground, path.join(targetLoaderResources,'loader-background.png') );
        console.log("Updated loader-background!");
	}
};