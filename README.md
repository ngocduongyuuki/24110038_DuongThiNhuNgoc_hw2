# ProductManager - Java Web Application (JPA)

**Student ID:** 24110038  
**Student Name:** Duong Thi Nhu Ngoc

---

## Introduction

ProductManager is a Java Web Application developed for Web Programming Homework 2.

The project is based on Homework 1 and has been upgraded from JDBC to **Java Persistence API (JPA)** with Hibernate ORM for database operations.

The application provides an updated user interface for managing accounts, products, categories, and videos. It uses JSP and Jakarta Servlet for the web layer and Microsoft SQL Server for data storage.

The application is developed and deployed using **Visual Studio Code with Apache Tomcat 10.1.23** through the Server Connector extension.

## Screenshots

### Home Page

<img width="1917" height="1087" alt="Screenshot 2026-11-23 113511" src="https://github.com/user-attachments/assets/c8bd42bc-695b-4de8-8b69-783592b110db" />

### Login Page

<img width="1917" height="1091" alt="Screenshot 2026-11-23 113501" src="https://github.com/user-attachments/assets/de539cb2-f754-40b2-ba4f-29eba13eb436" />

### Video Management

![Uploading Screenshot 2026-11-23 113728.png…]()
### Video Details

<img width="1915" height="1088" alt="Screenshot 2026-11-23 113657" src="https://github.com/user-attachments/assets/c0c178f5-22fb-4ad6-8e70-bfbfd4466929" />


## Technologies

- Java (JDK 17+)
- Apache Maven
- Jakarta Servlet
- JavaServer Pages (JSP)
- Jakarta Persistence API (JPA)
- Hibernate ORM
- Microsoft SQL Server
- Apache Tomcat 10.1.23
- Visual Studio Code
- Red Hat Community Server Connector
- HTML, CSS, JavaScript

## Main Features

### Authentication and Account Management
- Account registration with email OTP verification.
- Login and logout.
- Forgot password and password reset using OTP.
- Account profile management.
- Profile information updates.

### Product and Category Management
- Product management (CRUD).
- Category management (CRUD).

### Video Management
- Video upload and management.
- Video listing and detail pages.
- Display the 10 newest videos on the home page.
- Store video metadata in Microsoft SQL Server.
- Store uploaded video files on the server's local file system.

### Database and Persistence
- JPA-based database operations.
- Hibernate ORM integration.
- Entity-based data persistence.
- Microsoft SQL Server connection.

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
│       ├── java/
│       ├── resources/
│       └── webapp/
│
├── database.sql
├── migration_videos.sql
├── pom.xml
├── .gitignore
└── .env.example
```

## Setup and Run

### Requirements

Install the following tools before running the project:

- JDK 17 or later.
- Apache Maven.
- Microsoft SQL Server.
- Visual Studio Code.
- Apache Tomcat 10.1.x.
- Red Hat Community Server Connector extension for VS Code.

### 1. Clone the Repository

```bash
git clone https://github.com/ngocduongyuuki/24110038_DuongThiNhuNgoc_hw2.git
```

Open the project folder in Visual Studio Code.

### 2. Configure the Database

1. Start Microsoft SQL Server.
2. Open SQL Server Management Studio (SSMS).
3. Execute `database.sql` to create the database and initial tables.
4. Execute `migration_videos.sql` if the video table has not been created.
5. Configure the database connection according to the project's configuration and `.env.example`.

Make sure the SQL Server instance, port, database name, username, and password match your local environment.

### 3. Configure Environment Variables

Check `.env.example` for the configuration variables required by the application.

Configure the required database, email, and file-storage settings for your local environment.

**Important:**
- `.env.example` is a configuration template, not a file containing actual credentials.
- Do not commit passwords, API keys, or other sensitive information to GitHub.
- Do not place secret `.env` files inside `src/main/resources`.
- Make sure the runtime configuration is available to the Tomcat server launched through VS Code.
- Configure `UPLOAD_DIR` to point to a valid local directory for uploaded videos.

### 4. Build the Project

Open the VS Code terminal in the project root and run:

```bash
mvn clean package
```

If the build succeeds, Maven generates the WAR file in the `target` directory.

### 5. Configure Tomcat in Visual Studio Code

The project uses **Apache Tomcat 10.1.23**, managed directly from Visual Studio Code.

1. Open Visual Studio Code.
2. Install the Red Hat Community Server Connector extension if it is not already installed.
3. Open the **SERVERS** panel.
4. Add or select an Apache Tomcat 10.1.x server.
5. Configure the Tomcat installation directory.
6. Start the Tomcat server.
7. Deploy the project to the server using the Server Connector interface.

The application is deployed and managed through VS Code. You do not need to manually copy the WAR file into the Tomcat `webapps` folder when using this workflow.

### 6. Run the Application

After Tomcat has started and the application has been deployed, open:

```text
http://localhost:8080/24110038_DuongThiNhuNgoc_hw2/
```

Login page:

```text
http://localhost:8080/24110038_DuongThiNhuNgoc_hw2/login
```

The application can be stopped, restarted, and redeployed through the VS Code **SERVERS** panel.

## Storage

Uploaded videos are stored as physical files on the server's local file system, while video metadata is stored in Microsoft SQL Server.

- **Storage location:** Configured through the `UPLOAD_DIR` JVM parameter.
- **Database:** Stores video information such as title, description, file paths, upload date, and owner.
- **Video files:** Stored separately from the source code and are not included in this GitHub repository.

When running the project on another machine, configure `UPLOAD_DIR` to point to a valid directory with appropriate read and write permissions.

## Notes

- The project uses Jakarta-based APIs and Apache Tomcat 10.1.x.
- Use the configured Tomcat server in VS Code to run and test the application.
- Database and email services must be configured before using features that depend on them.
- Uploaded files are stored locally and are not automatically transferred when cloning the repository.
- Never upload personal credentials or production secrets to GitHub.

## Author

**Duong Thi Nhu Ngoc**

GitHub: [@ngocduongyuuki](https://github.com/ngocduongyuuki)

Repository: [24110038_DuongThiNhuNgoc_hw2](https://github.com/ngocduongyuuki/24110038_DuongThiNhuNgoc_hw2)
