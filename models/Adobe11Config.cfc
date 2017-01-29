/**
* I represent the behavior of reading and writing CF engine config in the format compatible with an Adobe 11.x server
* I extend the BaseConfig class, which represents the data itself.
*/
component accessors=true extends='BaseConfig' {
	
	property name='runtimeConfigPath' type='string';
	property name='runtimeConfigTemplate' type='string';

	property name='clientStoreConfigPath' type='string';
	property name='clientStoreConfigTemplate' type='string';

	property name='watchConfigPath' type='string';
	property name='watchConfigTemplate' type='string';

	property name='mailConfigPath' type='string';
	property name='mailConfigTemplate' type='string';

	property name='datasourceConfigPath' type='string';
	property name='datasourceConfigTemplate' type='string';


	property name='seedPropertiesPath' type='string';
	property name='passwordPropertiesPath' type='string';
	property name='AdobePasswordManager';
	
	/**
	* Constructor
	*/
	function init() {
		setRuntimeConfigTemplate( expandPath( '/resources/adobe11/neo-runtime.xml' ) );		
		setRuntimeConfigPath( '/lib/neo-runtime.xml' );
		
		setClientStoreConfigTemplate( expandPath( '/resources/adobe11/neo-clientstore.xml' ) );		
		setClientStoreConfigPath( '/lib/neo-clientstore.xml' );
		
		setWatchConfigTemplate( expandPath( '/resources/adobe11/neo-watch.xml' ) );		
		setWatchConfigPath( '/lib/neo-watch.xml' );
		
		setMailConfigTemplate( expandPath( '/resources/adobe11/neo-mail.xml' ) );		
		setMailConfigPath( '/lib/neo-mail.xml' );
		
		setDatasourceConfigTemplate( expandPath( '/resources/adobe11/neo-datasource.xml' ) );
		setDatasourceConfigPath( '/lib/neo-datasource.xml' );
		
		setSeedPropertiesPath( '/lib/seed.properties' );
		setPasswordPropertiesPath( '/lib/password.properties' );
		
		setAdobePasswordManager( new AdobePasswordManager() );
		
		super.init();
	}
	
	/**
	* I read in config
	*
	* @CFHomePath The JSON file to read from
	*/
	function read( string CFHomePath ){
		// Override what's set if a path is passed in
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		
		if( !len( getCFHomePath() ) ) {
			throw 'No CF home specified to read from';
		}
		
		readRuntime();
		readClientStore();
		readWatch();
		readMail();
		readDatasource();
		readAuth();
			
		return this;
	}
	
	private function readRuntime() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getRuntimeConfigPath(), '/' ) );
				
		setSessionMangement( thisConfig[ 7 ].session.enable );
		setSessionTimeout( thisConfig[ 7 ].session.timeout );
		setSessionMaximumTimeout( thisConfig[ 7 ].session.maximum_timeout );
		setSessionType( thisConfig[ 7 ].session.usej2eesession ? 'j2ee' : 'cfml' );
		
		setApplicationMangement( thisConfig[ 7 ].application.enable );
		setApplicationTimeout( thisConfig[ 7 ].application.timeout );
		setApplicationMaximumTimeout( thisConfig[ 7 ].application.maximum_timeout );
		
		// Stored as 0/1
		setErrorStatusCode( ( thisConfig[ 8 ].EnableHTTPStatus == 1 ) );
		setMissingErrorTemplate( thisConfig[ 8 ].missing_template );
		setGeneralErrorTemplate( thisConfig[ 8 ].site_wide );
		
		var ignoreList = '/CFIDE,/gateway';
		for( var thisMapping in thisConfig[ 9 ] ) {
			if( !listFindNoCase( ignoreList, thisMapping ) ){
				addCFMapping( thisMapping, thisConfig[ 9 ][ thisMapping ] );
			}
		}		
		
		setRequestTimeoutEnabled( thisConfig[ 10 ].timeoutRequests );
		// Convert from seconds to timespan
		setRequestTimeout( '0,0,0,#thisConfig[ 10 ].timeoutRequestTimeLimit#' );
		setPostParametersLimit( thisConfig[ 10 ].postParametersLimit );
		setPostSizeLimit( thisConfig[ 10 ].postSizeLimit );
				
		setTemplateCacheSize( thisConfig[ 11 ].templateCacheSize );
		if( thisConfig[ 11 ].trustedCacheEnabled ) {
			setInspectTemplate( 'never' );
		} else if ( thisConfig[ 11 ].inRequestTemplateCacheEnabled ?: false ) {
			setInspectTemplate( 'once' );
		} else {
			setInspectTemplate( 'always' );
		}
		setSaveClassFiles(  thisConfig[ 11 ].saveClassFiles  );
		setComponentCacheEnabled( thisConfig[ 11 ].componentCacheEnabled );
		
		setMailDefaultEncoding( thisConfig[ 12 ].defaultMailCharset );
		
		setCFFormScriptDirectory( thisConfig[ 14 ].CFFormScriptSrc );
		
		// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.
		setScriptProtect( thisConfig[ 15 ] );
		
		setPerAppSettingsEnabled( thisConfig[ 16 ].isPerAppSettingsEnabled );				
		// Adobe stores the inverse of Lucee
		setUDFTypeChecking( !thisConfig[ 16 ].cfcTypeCheckEnabled );
		setDisableInternalCFJavaComponents( thisConfig[ 16 ].disableServiceFactory );
		// Lucee and Adobe store opposite value
		setDotNotationUpperCase( !thisConfig[ 16 ].preserveCaseForSerialize );
		setSecureJSON( thisConfig[ 16 ].secureJSON );
		setSecureJSONPrefix( thisConfig[ 16 ].secureJSONPrefix );
		setMaxOutputBufferSize( thisConfig[ 16 ].maxOutputBufferSize );
		setInMemoryFileSystemEnabled( thisConfig[ 16 ].enableInMemoryFileSystem );
		setInMemoryFileSystemLimit( thisConfig[ 16 ].inMemoryFileSystemLimit );
		setInMemoryFileSystemAppLimit( thisConfig[ 16 ].inMemoryFileSystemAppLimit );
		setAllowExtraAttributesInAttrColl( thisConfig[ 16 ].allowExtraAttributesInAttrColl );
		setDisallowUnamedAppScope( thisConfig[ 16 ].dumpunnamedappscope );
		setAllowApplicationVarsInServletContext( thisConfig[ 16 ].allowappvarincontext );
		setCFaaSGeneratedFilesExpiryTime( thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime );
		setORMSearchIndexDirectory( thisConfig[ 16 ].ORMSearchIndexDirectory );
		setGoogleMapKey( thisConfig[ 16 ].googleMapKey );
		setServerCFCEenabled( thisConfig[ 16 ].enableServerCFC );
		setServerCFC( thisConfig[ 16 ].serverCFC );
		setCompileExtForCFInclude( thisConfig[ 16 ].compileextforinclude );
		setSessionCookieTimeout( thisConfig[ 16 ].sessionCookieTimeout );
		setSessionCookieHTTPOnly( thisConfig[ 16 ].httpOnlySessionCookie );
		setSessionCookieSecure( thisConfig[ 16 ].secureSessionCookie );
		setSessionCookieDisableUpdate( thisConfig[ 16 ].internalCookiesDisableUpdate );
		
		// Map Adobe values to shared Lucee settings
		switch( thisConfig[ 16 ].applicationCFCSearchLimit ) {
			case '1' :
				setApplicationMode( 'curr2driveroot' );
				break;
			case '2' :
				setApplicationMode( 'curr2root' );
				break;
			case '3' :
				setApplicationMode( 'currorroot' );
		}
				
		setThrottleThreshold( thisConfig[ 18 ][ 'throttle-threshold' ] );
		setTotalThrottleMemory( thisConfig[ 18 ][ 'total-throttle-memory' ] );
		
	}
	
	private function readClientStore() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getClientStoreConfigPath(), '/' ) );
				
		setUseUUIDForCFToken( thisConfig[ 2 ].uuidToken );
	}
	
	private function readWatch() {
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getWatchConfigPath(), '/' ) );
	
		setWatchConfigFilesForChangesEnabled( thisConfig[ 'watch.watchEnabled' ] );
		setWatchConfigFilesForChangesInterval( thisConfig[ 'watch.interval' ] );
		setWatchConfigFilesForChangesExtensions( thisConfig[ 'watch.extensions' ] );
	}
	
	private function readMail() {
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getMailConfigPath(), '/' ) );
		
		setMailSpoolEnable( thisConfig.spoolEnable );
		setMailSpoolInterval( thisConfig.schedule );
		setMailConnectionTimeout( thisConfig.timeout );
		setMailDownloadUndeliveredAttachments( thisConfig.allowDownload );
		setMailSignMesssage( thisConfig.sign );
		setMailSignKeystore( thisConfig.keystore );
		setMailSignKeystorePassword( passwordManager.decryptMailServer( thisConfig.keystorepassword ) );
		setMailSignKeyAlias( thisConfig.keyAlias );
		setMailSignKeyPassword( passwordManager.decryptMailServer( thisConfig.keypassword ) );
		
		addMailServer(
			smtp = thisConfig.server,
			username = thisConfig.username,
			password = passwordManager.decryptMailServer( thisConfig.password ),
			port = thisConfig.port,
			SSL= thisConfig.useSSL,
			TSL = thisConfig.useTLS		
		);	
	}
	
	private function readDatasource() {
		var passwordManager = getAdobePasswordManager().setSeedProperties( getCFHomePath().listAppend( getSeedPropertiesPath(), '/' ) );
		thisConfig = readWDDXConfigFile( getCFHomePath().listAppend( getDatasourceConfigPath(), '/' ) );
		var datasources = thisConfig[ 1 ];
		
		for( var datasource in datasources ) {
			// For brevity
			var ds = datasources[ datasource ];
			
			addDatasource(
				name = datasource,
				// TODO:  Turn ds.alter, ds.create, ds.drop, ds.grant, etc, etc into bitmask
				//allow = '',
				// Invert logic
				blob = !ds.disable_blob,	
				class = ds.class,
				// Invert logic
				clob = !ds.disable_clob,
				// If the field doesn't exist, it's unlimited
				connectionLimit = ds.urlmap.maxConnections ?: -1,
				// Convert from seconds to minutes
				connectionTimeout = round( ds.timeout / 60 ),
				database = ds.urlmap.database,
				// Normalize names
				dbdriver = translateDatasourceDriverToGeneric( ds.driver ),
				dsn = ds.url,
				host = ds.urlmap.host,
				password = passwordManager.decryptDataSource( ds.password ),
				port = ds.urlmap.port,
				username = ds.username,
				validate = ds.validateConnection
			);
		}
	}

	function readAuth() {
		var propertyFile = new propertyFile().load( getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' ) );
		if( !propertyFile.encrypted ) {
			setAdminPassword( propertyFile.password );
			setAdminRDSPassword( propertyFile.rdspassword );	
		} else {
			setACF11Password( propertyFile.password );
			setACF11RDSPassword( propertyFile.rdspassword );
		}
	}

	/**
	* I write out config from a base JSON format
	*
	* @CFHomePath The JSON file to write to
	*/
	function write( string CFHomePath ){
		setCFHomePath( arguments.CFHomePath ?: getCFHomePath() );
		var thisCFHomePath = getCFHomePath();
		
		if( !len( thisCFHomePath ) ) {
			throw 'No CF home specified to write to';
		}
		
		writeRuntime();
		writeClientStore();
		writeWatch();
		//writeMail();
		//writeDatasource();
		writeAuth();
		
		return this;
	}
	
	private function writeRuntime() {		
		var configFilePath = getCFHomePath().listAppend( getRuntimeConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getRuntimeConfigTemplate() );
		}
				
		if( !isNull( getSessionMangement() ) ) { thisConfig[ 7 ].session.enable = getSessionMangement(); }
		if( !isNull( getSessionTimeout() ) ) { thisConfig[ 7 ].session.timeout = getSessionTimeout(); }
		if( !isNull( getSessionMaximumTimeout() ) ) { thisConfig[ 7 ].session.maximum_timeout = getSessionMaximumTimeout(); }
		if( !isNull( getSessionType() ) ) { thisConfig[ 7 ].session.usej2eesession = ( getSessionType() == 'j2ee' ); }

		if( !isNull( getApplicationMangement() ) ) { thisConfig[ 7 ].application.enable = getApplicationMangement(); }
		if( !isNull( getApplicationTimeout() ) ) { thisConfig[ 7 ].application.timeout = getApplicationTimeout(); }
		if( !isNull( getApplicationMaximumTimeout() ) ) { thisConfig[ 7 ].application.maximum_timeout = getApplicationMaximumTimeout(); }
		
		// Convert from boolean back to 1/0
		if( !isNull( getErrorStatusCode() ) ) { thisConfig[ 8 ].EnableHTTPStatus = ( getErrorStatusCode() ? 1 : 0 ); }
		if( !isNull( getMissingErrorTemplate() ) ) { thisConfig[ 8 ].missing_template = getMissingErrorTemplate(); }
		if( !isNull( getGeneralErrorTemplate() ) ) { thisConfig[ 8 ].site_wide = getGeneralErrorTemplate(); }
		
		for( var virtual in getCFmappings() ?: {} ) {
			var physical = getCFmappings()[ virtual ][ 'physical' ];
			thisConfig[ 9 ][ virtual ] = physical;
		}
		
		if( !isNull( getRequestTimeoutEnabled() ) ) { thisConfig[ 10 ].timeoutRequests = getRequestTimeoutEnabled(); }
		if( !isNull( getRequestTimeout() ) ) {
			// Convert from timepsan to seconds
			var rt = getRequestTimeout();
			var ts = createTimespan( rt.listGetAt( 1 ), rt.listGetAt( 2 ), rt.listGetAt( 3 ), rt.listGetAt( 4 ) );
			// timespan of "1" is one day.  Multiple to get seconds
			thisConfig[ 10 ].timeoutRequestTimeLimit = round( ts*24*60*60 );
		}
		if( !isNull( getPostParametersLimit() ) ) { thisConfig[ 10 ].postParametersLimit = getPostParametersLimit(); }
		if( !isNull( getPostSizeLimit() ) ) { thisConfig[ 10 ].postSizeLimit = getPostSizeLimit(); }
		
		
		
		
		
		
		
		
		
		/*		
		
		
		
		
		
				
		setTemplateCacheSize( thisConfig[ 11 ].templateCacheSize );
		if( thisConfig[ 11 ].trustedCacheEnabled ) {
			setInspectTemplate( 'never' );
		} else if ( thisConfig[ 11 ].inRequestTemplateCacheEnabled ?: false ) {
			setInspectTemplate( 'once' );
		} else {
			setInspectTemplate( 'always' );
		}
		setSaveClassFiles(  thisConfig[ 11 ].saveClassFiles  );
		setComponentCacheEnabled( thisConfig[ 11 ].componentCacheEnabled );
		
		setMailDefaultEncoding( thisConfig[ 12 ].defaultMailCharset );
		
		setCFFormScriptDirectory( thisConfig[ 14 ].CFFormScriptSrc );
		
		// Adobe doesn't do "all" or "none" like Lucee, just the list.  Empty string if nothing.
		setScriptProtect( thisConfig[ 15 ] );
		
		setPerAppSettingsEnabled( thisConfig[ 16 ].isPerAppSettingsEnabled );				
		// Adobe stores the inverse of Lucee
		setUDFTypeChecking( !thisConfig[ 16 ].cfcTypeCheckEnabled );
		setDisableInternalCFJavaComponents( thisConfig[ 16 ].disableServiceFactory );
		// Lucee and Adobe store opposite value
		setDotNotationUpperCase( !thisConfig[ 16 ].preserveCaseForSerialize );
		setSecureJSON( thisConfig[ 16 ].secureJSON );
		setSecureJSONPrefix( thisConfig[ 16 ].secureJSONPrefix );
		setMaxOutputBufferSize( thisConfig[ 16 ].maxOutputBufferSize );
		setInMemoryFileSystemEnabled( thisConfig[ 16 ].enableInMemoryFileSystem );
		setInMemoryFileSystemLimit( thisConfig[ 16 ].inMemoryFileSystemLimit );
		setInMemoryFileSystemAppLimit( thisConfig[ 16 ].inMemoryFileSystemAppLimit );
		setAllowExtraAttributesInAttrColl( thisConfig[ 16 ].allowExtraAttributesInAttrColl );
		setDisallowUnamedAppScope( thisConfig[ 16 ].dumpunnamedappscope );
		setAllowApplicationVarsInServletContext( thisConfig[ 16 ].allowappvarincontext );
		setCFaaSGeneratedFilesExpiryTime( thisConfig[ 16 ].CFaaSGeneratedFilesExpiryTime );
		setORMSearchIndexDirectory( thisConfig[ 16 ].ORMSearchIndexDirectory );
		setGoogleMapKey( thisConfig[ 16 ].googleMapKey );
		setServerCFCEenabled( thisConfig[ 16 ].enableServerCFC );
		setServerCFC( thisConfig[ 16 ].serverCFC );
		setCompileExtForCFInclude( thisConfig[ 16 ].compileextforinclude );
		setSessionCookieTimeout( thisConfig[ 16 ].sessionCookieTimeout );
		setSessionCookieHTTPOnly( thisConfig[ 16 ].httpOnlySessionCookie );
		setSessionCookieSecure( thisConfig[ 16 ].secureSessionCookie );
		setSessionCookieDisableUpdate( thisConfig[ 16 ].internalCookiesDisableUpdate );
		
		// Map Adobe values to shared Lucee settings
		switch( thisConfig[ 16 ].applicationCFCSearchLimit ) {
			case '1' :
				setApplicationMode( 'curr2driveroot' );
				break;
			case '2' :
				setApplicationMode( 'curr2root' );
				break;
			case '3' :
				setApplicationMode( 'currorroot' );
		}
				
		setThrottleThreshold( thisConfig[ 18 ][ 'throttle-threshold' ] );
		setTotalThrottleMemory( thisConfig[ 18 ][ 'total-throttle-memory' ] );
		
		
		*/
		
		
		
		
		
		
		
		
		
		writeWDDXConfigFile( thisConfig, configFilePath );
		
	}
	
	private function writeClientStore() {
		var configFilePath = getCFHomePath().listAppend( getClientStoreConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getClientStoreConfigTemplate() );
		}
				
		if( !isNull( getUseUUIDForCFToken() ) ) { thisConfig[ 2 ].uuidToken = getUseUUIDForCFToken(); }

		writeWDDXConfigFile( thisConfig, configFilePath );
	}
	
	private function writeWatch() {
		var configFilePath = getCFHomePath().listAppend( getWatchConfigPath(), '/' );
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			var thisConfig = readWDDXConfigFile( configFilePath );
		// Otherwise, start from an empty base template
		} else {
			var thisConfig = readWDDXConfigFile( getWatchConfigTemplate() );
		}
				
		if( !isNull( getWatchConfigFilesForChangesEnabled() ) ) { thisConfig[ 'watch.watchEnabled' ] = getWatchConfigFilesForChangesEnabled(); }
		if( !isNull( getWatchConfigFilesForChangesInterval() ) ) { thisConfig[ 'watch.interval' ] = getWatchConfigFilesForChangesInterval(); }
		if( !isNull( getWatchConfigFilesForChangesExtensions() ) ) { thisConfig[ 'watch.extensions' ] = getWatchConfigFilesForChangesExtensions(); }
		
		writeWDDXConfigFile( thisConfig, configFilePath );
	
	}

	function writeAuth() {		
		var configFilePath = getCFHomePath().listAppend( getPasswordPropertiesPath(), '/' );
		
		var propertyFile = new propertyFile();
		
		// If the target config file exists, read it in
		if( fileExists( configFilePath ) ) {
			propertyFile.load( configFilePath );
		}
		
		if( !isNull( getAdminPassword() ) ) {
			propertyFile[ 'password' ] = getAdminPassword();
			propertyFile[ 'encrypted' ] = 'false';
			
			if( !isNull( getAdminRDSPassword() ) ) { propertyFile[ 'rdspassword' ] = getAdminRDSPassword(); }
			
		} else if( !isNull( getACF11Password() ) ) {
			propertyFile[ 'password' ] = getACF11Password();
			propertyFile[ 'encrypted' ] = 'true';
			
			if( !isNull( getACF11RDSPassword() ) ) { propertyFile[ 'rdspassword' ] = getACF11RDSPassword(); }
		}
		
		propertyFile.store();
	
	}

















	
	private function readWDDXConfigFile( required string configFilePath ) {
		if( !fileExists( configFilePath ) ) {
			throw "The config file doesn't exist [#configFilePath#]";
		}
		
		var thisConfigRaw = fileRead( configFilePath );
		if( !isXML( thisConfigRaw ) ) {
			throw "Config file doesn't contain XML [#configFilePath#]";
		}
		
		// Work around Lucee bug:
		// https://luceeserver.atlassian.net/browse/LDEV-1167
		thisConfigRaw = reReplaceNoCase( thisConfigRaw, '\s*type=["'']coldfusion\.server\.ConfigMap["'']', '', 'all' );
		
		wddx action='wddx2cfml' input=thisConfigRaw output='local.thisConfig';
		return local.thisConfig;		
	}
	
	private function writeWDDXConfigFile( required any data, required string configFilePath ) {
		
		// Ensure the parent directories exist		
		directoryCreate( path=getDirectoryFromPath( configFilePath ), createPath=true, ignoreExists=true )
		
		wddx action='cfml2wddx' input=data output='local.thisConfigRaw';
		
		fileWrite( configFilePath, thisConfigRaw );
		
	}

	private function getDefaultDatasourceStruct() {
		return {
		    "disable":false,
		    "disable_autogenkeys":false,
		    "revoke":true,
		    "validationQuery":"",
		    "drop":true,
		    // "url":"jdbc:mysql://localhost:3306/test?tinyInt1isBit=false&",
		    "url":"",
		    "update":true,
		    "password":"",
		    "DRIVER":"",
		    "NAME":"",
		    "blob_buffer":64000,
		    "disable_blob":true,
		    "timeout":1200,
		    "validateConnection":false,
		    "CLASS":"",
		    "grant":true,
		    "buffer":64000,
		    "username":"",
		    "login_timeout":30,
		    "description":"",
		    "urlmap":{
		        "defaultpassword":"",
		        "pageTimeout":"",
		        "SID":"",
		        "spyLogFile":"",
		        "CONNECTIONPROPS":{
		            "HOST":"",
		            "DATABASE":"",
		            "PORT":"0"
		        },
		        "host":"",
		        "_logintimeout":30,
		        "defaultusername":"",
		        "maxBufferSize":"",
		        "databaseFile":"",
		        "TimeStampAsString":"no",
		        "systemDatabaseFile":"",
		        "datasource":"",
		        "_port":0,
		        "args":"",
		        "supportLinks":"true",
		        "UseTrustedConnection":"false",
		        "applicationintent":"",
		        "sendStringParametersAsUnicode":"false",
		        "database":"test",
		        "informixServer":"",
		        "port":"0",
		        "MaxPooledStatements":"100",
		        "useSpyLog":false,
		        "isnewdb":"false",
		        "qTimeout":"0",
		        "selectMethod":"direct"
		    },
		    "insert":true,
		    "create":true,
		    "ISJ2EE":false,
		    "storedproc":true,
		    "interval":420,
		    "alter":true,
		    "delete":true,
		    "select":true,
		    "disable_clob":true,
		    "pooling":true,
		    "clientinfo":{
		        "ClientHostName":false,
		        "ApplicationNamePrefix":"",
		        "ApplicationName":false,
		        "ClientUser":false
		    }
		};
	}
	
	private function translateDatasourceDriverToGeneric( required string driverName ) {
		
		switch( driverName ) {
			case 'MSSQLServer' :
				return 'MSSQL';
			case 'PostgreSQL' :
				return 'PostgreSql';
			case 'Oracle' :
				return 'Oracle';
			case 'MySQL5' :
				return 'MySQL';
			case 'DB2' :
				return 'DB2';
			case 'Sybase' :
				return 'Sybase';
			case 'Apache Derby Client' :
				return 'Apache Derby Client';
			case 'Apache Derby Embedded' :
				return 'Apache Derby Embedded';
			case 'MySQL_DD' :
				return 'MySQL_DD';
			case 'jndi' :
				return 'jndi';
			default :
				return arguments.driverName;
		}
	
	}
	
	private function translateDatasourceDriverToAdobe( required string driverName ) {
		
		switch( driverName ) {
			case 'MSSQL' :
				return 'MSSQLServer';
			case 'PostgreSQL' :
				return 'PostgreSql';
			case 'Oracle' :
				return 'Oracle';
			case 'MySQL' :
				return 'MySQL5';
			case 'DB2' :
				return 'DB2';
			case 'Sybase' :
				return 'Sybase';
			// These all just fall through to default "other"
			case 'ODBC' :
			case 'HSQLDB' :
			case 'H2Server' :
			case 'H2' :
			case 'Firebird' :
			case 'MSSQL2' : // jTDS driver
			default :
				return arguments.driverName;
		}
	
	}
	
	private function translateDatasourceClassToAdobe( required string driverName, required string className ) {
		
		switch( driverName ) {
			case 'MSSQLServer' :
				return 'macromedia.jdbc.MacromediaDriver';
			case 'Oracle' :
				return 'macromedia.jdbc.MacromediaDriver';
			case 'MySQL5' :
				return 'com.mysql.jdbc.Driver';
			default :
				return arguments.className;
		}
	
	}
	
}