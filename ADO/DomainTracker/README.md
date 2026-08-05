## SSL Certificates Domain Tracker  
### The following story is from a friend of a friend, any similarity with reality is pure coincidence:<br>
It is a wonderful Sunday, you look outside and imagine going to some beautiful place, 
but suddently you receive a message in the Whatsapp: there is an incident in production, 
they are asking for help, who from prod support is available of if anyone could join 
because users are not able to use the system, and you just do what you have to... you signin.
After a few minutes checking logs you realize that it is an expired certificate.  The certificate is renewed, and all works again.
#### This things happen, after the root cause analysis it is always the same: the domain was out of the list or not even checked by that expensive
#### software that only does that: SSL certificate checks.


#### Today i am inspired and did in a few minutes this SSL certs checker.  The best is that i find it elegant, and most important: for free !!
The strategy is the following:

Azure Pipeline -> Retrieves certificates , updates certificates.csv -> Push it to Github --> access the report that reads the updated file.
![ADOImage](ADO.png)

#### Now you can just run this script and have a report and renew the certificate:
![ReportImage](Report.png)
