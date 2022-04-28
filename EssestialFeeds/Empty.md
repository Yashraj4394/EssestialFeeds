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

An ephemeral session configuration object is similar to a default session configuration (see default), except that the corresponding session object doesn’t store caches, credential stores, or any session-related data to disk. Instead, session-related data is stored in RAM. The only time an ephemeral session writes data to disk is when you tell it to write the contents of a URL to a file.

By default, url loading system caches the url request and its requested data using the URLCache object.(Check the rules of default caching)

** Side Effects **
Side effects are changes to state outside the local scope.

"In computer science, an operation, function or expression is said to have a side effect if it modifies some state variable value(s) outside its local environment, that is to say has an observable effect besides returning a value (the main effect) to the invoker of the operation."—https://en.wikipedia.org/wiki/Side_effect_(computer_science)

Mutating some state in the DB/file system or updating the UI are examples of side-effects (mutating state outside the local scope). 

A function has no side-effects if it only operates with the data passed as arguments - without any mutation outside the local scope.

** Global Queue **
DispatchQueue.global returns a shared concurrent queue - so it's suitable for operations that can run concurrently. For example, when you want to run expensive operations (such as sorting an array with hundreds of thousands of elements) concurrently in a background queue to prevent blocking the main thread
