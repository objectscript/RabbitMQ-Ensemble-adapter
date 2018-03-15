/// Various test methods
Class RabbitMQ.Utils
{

Parameter CLASS = "isc.rabbitmq.API";

Parameter CLASSPATH = "C:\InterSystems\RabbitMQjava.jar";

Parameter BUILDCLASSPATH = "D:\Cache\RabbitMQ\java\out\artifacts\RabbitMQjava_jar\RabbitMQjava.jar";

Parameter GATEWAY = "RabbitMQ";

Parameter QUEUE = "Test";

/// Load Jar from path.
/// Write $System.Status.GetErrorText(##class(RabbitMQ.Utils).UpdateJar())
ClassMethod UpdateJar(gatewayName = {..#GATEWAY}, path As %String = {..#CLASSPATH})
{
	#Dim sc As %Status = $$$OK
	Set sc = ##class(Ens.Director).StopProduction(, 1)
	Quit:$$$ISERR(sc) sc
	
	Set sc = ##class(%Net.Remote.Service).StopGateway(gatewayName)
	
	Set:$system["ed-pc" sc = ##class(%File).CopyFile(..#BUILDCLASSPATH,..#CLASSPATH, $$$YES, .result)
	Quit:sc'=1 $$$ERROR($$$GeneralError, $$$FormatText("File copy failed with error: %1", result))
	
	Set gateway = ..Connect(gatewayName, path, .sc)
	Quit:$$$ISERR(sc) sc
	
	Set sc = gateway.%Import(..#CLASS)
	Quit:$$$ISERR(sc) sc
	Set:'##class(%Dictionary.CompiledClass).%ExistsId(..#CLASS) sc = $$$ERROR($$$GeneralError, $$$FormatText("Class '%1' does not exist",..#CLASS))
	Quit:$$$ISERR(sc) sc
	
	Set sc = ##class(%Net.Remote.Service).StopGateway(gatewayName)
	
	Set sc = ##class(Ens.Director).StartProduction()
	Quit sc
}

/// Read one message.
/// Write $System.Status.GetErrorText(##class(RabbitMQ.Utils).ReadMsg())
ClassMethod ReadMsg(pMsgLen = 32000) As %Status
{
    #Dim gateway as %Net.Remote.Gateway
    #Dim exception as %Exception.AbstractException

    Set sc = $$$OK
    Try {
	    
        Set gateway = ..Connect()
        #Dim api As isc.rabbitmq.API
        Set api = ..GetAPI(gateway)

		Set list = ##class(%ListOfDataTypes).%New()
		For i=1:1:15 Do list.Insert("")
		
		#Dim stream As %Stream.Object
        Set stream = api.readMessageStream(.list)
        set body = stream.Read()
        Write !,"Body: ", body,!

        
        Zw list

        Set sc= gateway.%Disconnect()
    } Catch ex {
        Set sc = $$$ADDSC(ex.AsStatus(), $g(%objlasterror))
    }

    Quit sc
}

/// Read one message.
/// Write $System.Status.GetErrorText(##class(RabbitMQ.Utils).ReadMsgString())
ClassMethod ReadMsgString(pMsgLen = 32000) As %Status
{
    #Dim gateway as %Net.Remote.Gateway
    #Dim exception as %Exception.AbstractException

    Set sc = $$$OK
    Try {
	    
        Set gateway = ..Connect()
        #Dim api As isc.rabbitmq.API
        Set api = ..GetAPI(gateway)

		#Dim list As %ListOfDataTypes
        Set list = api.readMessageString()
        
        Write !,"Body: ",list.GetAt(16),!
        
        Zw list

        Set sc= gateway.%Disconnect()
    } Catch ex {
	    break
        Set sc = $$$ADDSC(ex.AsStatus(), $g(%objlasterror))
    }

    Quit sc
}

/// Send one message.
/// Write $System.Status.GetErrorText(##class(RabbitMQ.Utils).SendMsg())
ClassMethod SendMsg(msg = "356") As %Status
{
    #dim gateway as %Net.Remote.Gateway
    #dim exception as %Exception.AbstractException

    Set sc = $$$OK
    Try {
	    
        Set gateway = ..Connect()
        #Dim api As isc.rabbitmq.API
        Set api = ..GetAPI(gateway)

        Set stream = ##class(%GlobalBinaryStream).%New()
        Do stream.Write(msg)
		
        Do api.sendMessage(stream, "correlationId", "message " _ $zdt($zts,3,1,3))
        

        Set sc= gateway.%Disconnect()

    } Catch ex {
        Set sc = $$$ADDSC(ex.AsStatus(), $g(%objlasterror))
    }

    Quit sc
}

/// Get JGW object
ClassMethod Connect(gatewayName As %String = {..#GATEWAY}, path As %String = {..#CLASSPATH}, Output sc As %Status) As %Net.Remote.Gateway
{
	Set gateway = ""
	Set sc = ##class(%Net.Remote.Service).OpenGateway(gatewayName, .gatewayConfig)
	Quit:$$$ISERR(sc) gateway
	Set sc = ##class(%Net.Remote.Service).ConnectGateway(gatewayConfig, .gateway, path, $$$YES)
	Quit gateway
}

/// Construct RabbitMQ API object.
ClassMethod GetAPI(gateway As %Net.Remote.Gateway) As isc.rabbitmq.API
{
	Set host = "localhost"
	Set port = -1
	Set user = "guest"
	Set pass = "guest"
	Set virtualHost = "/"
	Set queue = ..#QUEUE
	Set durable = $$$YES
	
	Set api = ##class(isc.rabbitmq.API).%New(gateway,  host, port, user, pass, virtualHost, queue, durable)
	Quit api
}

}

