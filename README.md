# database-systems-nosql-project

Repository for the TUNI course DATA.DB.300 – Database Systems: NoSQL project.

## Setup

### Prerequisites

- Docker
- Docker compose
- A database management tool can be helpful

### Running the project

1. Clone the repository:
```
git clone https://github.com/SalonenTeemu/database-systems-nosql-project.git
```

2. Navigate to the project directory:
```
cd database-systems-nosql-project
```

3. Start the application using Docker compose:
```
docker-compose up
```

During the initial startup, table creation statements and seed data insertions are executed.

## Documentation

The `documentation/` folder contains:
- The project report including the business domain and use cases
- Database design and architecture documents

## PostgreSQL setup 

The `postgres/` folder contains:
- Table creation statements
- Data insertion scripts
- Queries for the first 10 project use cases

## MongoDB setup 

The `mongo/` folder contains:
- Collection creation statements
- Data insertion scripts
- Queries for the extra 3 project use cases

The MongoDB database can be viewed using the mongo-express image on `http://localhost:8081`.
The credentials to access the web UI are:
- Username: admin
- Password admin
