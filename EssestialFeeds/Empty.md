#  <#Title#>

naming convention of test

testKeyword_methodWeAreTesting_behvaiourWeAreTesting


Approach 1:end-to-end tests:

Means we are actually hitting the network and then testing the response. This is a very good approach but it is very expensive and time consuming as for every test a network call is to be made. Network connection has to be present to run tests and moreover low network will result in tests taking longer time to validate. 

Approach 2:stub-subclassing:

In this approaach we subclass the urlsesion and override is method so that we dont make actual API call and can run tests. The issue with this approach is that we subclass URLSesion and we dont know internally foundation methods are being called. We dont have any control on it. This approach is dangeerious moving forward though it works fine. 

Approach 3: protocol based mocking:
