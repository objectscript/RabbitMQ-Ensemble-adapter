Class RabbitMQ.Common Extends %RegisteredObject [ Abstract ]
{

/// This is the ID name of the set of credentials values (Username, Password) to be used to access the HTTP server
/// Property Credentials As %String [ InitialExpression = "None" ];
Property Host As %String [ InitialExpression = "localhost" ];

Property Port As %Integer [ InitialExpression = -1 ];

Property VirtualHost As %String [ InitialExpression = "/" ];

/// Outbound adapter only (ignored for inbound adapter)
/// If Exchange is not set, then Queue name.
/// If Exchange is set, then Routing key.
Property Queue As %String;

/// Exchange name. Optional, empty by default.
Property Exchange As %String;

/// Config Name of the Java Gateway service controlling the Java Gateway server this item will use.
/// Alternatively use JGHost and JGPort Settings, to specify Java gateway outside of Ensemble scope.
Property JGService As %String;

/// Hostname of the Java Gateway server this item will use.
/// Alternatively use JGService Setting, to specify Java gateway inside Ensemble.
Property JGHost As %String;

/// Port of the Java Gateway server this item will use.
/// Alternatively use JGService Setting, to specify Java gateway inside Ensemble.
Property JGPort As %Integer;

/// Gateway connection
Property JGW As %Net.Remote.Gateway;

/// API object
Property API As isc.rabbitmq.API;

/// Encoding to convert message body. Leave empty to get/send as is.
Property Encoding As %String;

/// CLASSPATH containing the files required to be passed as an argument when starting the JVM.
/// The user should typically provide here the files containing the classes used via the Java Gateway. 
/// We assume that the user has properly quoted the classpath and supplied the correct separators for the platform
/// in case of multiple files. <br>
/// See property AdditionalPaths in that class.
Property ClassPath As %String(MAXLEN = 32000);

/// How many times have we tried reconnecting
/// empty - do not retry
/// 0 - retry ad infinitum
/// n - retry n times
Property RetryCount As %Integer [ InitialExpression = 5 ];

/// How frequently to retry access to the output system.
/// Pause in seconds between retry attempts.
Property RetryInterval As %Numeric(MINVAL = 0) [ InitialExpression = 5 ];

/// These are the production settings for this object
Parameter SETTINGS = "Host:Basic,Port:Basic,VirtualHost:Basic,Queue:Basic,Credentials:Basic:credentialsSelector,JGHost:Java Gateway,JGPort:Java Gateway,JGService:Java Gateway:selector?context={Ens.ContextSearch/ProductionItems?targets=0&productionName=@productionId},ClassPath:Basic,Encoding:Basic,RetryCount:Alerting,RetryInterval:Alerting";

/// Connect to running JGW 
Method Connect() As %Status
{
    // connect to current namespace, use 2 second timeout
    Set sc = $$$OK
    Set timeout = 5
    Set classPath = ##class(%ListOfDataTypes).%New()
    Do classPath.Insert(..ClassPath)

    // get a connection handle and connect
    Set gateway = ##class(%Net.Remote.Gateway).%New()
    If ..JGService'="" {
		Set host = ##class(Ens.Director).GetHostSettingValue(..JGService, "Address")
		Set port = ##class(Ens.Director).GetHostSettingValue(..JGService, "Port")
    } Else {
	    Set host = ..JGHost
		Set port = ..JGPort
    }
    
    Set sc = gateway.%Connect(host, port, $namespace, timeout, classPath)

    If $$$ISOK(sc) {
	    Set ..JGW = gateway
    }
    Quit sc
}

Method ConnectToRabbitMQ() As %Status
{
	Set sc = $$$OK
	
	If ..%CredentialsObj.Username'="" {
		Set user = ..%CredentialsObj.Username
		Set pass = ..%CredentialsObj.Password
	} Else {
		Set user = "guest"
		Set pass = "guest"
	}
	
	Set port = $select(..Port="":-1, 1:..Port)
	
	Try {
		Set ..API = ##class(isc.rabbitmq.API).%New(..JGW, ..Host, port, user, pass, ..VirtualHost, ..Queue, $$$YES, ..Exchange)
	} Catch ex {
		Set sc = $$$ADDSC(ex.AsStatus(),$g(%objlasterror))
	}
	
	Quit sc
}

Method IsOpen() As %Status
{
	#Dim sc As %Status = $$$OK 
	Set retryCount = 1
	Try {
		While '..API.isOpen() {
			If ..RetryCount = "" {
				Set sc = $$$ERROR($$$GeneralError, "Connection problems. Consider specifying RetryCount and RetryInterval settings")
			} ElseIf ((..RetryCount = 0) || (retryCount < ..RetryCount)) {
				// wait and retry connecting
				Set retryCount = retryCount + 1
				Hang ..RetryInterval
				
				// reconnect happens in isOpen method			
			} Else {
				// we're out of reconnect attempts
				Set sc = $$$ERROR($$$GeneralError, $$$FormatText("Connection still closed after %1 attempts at reconnecting.", ..RetryCount))
			}
			Quit:$$$ISERR(sc)
		}
	} Catch ex {
		#Dim ex As %Exception.General
		Set sc = ex.AsStatus()
	}
	
	Quit sc
}

}

