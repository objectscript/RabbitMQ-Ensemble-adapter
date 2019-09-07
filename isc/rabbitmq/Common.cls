Class isc.rabbitmq.Common Extends %RegisteredObject [ Abstract ]
{

/// Either host or Connection URI: amqp:\\
/// If Connection URI is passed, then Port, Credentials and Virtual host properties are ignored.
Property Host As %VarString [ InitialExpression = "localhost" ];

Property Port As %Integer [ InitialExpression = -1 ];

Property VirtualHost As %String [ InitialExpression = "/" ];

Property Queue As %String;

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

/// These are the production settings for this object
Parameter SETTINGS = "Host:Basic,Port:Basic,VirtualHost:Basic,Queue:Basic,Credentials:Basic:credentialsSelector,JGHost:Java Gateway,JGPort:Java Gateway,JGService:Java Gateway:selector?context={Ens.ContextSearch/ProductionItems?targets=0&productionName=@productionId},ClassPath:Basic,Encoding:Basic";

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
	
	Try {
		Set ..API = ##class(isc.rabbitmq.API).%New(..JGW, ..Host, ..Port, user, pass, ..VirtualHost, ..Queue, $$$YES)
	} Catch ex {		
		Set sc = $$$ADDSC(ex.AsStatus(),$g(%objlasterror))
	}
	
	Quit sc
}

}

