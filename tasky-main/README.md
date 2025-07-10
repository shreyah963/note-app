# Docker
A Dockerfile has been provided to run this application.  The default port exposed is 8080.

# Environment Variables
The following environment variables are needed.
|Variable|Purpose|example|
|---|---|---|
|`MONGODB_URI`|Address to mongo server|`mongodb://servername:27017` or `mongodb://username:password@hostname:port` or `mongodb+srv://` schema|
|`SECRET_KEY`|Secret key for JWT tokens|`secret123`|

Alternatively, you can create a `.env` file and load it up with the environment variables.

# Running with Go

Clone the repository into a directory of your choice Run the command `go mod tidy` to download the necessary packages.

You'll need to add a .env file and add a MongoDB connection string with the name `MONGODB_URI` to access your collection for task and user storage.
You'll also need to add `SECRET_KEY` to the .env file for JWT Authentication.

Run the command `go run main.go` and the project should run on `locahost:8080`

# License

This project is licensed under the terms of the MIT license.

Original project: https://github.com/dogukanozdemir/golang-todo-mongodb

# Vulnerable Notes App

## Overview
This is a deliberately vulnerable note-taking application built with Go, Gin, and MongoDB. It demonstrates common security flaws for educational purposes. **Do not use in production!**

## Features
- User registration and login (JWT-based)
- Create, read, update, and delete notes (title, body, tags)
- List all notes
- Simple web frontend for notes

## Intentional Vulnerabilities
- **Broken Access Control:** Any user can view, edit, or delete any note by ID.
- **Sensitive Info Logging:** Note contents and user IDs are logged to the server.
- **Overly Permissive Secrets:** (If secrets are hardcoded or exposed)
- **No Input Validation:** Allows XSS and injection attacks.
- **User Ownership Bypass:** Client can specify any user_id when creating notes.

## How to Exploit
1. **Broken Access Control:**
   - Log in as one user, create a note, then log in as another user and access the note by its ID using the API.
2. **Sensitive Info Logging:**
   - Check server logs after creating or updating notes to see sensitive data.
3. **Overly Permissive Secrets:**
   - Look for secrets in the code or public files.
4. **No Input Validation:**
   - Create a note with `<script>alert('XSS')</script>` in the title or body.
5. **User Ownership Bypass:**
   - Use the API to create a note with another user's ID.

## API Endpoints
- `POST   /signup` - Register a new user
- `POST   /login` - Log in
- `POST   /notes` - Create a note
- `GET    /notes` - List all notes
- `GET    /notes/:id` - Get a note by ID
- `PUT    /notes/:id` - Update a note by ID
- `DELETE /notes/:id` - Delete a note by ID

## Setup
1. Clone the repo and run `go mod tidy`.
2. Set up MongoDB and add your connection string to a `.env` file as `MONGODB_URI`.
3. Add a `SECRET_KEY` to your `.env` file.
4. Run the app: `go run main.go`
5. Access the app at [http://localhost:8080](http://localhost:8080)

## Warning
This app is intentionally insecure. Do not deploy it in a real environment.

---

## **1. How the File Gets Into the Image (Dockerfile)**

From your `tasky-main/Dockerfile`:
```dockerfile
COPY --from=build /go/src/tasky/assets ./assets
COPY --from=build /go/src/tasky/wizexercise.txt ./wizexercise.txt
```
- This copies the `assets` directory and the `wizexercise.txt` file from the build stage into the final image at `/app/assets` and `/app/wizexercise.txt`.

---

## **2. Validate the File Exists in the Running Container**

### **A. Find a Running Pod**

First, get the name of a running pod for your app:
```bash
kubectl get pods -n notes-app
```

### **B. Exec Into the Pod**

Open a shell inside the pod (replace `<pod-name>` with your pod’s name):
```bash
kubectl exec -it <pod-name> -n notes-app -- sh
```
- If your image uses Alpine, `sh` will work. If it’s Ubuntu/Debian, use `bash`.

### **C. List the File(s)**

Once inside the container, check for the file:
```sh
ls -l /app/wizexercise.txt
ls -l /app/assets
cat /app/wizexercise.txt
```
- This will show the file and its contents.

### **D. Screenshot/Proof**

- Take a screenshot of the terminal showing the file exists and (optionally) its contents.

---

## **Summary Table**

| Step | Command | What to Show |
|------|---------|--------------|
| Show Dockerfile COPY | (see above) | Dockerfile snippet |
| List pods | `kubectl get pods -n notes-app` | Pod name |
| Exec into pod | `kubectl exec -it <pod> -n notes-app -- sh` | Shell prompt |
| List/check file | `ls -l /app/wizexercise.txt`<br>`cat /app/wizexercise.txt` | File exists and contents |

---

**Let me know if you want a ready-to-copy command for your specific pod, or if you want to see how to do this for another file!**