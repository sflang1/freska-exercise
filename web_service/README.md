# Findings

First of all, I started by reading the documentation of Fixer.io. I found out a perfect endpoint for grabbing all data from one time point to another: 

```
https://data.fixer.io/api/timeseries
    ? access_key = API_KEY
    & start_date = 2012-05-01
    & end_date = 2012-05-25
```

it should give you access to all the data from one date to another in only one request. Unluckily, this service is allowed only with a paid subscription, so I will have to use this endpoint: 

```
https://data.fixer.io/api/2013-12-24
    ? access_key = API_KEY
    & base = GBP
    & symbols = USD,CAD,EUR
```

That only gives one date at a time, and when given a range of days, I will have to call this endpoint once for each day in the range. Even though I know this isn't the most efficient solution, I have to do it in this way for this practical exercise.


When deciding whether I should fail the request to my API if one of the requests to the Fixer.io endpoints failed, I thought that maybe it's better for a user to get an incomplete batch of information than wait for a time while the Fixer.io requests are done and then if some failed, receive nothing. That's why I decided that just in case of failure of the connection with Fixer.io, I would return only the ones that were successful.


I tried that the application is as testable as possible, even though it should connect to an API. That's why I encapsulated all the API logic in a service. In the case that it needs to be tested, you can easily mock its results through RSpec, as I prove in the small tests I have created for testing the endpoint. In this way, you accomplish that for testing it is not needed to call the API, and that you can return whatever you want.