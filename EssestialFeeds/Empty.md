#  <#Title#>

naming convention of test

testKeyword_methodWeAreTesting_behvaiourWeAreTesting


testing strategies for network requests: 
Approach 1:End-to-end testing:

Means we are actually hitting the network and then testing the response. This is a very good approach but it is very expensive and time consuming as for every test a network call is to be made. Network connection has to be present to run tests and moreover low network will result in tests taking longer time to validate. 

Approach 2:Mocking with Subclasses:

In this approaach we subclass the urlsesion and override its method so that we dont make actual API call and can run tests. The issue with this approach is that we subclass URLSesion and we dont know how internally foundation methods are being called. We dont have any control on it. This approach is dangerous moving forward though it works fine. 
From our point of view, URLSession is a 3rd-party class (a class we don’t own) which we don’t have access to its implementation. We believe that by not owning the mocked class, we inherently increase the risk in our codebase because of the possible wrongful assumptions we make about it’s mocked behavior.
Another downside to subclass mocking is the tight coupling between the tests with the production code. For example, when mocking, the tests end up asserting precise method calls (first we assert that we’ve created a data task with a given URL using a specific API, then we assert that we’ve called resume to start the request, and only then we can assert the behavior we expect). 

Approach 3: Mocking with Protocols:

Approach 4: URLProtocol Stubbing:
use the little-known URL Loading System to intercept and handle requests with URLProtocol stubs.
Required methods when subclassing:URLProtocol 
class func canInit(with:URLRequest) -> Bool
class func canonicalRequest(for:URLRequest)
func startLoading()
func stopLoading()
