# Findings
Defining how a currency evolves over time must be done regarding another currency (for example, today an Euro can be 1.3 USD and tomorrow 1.4), so for this task I would need a base currency related to which I will compare all other currencies. For me, this will be the Euro. But what happens if someone asks for the Euro evolution itself? Then it should be compared to another currency, which I defined as the American Dollar (USD)


I decided to follow a different approach to the web application, where I try to grab all the possibly related records with a single query, because the range could be huge, and asking for each date if a record exists is very costly, then, you have the consider the fact that the endpoint won't be used by only one person, so the number of queries (if you ask in a separate query for each day) can increase a lot.

In this case, as this service will be run only on the evening (low charge), and as it will ask just for five particular dates (today, yesterday, a week ago, a month ago and a year ago), I consider the time won in development is worth the extra queries.