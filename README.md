# Homework 2 - Java Persistence API (JPA)

**Student ID:** 24110038  
**Student Name:** Duong Thi Nhu Ngoc

---

## Introduction

This project is developed for Web Programming Homework 2. It is based on Homework 1 and uses Java Persistence API (JPA) with Hibernate ORM to interact with Microsoft SQL Server.

## Screenshots

### Home Page

<img width="1917" height="1096" alt="Screenshot 2026-11-19 103020" src="https://github.com/user-attachments/assets/3f9d3b1e-6205-4a3b-a41a-7bceada57df9" />

### Login Page

<img width="1917" height="1097" alt="Screenshot 2026-11-19 103003" src="https://github.com/user-attachments/assets/18ad722f-3309-4ece-bd44-b208e83fbead" />

### Video Management

<img width="1917" height="1092" alt="Screenshot 2026-11-19 103047" src="https://github.com/user-attachments/assets/a8b24937-113e-468d-8054-591a68876d9c" />

### Video Details

<img width="1917" height="1095" alt="Screenshot 2026-11-19 103427" src="https://github.com/user-attachments/assets/20c79a9b-a9c1-4a70-b028-a1d5ce1bc70d" />


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

- Account registration with email OTP verification
- Login and logout
- Forgot password and password reset using OTP
- Account management
- Product management
- Category management
- Video upload and management
- Video listing and detail pages
- Display the 10 newest videos on the home page
- CRUD operations using JPA
- Database connection with Microsoft SQL Server

## Project Structure

```text
24110038_DuongThiNhuNgoc_hw2/
│
├── .mvn/
├── docs/
│   └── images/
│       ├── home.png
│       ├── login.png
│       ├── video-list.png
│       └── video-detail.png
│
├── src/
│   └── main/
│
├── database.sql
├── migration_videos.sql
├── pom.xml
├── .gitignore
└── .env.example
```

## Setup and Run

### Requirements

- JDK 17 or later
- Apache Maven
- Microsoft SQL Server
- Apache Tomcat 11

### Installation

1. Clone this repository:

```bash
git clone https://github.com/ngocduongyuuki/24110038_DuongThiNhuNgoc_hw2.git
```

2. Open the project directory.

3. Create the database using `database.sql`.

4. Run `migration_videos.sql` to create the Videos table.

5. Configure database and email settings according to `.env.example`.

6. Build the project:

```bash
mvn clean package
```

7. Deploy the generated WAR file from the `target` directory to Apache Tomcat.

8. Start Tomcat and access the application through your browser.

---

## Author

**Duong Thi Nhu Ngoc**

GitHub: [@ngocduongyuuki](https://github.com/ngocduongyuuki)
