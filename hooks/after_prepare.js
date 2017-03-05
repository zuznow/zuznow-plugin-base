#!/usr/bin/env node

module.exports = function(context) {

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
    
    
     function rmDir(dirPath) {
      try { var files = fs.readdirSync(dirPath); }
      catch(e) { return; }
      if (files.length > 0)
        for (var i = 0; i < files.length; i++) {
          var filePath = path.join(dirPath,files[i]);
          if (fs.statSync(filePath).isFile())
            fs.unlinkSync(filePath);
          else
            rmDir(filePath);
        }
      fs.rmdirSync(dirPath);
    };
    
    

    var ConfigParser;
    try {
        // cordova-lib >= 5.3.4 doesn't contain ConfigParser and xml-helpers anymore
        ConfigParser = context.requireCordovaModule("cordova-common").ConfigParser;
    } catch (e) {
        ConfigParser = context.requireCordovaModule("cordova-lib/src/configparser/ConfigParser");
    }

    var fs = context.requireCordovaModule('fs');
    var path = context.requireCordovaModule('path');
    var glob = context.requireCordovaModule('glob');

    var pluginRoot = path.join(context.opts.projectRoot,'plugins', 'zuznow-plugin-base');

    var androidRoot = path.join(context.opts.projectRoot,'platforms', 'android');
    var confFile = path.join(context.opts.projectRoot, 'config.xml');
    var cordovaConfig = new ConfigParser(confFile);

    var androidPackageName = cordovaConfig.packageName();

    var androidPackageDir = path.join(androidRoot, 'src', path.join.apply(null, androidPackageName.split('.')));


    var inFile = path.join(pluginRoot,'src','android',"MainActivity.java");
    var outFile = path.join(androidPackageDir,"MainActivity.java");
    var data = fs.readFileSync(inFile,'utf8');
    data = data.replace(/com\.zuznow/gi, androidPackageName);
    fs.writeFileSync(outFile, data);


    var mediaSource = path.join(context.opts.projectRoot,'zuznow', 'android', 'res');
    var mediaTarget = path.join(androidRoot);
    if ( fs.existsSync( mediaSource ) ) {
		console.log("zuznow -- remove unused media files");
		var files =  glob.sync(path.join(androidRoot,'res','drawable')+"*/screen.png" );	
		files.map(fs.unlinkSync);
        files =  glob.sync(path.join(androidRoot,'res','drawable')+"*/icon.png" );    
        files.map(fs.unlinkSync);
        console.log("zuznow -- copyFiles media from: "+mediaSource+" to: "+mediaTarget);
        copyFolderRecursiveSync( mediaSource, mediaTarget );
    }



};
