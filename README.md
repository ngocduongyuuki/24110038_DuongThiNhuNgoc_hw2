# Homework 2 - Java Persistence API (JPA)

**Student ID:** 24110038  
**Student Name:** Duong Thi Nhu Ngoc

## Introduction

This project is developed for Web Programming Homework 2. It is based on Homework 1 and uses Java Persistence API (JPA) with Hibernate to interact with Microsoft SQL Server.

## Technologies

- Java
- Maven
- Jakarta Servlet
- JSP
- Jakarta Persistence API (JPA)
- Hibernate ORM
- Microsoft SQL Server
- Apache Tomcat

## Main Features

- Account management
- Product management
- Category management
- CRUD operations using JPA
- Database connection with Microsoft SQL Server

## Project Structure

```text
24110038_DuongThiNhuNgoc_hw2/
├── .mvn/
├── src/
│   └── main/
├── database.sql
├── pom.xml
├── .gitignore
└── .env.example
```

## Setup and Run

1. Install JDK, Maven, Microsoft SQL Server and Apache Tomcat.
2. Create the database using `database.sql`.
3. Configure the database connection according to `.env.example` and the project configuration.
4. Build the project:

```bash
mvn clean package
```

5. Deploy the generated WAR file from the `target` directory to Apache Tomcat.
6. Start Tomcat and access the application through your browser.

## Author

**Duong Thi Nhu Ngoc**  
GitHub: [ngocduongyuuki](https://github.com/ngocduongyuuki)
