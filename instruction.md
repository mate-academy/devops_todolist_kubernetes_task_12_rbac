# INSTRUCTION.md

## Instructions to Validate Changes

Follow the steps below to validate the changes made in the project.

### Pre-requisites:

1. Ensure you have Python installed (version 3.8 or higher).
2. Verify that Django is installed in your environment (`pip install django`).
3. Install other dependencies listed in the `requirements.txt` file by running:
   ```bash
   pip install -r requirements.txt
   ```

### Steps to Validate:

1. **Run Migrations**:
    - Apply database migrations to ensure that the database is up-to-date with the models.
   ```bash
   python manage.py migrate
   ```

2. **Run Tests**:
    - Execute the unit tests provided in the project to ensure functionality is intact.
   ```bash
   python manage.py test
   ```

3. **Start the Development Server**:
    - Run the development server to manually test the application in your web browser.
   ```bash
   python manage.py runserver
   ```
    - Open your browser and navigate to `http://127.0.0.1:8000` to verify changes manually.

4. **Verify Logs (if applicable)**:
    - Check server logs to ensure there are no unexpected errors during runtime.

5. **Static Files (optional)**:
    - If your changes involve static files (CSS, JS), run the following to collect static files:
   ```bash
   python manage.py collectstatic
   ```

6. **Code Quality Check (if applicable)**:
    - Run linters or format checkers to ensure the code adheres to the project's style guide.
      Example with `flake8`:
   ```bash
   flake8 .
   ```

7. **Deployment (if applicable)**:
    - If the changes are for production, create/build after ensuring correct settings are configured:
   ```bash
   python manage.py check --deploy
   ```

### Validate Specific Changes:

- Highlight each feature or fix introduced in the current modification and verify the expected result manually or
  through automated tests.

Following these steps will ensure that all changes are correctly validated and do not introduce regressions.