# Folder structure

I was asked to create two microservices. Each one of them is decoupled of the other and each reside in its own folder: web_service and report_job_service. Both of them are built with Ruby, and the web_service uses Ruby on Rails. Even though you mentioned in the email that you use Sinatra for your microservices, I have not worked with it as extensively as with Rails, so I prefered confort. Regarding the report_job, it could be done with a lot of languages but I particularly like Ruby as a scripting language, too! So I decided to go for it.

# How to run it
I created two environments for this, the development and the production one. 

## Development
You will need a postgres database server running in your machine. For setting it up, please follow these steps:

### Web microservice

1. Copy the .env.example.development to .env.development in the web_service folder
2. Replace your connection credentials in the .env.development file for you to have a connection to the database.
3. In .env.development, replace the FIXER_IO_API_KEY to your API key.
4. Run the commands: 
```
bundle install

rake db:create && rake db:migrate
```
5. The final step is to run 
```
rails server
```

### Report job microservice
1. Get into the report_job_service folder
2. Copy the .env.example.development to .env (<b>IMPORTANT</b>: It must be into .env, not .env.development)
3. Replace your values for providing connection to the database. Remember! The database name must be the same than in the web microservice. 
4. Inside report_job_service, create a tmp folder, like this:
```
mkdir tmp
```
4. For running this microservice, you can call 
```
ruby main.rb --currencies "USD,JPY" --formats "csv, json"
```

The currencies are a comma-separated string containing the acronyms of the currencies you want to consult, while formats is a comma-separated string containing one of the following formats (case sensiive) "csv", "json", "html", "xls".

The generated files will be saved within the tmp folder.


## Production
The production setup is done through Docker. I added a docker-compose file in the root of the project. 

1. Copy the .env.example file to .env in the root folder of the project and change in .env the POSTGRES_PASSWORD to the value you want to assign to your Postgres database in the Docker container. 
2. Copy the .env.example.production to .env.production in the web_service folder. Please, fill only the FIXER_IO_API_KEY and check that the database password is the same as the provided in the .env file that's found in the root folder of the project.
3. Because the master key that encrypted the credentials.yml.enc was not passed to Github, you must run this to set up a new credentials.yml.enc in the web_service folder, run: 
```
rm config/credentials.yml.enc
EDITOR=nano rails credentials:edit
```

3. Copy the .env.example.production file into the .env file in the report_job_service folder. Fill only the FIXER_IO_API_KEY and all the fields related to AWS, as we are going to upload the documents created to it. Check that the database name is the same than in the web_service folder and that the database password is the same than in the .env file in the root project.
4. Run in the root folder of the project
```
docker-compose build && docker-compose up
```
5. When it has finished, you will be able to send your requests to the web service in the location http://localhost:3000 
6. For running the production version of the report job, you should do this:
```
docker exec -it <-name or ID of the container -> bash
ENV=production ruby main.py --currencies "USD,JPY" --formats "csv, json"
```

## API specification
The api only has one endpoint:
```
GET /api/currencies/convert/:base_currency?start_date=your_date&end_date=your_date&to=destination_currency
```

For example: 
```
http://localhost:3000/api/currencies/convert/EUR?to=USD&start_date=2020-02-03&end_date=2020-02-05
```

All the params (base_currency, destination_currency, start and end date) are required and the server won't respond if any is not present. The server also checks if the start_date is earlier than the end_date.

It returns a parsed object with the rates per day:
```
[{"date":"2020-02-05","from":"EUR","to":"USD","rate":1.099993},{"date":"2020-02-04","from":"EUR","to":"USD","rate":1.104487},{"date":"2020-02-03","from":"EUR","to":"USD","rate":1.106256}]
```

